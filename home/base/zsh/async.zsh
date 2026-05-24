#!/usr/bin/env zsh

# zsh-async v1.8.6 by Mathias Fredriksson — https://github.com/mafredri/zsh-async — MIT

typeset -g ASYNC_VERSION=1.8.6
typeset -g ASYNC_DEBUG=${ASYNC_DEBUG:-0}

_async_eval() {
	local ASYNC_JOB_NAME
	# Rename job to [async/eval] and pipe all output (stdout + stderr,
	# not separated) into _async_job's cat for unified handling.
	{
		eval "$@"
	} &> >(ASYNC_JOB_NAME=[async/eval] _async_job 'command -p cat')
}

_async_job() {
	# Disable xtrace as it would mangle the output.
	setopt localoptions noxtrace

	float -F duration=$EPOCHREALTIME

	# Capture stdout (eval) and stderr (cat) in separate subshells. After
	# the command block exits, cat's stdin closes and stderr is appended
	# with a trailing \0 to mark end-of-output.
	local jobname=${ASYNC_JOB_NAME:-$1} out
	out="$(
		local stdout stderr ret tok
		{
			stdout=$(eval "$@")
			ret=$?
			duration=$(( EPOCHREALTIME - duration ))

			print -r -n - $'\0'${(q)jobname} $ret ${(q)stdout} $duration
		} 2> >(stderr=$(command -p cat) && print -r -n - " "${(q)stderr}$'\0')
	)"
	if [[ $out != $'\0'*$'\0' ]]; then
		# Corrupted output (aborted job?), skip.
		return
	fi

	# Mutex: stall until token available, output, then release.
	read -r -k 1 -p tok || return 1
	print -r -n - "$out"
	print -n -p $tok
}

_async_worker() {
	emulate -R zsh

	# Avoid printing pids of child processes.
	unsetopt monitor

	# Silence fork-failed / malloc errors (zsh 5.0.2 & 5.0.8 are noisy).
	exec 2>/dev/null

	# `zpty -d` sends SIGHUP to all earlier zpty instances; without this
	# trap our worker would exit even though it still appears in `zpty -L`.
	# Fixed in zsh >= 5.4.1.
	if ! is-at-least 5.4.1; then
		TRAPHUP() {
			return 0
		}
	fi

	local -A storage
	local unique=0
	local notify_parent=0
	local parent_pid=0
	local coproc_pid=0
	local processing=0

	local -a zsh_hooks zsh_hook_functions
	zsh_hooks=(chpwd periodic precmd preexec zshexit zshaddhistory)
	zsh_hook_functions=(${^zsh_hooks}_functions)
	# Deactivate all zsh hooks (and their registered functions) inside the worker.
	unfunction $zsh_hooks &>/dev/null
	unset $zsh_hook_functions
	unset zsh_hooks zsh_hook_functions

	close_idle_coproc() {
		local -a pids
		pids=(${${(v)jobstates##*:*:}%\=*})

		# If only the cat coproc is running, close it to keep the process tree clean.
		if  (( ! processing )) && [[ $#pids = 1 ]] && [[ $coproc_pid = $pids[1] ]]; then
			coproc :
			coproc_pid=0
		fi
	}

	child_exit() {
		close_idle_coproc

		# SIGWINCH for cross-version compatibility: pre-5.2 zsh's zpty had
		# no fd; pre-5.1.1, INFO/ALRM/USR1 could deadlock under some conditions.
		if (( notify_parent )); then
			kill -WINCH $parent_pid
		fi
	}

	trap child_exit CHLD

	while getopts "np:uz" opt; do
		case $opt in
			n) notify_parent=1;;
			p) parent_pid=$OPTARG;;
			u) unique=1;;
			z) notify_parent=0;;  # Uses ZLE watcher instead.
		esac
	done

	# Does not reinstall the child trap.
	terminate_jobs() {
		trap - CHLD
		coproc :
		coproc_pid=0

		if is-at-least 5.4.1; then
			# Catch the HUP sent to this process before propagating to group.
			trap '' HUP
			kill -HUP -$$
			trap - HUP
		else
			# HUP already handled by TRAPHUP above for zsh < 5.4.1.
			kill -HUP -$$
		fi
	}

	killjobs() {
		local tok
		local -a pids
		pids=(${${(v)jobstates##*:*:}%\=*})

		(( $#pids == 0 )) && continue
		(( $#pids == 1 )) && [[ $coproc_pid = $pids[1] ]] && continue

		# Grab the lock so we don't kill mid-write and corrupt output.
		(( coproc_pid )) && read -r -k 1 -p tok

		terminate_jobs
		trap child_exit CHLD
	}

	local request do_eval=0
	local -a cmd
	while :; do
		read -r -d $'\0' request || {
			# zpty is broken; shut down and report as a last hurrah.
			terminate_jobs
			print -r -n $'\0'"'[async]'" $(( 127 + 3 )) "''" 0 "'$0:$LINENO: zpty fd died, exiting'"$'\0'
			# Use `return`, not `exit` — `exit` can loop infinitely with high CPU.
			return $(( 127 + 1 ))
		}

		# A respawned zpty sometimes prefixes messages with \C-M; strip it.
		request=${request#$'\C-M'}

		case $request in
			_killjobs)    killjobs; continue;;
			_async_eval*) do_eval=1;;
		esac

		# (z) shell-parses so single strings and multi-arg forms both work.
		cmd=("${(z)request}")

		local job=$cmd[1]

		# Unique mode: skip if a previous job with this name is still running.
		# Doesn't apply to eval (which is synchronous).
		if (( !do_eval )) && (( unique )); then
			for pid in ${${(v)jobstates##*:*:}%\=*}; do
				if [[ ${storage[$job]} == $pid ]]; then
					continue 2
				fi
			done
		fi

		# Guard against closing the coproc from the trap before the command starts.
		processing=1

		# Recreate coproc — it gets closed after the last job completes.
		if (( ! coproc_pid )); then
			# coproc acts as a mutex for synchronized output across children.
			coproc command -p cat
			coproc_pid="$!"
			print -n -p "t"
		fi

		if (( do_eval )); then
			shift cmd  # Strip _async_eval.
			_async_eval $cmd
		else
			_async_job $cmd &
			# Store pid manually — zsh's job manager shows '$job' non-uniquely.
			storage[$job]="$!"
		fi

		processing=0

		if (( do_eval )); then
			do_eval=0

			# No active jobs means CHLD trap won't fire for coproc cleanup.
			close_idle_coproc
		fi
	done
}

# async_process_results <worker> <callback>
#   Drains finished jobs and invokes callback($jobname, $ret, $stdout, $exec_time, $stderr, $has_next).
#   On buffer corruption, jobname is "[async]" and ret is non-zero.
async_process_results() {
	setopt localoptions unset noshwordsplit noksharrays noposixidentifiers noposixstrings

	local worker=$1
	local callback=$2
	local caller=$3
	local -a items
	local null=$'\0' data
	integer -l len pos num_processed has_next

	typeset -gA ASYNC_PROCESS_BUFFER

	while zpty -r -t $worker data 2>/dev/null; do
		ASYNC_PROCESS_BUFFER[$worker]+=$data
		len=${#ASYNC_PROCESS_BUFFER[$worker]}
		pos=${ASYNC_PROCESS_BUFFER[$worker][(i)$null]}  # Index of NUL delimiter.

		# Wait for a NUL before parsing.
		if (( ! len )) || (( pos > len )); then
			continue
		fi

		while (( pos <= len )); do
			# (z) shell-parses, (Q@) unquotes back to an array.
			items=("${(@Q)${(z)ASYNC_PROCESS_BUFFER[$worker][1,$pos-1]}}")

			ASYNC_PROCESS_BUFFER[$worker]=${ASYNC_PROCESS_BUFFER[$worker][$pos+1,$len]}

			len=${#ASYNC_PROCESS_BUFFER[$worker]}
			if (( len > 1 )); then
				pos=${ASYNC_PROCESS_BUFFER[$worker][(i)$null]}
			fi

			has_next=$(( len != 0 ))
			if (( $#items == 5 )); then
				items+=($has_next)
				$callback "${(@)items}"
				(( num_processed++ ))
			elif [[ -z $items ]]; then
				# Empty items: double-null between results from commands
				# being pre- and suffixed with \0.
			else
				$callback "[async]" 1 "" 0 "$0:$LINENO: error: bad format, got ${#items} items (${(q)items})" $has_next
			fi
		done
	done

	(( num_processed )) && return 0

	# Don't print exit value when `setopt printexitvalue` is active.
	[[ $caller = trap || $caller = watcher ]] && return 0

	return 1
}

_async_zle_watcher() {
	setopt localoptions noshwordsplit
	typeset -gA ASYNC_PTYS ASYNC_CALLBACKS
	local worker=$ASYNC_PTYS[$1]
	local callback=$ASYNC_CALLBACKS[$worker]

	if [[ -n $2 ]]; then
		# $2 from `zle -F`: hup/nval/err (man zshzle). Stop also unregisters the broken fd.
		async_stop_worker $worker

		if [[ -n $callback ]]; then
			$callback '[async]' 2 "" 0 "$0:$LINENO: error: fd for $worker failed: zle -F $1 returned error $2" 0
		fi
		return
	fi;

	if [[ -n $callback ]]; then
		async_process_results $worker $callback watcher
	fi
}

_async_send_job() {
	setopt localoptions noshwordsplit noksharrays noposixidentifiers noposixstrings

	local caller=$1
	local worker=$2
	shift 2

	zpty -t $worker &>/dev/null || {
		typeset -gA ASYNC_CALLBACKS
		local callback=$ASYNC_CALLBACKS[$worker]

		if [[ -n $callback ]]; then
			$callback '[async]' 3 "" 0 "$0:$LINENO: error: no such worker: $worker" 0
		else
			print -u2 "$caller: no such async worker: $worker"
		fi
		return 1
	}

	zpty -w $worker "$@"$'\0'
}

# async_job <worker> <fn> [args...]
#   Run fn asynchronously. fn must be defined before the worker started.
async_job() {
	setopt localoptions noshwordsplit noksharrays noposixidentifiers noposixstrings

	local worker=$1; shift

	local -a cmd
	cmd=("$@")
	if (( $#cmd > 1 )); then
		cmd=(${(q)cmd})
	fi

	_async_send_job $0 $worker "$cmd"
}

# async_worker_eval <worker> <fn> [args...]
#   Like async_job but mutates the worker's env (e.g. cd changes worker PWD).
#   Output returned via callback with jobname [async/eval].
async_worker_eval() {
	setopt localoptions noshwordsplit noksharrays noposixidentifiers noposixstrings

	local worker=$1; shift

	local -a cmd
	cmd=("$@")
	if (( $#cmd > 1 )); then
		cmd=(${(q)cmd})
	fi

	# Quote in case RC_EXPAND_PARAM is set.
	_async_send_job $0 $worker "_async_eval $cmd"
}

_async_notify_trap() {
	setopt localoptions noshwordsplit

	local k
	for k in ${(k)ASYNC_CALLBACKS}; do
		async_process_results $k ${ASYNC_CALLBACKS[$k]} trap
	done
}

# async_register_callback <worker> <callback>
#   Worker must be started with -n. Callback runs on job completion.
async_register_callback() {
	setopt localoptions noshwordsplit nolocaltraps

	typeset -gA ASYNC_PTYS ASYNC_CALLBACKS
	local worker=$1; shift

	ASYNC_CALLBACKS[$worker]="$*"

	# Without ZLE we use a SIGWINCH trap; with ZLE, a `zle -F` watcher.
	if [[ ! -o interactive ]] || [[ ! -o zle ]]; then
		trap '_async_notify_trap' WINCH
	elif [[ -o interactive ]] && [[ -o zle ]]; then
		local fd w
		for fd w in ${(@kv)ASYNC_PTYS}; do
			if [[ $w == $worker ]]; then
				zle -F $fd _async_zle_watcher
				break
			fi
		done
	fi
}

async_unregister_callback() {
	typeset -gA ASYNC_CALLBACKS

	unset "ASYNC_CALLBACKS[$1]"
}

# async_flush_jobs <worker>
#   Terminates all running processes under the worker.
async_flush_jobs() {
	setopt localoptions noshwordsplit

	local worker=$1; shift

	zpty -t $worker &>/dev/null || return 1

	async_job $worker "_killjobs"

	local junk
	if zpty -r -t $worker junk '*'; then
		(( ASYNC_DEBUG )) && print -n "async_flush_jobs $worker: ${(V)junk}"
		while zpty -r -t $worker junk '*'; do
			(( ASYNC_DEBUG )) && print -n "${(V)junk}"
		done
		(( ASYNC_DEBUG )) && print
	fi

	# Clear partially parsed responses too.
	typeset -gA ASYNC_PROCESS_BUFFER
	unset "ASYNC_PROCESS_BUFFER[$worker]"
}

# async_start_worker <worker> [-u] [-n] [-p <pid>]
#   -u unique (skip if same jobname is in-flight)
#   -n notify via SIGWINCH on job completion
#   -p pid to notify (default: current pid)
async_start_worker() {
	setopt localoptions noshwordsplit noclobber

	local worker=$1; shift
	local -a args
	args=("$@")
	zpty -t $worker &>/dev/null && return

	typeset -gA ASYNC_PTYS
	typeset -h REPLY
	typeset has_xtrace=0

	if [[ -o interactive ]] && [[ -o zle ]]; then
		# Tell the worker to ignore -n; we use a ZLE watcher instead.
		args+=(-z)

		if (( ! ASYNC_ZPTY_RETURNS_FD )); then
			# Older zsh: zpty returns no fd, so we guess by opening+closing
			# a new fd above 10 and assuming zpty reuses it.
			integer -l zptyfd
			exec {zptyfd}>&1
			exec {zptyfd}>&-
		fi
	fi

	# Workaround for stderr in the main shell being reassigned to /dev/null
	# by the reassignment inside the worker. See zsh-async issue #35.
	integer errfd=-1

	# errfd redirect is broken on zsh 5.0.2.
	if is-at-least 5.0.8; then
		exec {errfd}>&2
	fi

	# xtrace output interferes with the worker.
	[[ -o xtrace ]] && {
		has_xtrace=1
		unsetopt xtrace
	}

	if (( errfd != -1 )); then
		zpty -b $worker _async_worker -p $$ $args 2>&$errfd
	else
		zpty -b $worker _async_worker -p $$ $args
	fi
	local ret=$?

	(( has_xtrace )) && setopt xtrace
	(( errfd != -1 )) && exec {errfd}>& -

	if (( ret )); then
		async_stop_worker $worker
		return 1
	fi

	if ! is-at-least 5.0.8; then
		# Pre-5.0.8: wait for the worker to be ready before sending commands.
		sleep 0.001
	fi

	if [[ -o interactive ]] && [[ -o zle ]]; then
		if (( ! ASYNC_ZPTY_RETURNS_FD )); then
			REPLY=$zptyfd
		fi

		ASYNC_PTYS[$REPLY]=$worker
	fi
}

# async_stop_worker <worker>...
#   Stops workers; unfetched and incomplete work is lost.
async_stop_worker() {
	setopt localoptions noshwordsplit

	local ret=0 worker k v
	for worker in $@; do
		for k v in ${(@kv)ASYNC_PTYS}; do
			if [[ $v == $worker ]]; then
				zle -F $k
				unset "ASYNC_PTYS[$k]"
			fi
		done
		async_unregister_callback $worker
		zpty -d $worker 2>/dev/null || ret=$?

		typeset -gA ASYNC_PROCESS_BUFFER
		unset "ASYNC_PROCESS_BUFFER[$worker]"
	done

	return $ret
}

async_init() {
	(( ASYNC_INIT_DONE )) && return
	typeset -g ASYNC_INIT_DONE=1

	zmodload zsh/zpty
	zmodload zsh/datetime

	autoload -Uz is-at-least

	# Detect whether zsh/zpty returns an fd (requires interactive zle).
	typeset -g ASYNC_ZPTY_RETURNS_FD=0
	[[ -o interactive ]] && [[ -o zle ]] && {
		typeset -h REPLY
		zpty _async_test :
		(( REPLY )) && ASYNC_ZPTY_RETURNS_FD=1
		zpty -d _async_test
	}
}

async() {
	async_init
}

async "$@"
