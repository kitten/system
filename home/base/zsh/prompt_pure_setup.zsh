# Pure by Sindre Sorhus — https://github.com/sindresorhus/pure — MIT License
# Forked: color palette restricted to ANSI 0-15.

prompt_pure_human_time_to_var() {
	local human total_seconds=$1 var=$2
	local days=$(( total_seconds / 60 / 60 / 24 ))
	local hours=$(( total_seconds / 60 / 60 % 24 ))
	local minutes=$(( total_seconds / 60 % 60 ))
	local seconds=$(( total_seconds % 60 ))
	(( days > 0 )) && human+="${days}d "
	(( hours > 0 )) && human+="${hours}h "
	(( minutes > 0 )) && human+="${minutes}m "
	human+="${seconds}s"

	typeset -g "${var}"="${human}"
}

prompt_pure_check_cmd_exec_time() {
	integer elapsed
	(( elapsed = EPOCHSECONDS - ${prompt_pure_cmd_timestamp:-$EPOCHSECONDS} ))
	typeset -g prompt_pure_cmd_exec_time=
	(( elapsed > ${PURE_CMD_MAX_EXEC_TIME:-5} )) && {
		prompt_pure_human_time_to_var $elapsed "prompt_pure_cmd_exec_time"
	}
}

prompt_pure_set_title() {
	setopt localoptions noshwordsplit

	# Emacs terminal does not support settings the title.
	(( ${+EMACS} || ${+INSIDE_EMACS} )) && return

	case $TTY in
		# Don't set title over serial console.
		/dev/ttyS[0-9]*) return;;
	esac

	local hostname=
	if [[ -n $prompt_pure_state[username] ]]; then
		# Expand in-place in case ignore-escape is used.
		hostname="${(%):-(%m) }"
	fi

	local -a opts
	case $1 in
		expand-prompt) opts=(-P);;
		ignore-escape) opts=(-r);;
	esac

	# Set title atomically in one print statement so that it works when XTRACE is enabled.
	print -n $opts $'\e]0;'${hostname}${2}$'\a'
}

prompt_pure_preexec() {
	if [[ -n $prompt_pure_git_fetch_pattern ]]; then
		local -H MATCH MBEGIN MEND match mbegin mend
		if [[ $2 =~ (git|hub)\ (.*\ )?($prompt_pure_git_fetch_pattern)(\ .*)?$ ]]; then
			# Flush async jobs to cancel our git fetch and avoid conflicts
			# with the user's pull/fetch.
			async_flush_jobs 'prompt_pure'
		fi
	fi

	typeset -g prompt_pure_cmd_timestamp=$EPOCHSECONDS

	prompt_pure_set_title 'ignore-escape' "$PWD:t: $2"

	# Disallow Python virtualenv from updating the prompt; the magic number
	# 20 (same as in psvar) signals Pure modified it.
	export VIRTUAL_ENV_DISABLE_PROMPT=${VIRTUAL_ENV_DISABLE_PROMPT:-20}
}

prompt_pure_set_colors() {
	local color_temp key value
	for key value in ${(kv)prompt_pure_colors}; do
		zstyle -t ":prompt:pure:$key" color "$value"
		case $? in
			1) zstyle -s ":prompt:pure:$key" color color_temp
			   prompt_pure_colors[$key]=$color_temp ;;
			2) prompt_pure_colors[$key]=$prompt_pure_colors_default[$key] ;;
		esac
	done
}

prompt_pure_preprompt_render() {
	setopt localoptions noshwordsplit

	unset prompt_pure_async_render_requested

	typeset -g prompt_pure_git_branch_color=$prompt_pure_colors[git:branch]
	[[ -n ${prompt_pure_git_last_dirty_check_timestamp+x} ]] && prompt_pure_git_branch_color=$prompt_pure_colors[git:branch:cached]

	# psvar[12-20] drive the PROMPT %(NV..) conditionals — see prompt_pure_setup.
	psvar[12]=
	((${(M)#jobstates:#suspended:*} != 0)) && psvar[12]=${PURE_SUSPENDED_JOBS_SYMBOL:-✦}
	psvar[13]=
	[[ -n $prompt_pure_state[username] ]] && psvar[13]=1
	psvar[14]=${prompt_pure_vcs_info[branch]}
	psvar[15]=${prompt_pure_git_dirty}
	psvar[16]=${prompt_pure_vcs_info[action]}
	psvar[17]=${prompt_pure_git_arrows}
	psvar[18]=
	[[ -n $prompt_pure_git_stash ]] && psvar[18]=1
	psvar[19]=${prompt_pure_cmd_exec_time}

	local expanded_prompt
	expanded_prompt="${(S%%)PROMPT}"

	if [[ $1 == precmd ]]; then
		print
	elif [[ $prompt_pure_last_prompt != $expanded_prompt ]]; then
		prompt_pure_reset_prompt
	fi

	typeset -g prompt_pure_last_prompt=$expanded_prompt
}

prompt_pure_precmd() {
	setopt localoptions noshwordsplit

	prompt_pure_check_cmd_exec_time
	unset prompt_pure_cmd_timestamp

	prompt_pure_set_title 'expand-prompt' '%~'
	prompt_pure_set_colors
	prompt_pure_async_tasks

	psvar[20]=
	if [[ -n $CONDA_DEFAULT_ENV ]]; then
		psvar[20]="${CONDA_DEFAULT_ENV//[$'\t\r\n']}"
	fi
	# Empty VIRTUAL_ENV_DISABLE_PROMPT means the user unset it; Pure resumes.
	if [[ -n $VIRTUAL_ENV ]] && [[ -z $VIRTUAL_ENV_DISABLE_PROMPT || $VIRTUAL_ENV_DISABLE_PROMPT = 20 ]]; then
		if [[ -n $VIRTUAL_ENV_PROMPT ]]; then
			psvar[20]="${VIRTUAL_ENV_PROMPT}"
		else
			psvar[20]="${VIRTUAL_ENV:t}"
		fi
		export VIRTUAL_ENV_DISABLE_PROMPT=20
	fi

	if zstyle -T ":prompt:pure:environment:nix-shell" show; then
		if [[ -n $IN_NIX_SHELL ]]; then
			psvar[20]="${name:-nix-shell}"
		fi
	fi

	prompt_pure_reset_prompt_symbol
	prompt_pure_preprompt_render "precmd"

	if [[ -n $ZSH_THEME ]]; then
		print "WARNING: Oh My Zsh themes are enabled (ZSH_THEME='${ZSH_THEME}'). Pure might not be working correctly."
		print "For more information, see: https://github.com/sindresorhus/pure#oh-my-zsh"
		unset ZSH_THEME
	fi
}

prompt_pure_async_git_aliases() {
	setopt localoptions noshwordsplit
	local -a gitalias pullalias

	gitalias=(${(@f)"$(command git config --get-regexp "^alias\.")"})
	for line in $gitalias; do
		parts=(${(@)=line})
		aliasname=${parts[1]#alias.}
		shift parts

		if [[ $parts =~ ^(.*\ )?(pull|fetch)(\ .*)?$ ]]; then
			pullalias+=($aliasname)
		fi
	done

	print -- ${(j:|:)pullalias}
}

prompt_pure_async_vcs_info() {
	setopt localoptions noshwordsplit

	# Configure vcs_info inside an async task so it doesn't interfere with
	# the user's own vcs_info usage.
	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' use-simple true
	zstyle ':vcs_info:*' max-exports 3
	# %b = branch, %R = toplevel, %a = action (rebase/cherry-pick)
	zstyle ':vcs_info:git*' formats '%b' '%R' '%a'
	zstyle ':vcs_info:git*' actionformats '%b' '%R' '%a'

	vcs_info

	local -A info
	info[pwd]=$PWD
	info[branch]=${vcs_info_msg_0_//\%/%%}
	info[top]=$vcs_info_msg_1_
	info[action]=$vcs_info_msg_2_

	print -r - ${(@kvq)info}
}

prompt_pure_async_git_dirty() {
	setopt localoptions noshwordsplit
	local untracked_dirty=$1
	local untracked_git_mode=$(command git config --get status.showUntrackedFiles)
	if [[ "$untracked_git_mode" != 'no' ]]; then
		untracked_git_mode='normal'
	fi

	# Prevent e.g. `git status` from refreshing the index as a side effect.
	export GIT_OPTIONAL_LOCKS=0

	if [[ $untracked_dirty = 0 ]]; then
		command git diff --no-ext-diff --quiet --exit-code
	else
		test -z "$(command git status --porcelain -u${untracked_git_mode})"
	fi

	return $?
}

prompt_pure_async_git_fetch() {
	setopt localoptions noshwordsplit

	local only_upstream=${1:-0}

	# Disable Git auth prompts (Git 2.3+) and interactive SSH password prompts.
	export GIT_TERMINAL_PROMPT=0
	export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-"ssh"} -o BatchMode=yes"

	# Empty GPG_TTY forces pinentry-curses to close immediately rather than
	# stall waiting for input, in case gpg-agent handles SSH keys for fetch.
	export GPG_TTY=

	local -a remote
	if ((only_upstream)); then
		local ref
		ref=$(command git symbolic-ref -q HEAD)
		remote=($(command git for-each-ref --format='%(upstream:remotename) %(refname)' $ref))
		if [[ -z $remote[1] ]]; then
			return 97
		fi
	fi

	local fail_code=99

	# MONITOR mode lets us detect a child suspended on a password prompt.
	# Inside an async worker we can't transmit input, so we kill it instead.
	setopt localtraps monitor
	# Unset HUP so signal propagation works when the worker is flushed.
	trap - HUP

	trap '
		trap - CHLD
		if [[ $jobstates = suspended* ]]; then
			fail_code=98
			kill %%
		fi
	' CHLD

	command git -c gc.auto=0 fetch \
		--quiet \
		--no-tags \
		--no-prune-tags \
		--recurse-submodules=no \
		$remote &>/dev/null &
	wait $! || return $fail_code

	unsetopt monitor

	prompt_pure_async_git_arrows
}

prompt_pure_async_git_arrows() {
	setopt localoptions noshwordsplit
	command git rev-list --left-right --count HEAD...@'{u}'
}

prompt_pure_async_git_stash() {
	git rev-list --walk-reflogs --count refs/stash
}

# Lower worker priority so disk-heavy ops like `git status` don't hurt responsiveness.
prompt_pure_async_renice() {
	setopt localoptions noshwordsplit

	if command -v renice >/dev/null; then
		command renice +15 -p $$
	fi

	if command -v ionice >/dev/null; then
		command ionice -c 3 -p $$
	fi
}

prompt_pure_async_init() {
	typeset -g prompt_pure_async_inited
	if ((${prompt_pure_async_inited:-0})); then
		return
	fi
	prompt_pure_async_inited=1
	async_start_worker "prompt_pure" -u -n
	async_register_callback "prompt_pure" prompt_pure_async_callback
	async_worker_eval "prompt_pure" prompt_pure_async_renice
}

prompt_pure_async_tasks() {
	setopt localoptions noshwordsplit

	prompt_pure_async_init
	async_worker_eval "prompt_pure" builtin cd -q $PWD

	typeset -gA prompt_pure_vcs_info

	local -H MATCH MBEGIN MEND
	if [[ $PWD != ${prompt_pure_vcs_info[pwd]}* ]]; then
		# Switching working tree — reset Git preprompt state.
		async_flush_jobs "prompt_pure"
		unset prompt_pure_git_dirty
		unset prompt_pure_git_last_dirty_check_timestamp
		unset prompt_pure_git_arrows
		unset prompt_pure_git_stash
		unset prompt_pure_git_fetch_pattern
		prompt_pure_vcs_info[branch]=
		prompt_pure_vcs_info[top]=
	fi
	unset MATCH MBEGIN MEND

	async_job "prompt_pure" prompt_pure_async_vcs_info

	[[ -n $prompt_pure_vcs_info[top] ]] || return

	prompt_pure_async_refresh
}

prompt_pure_async_refresh() {
	setopt localoptions noshwordsplit

	if [[ -z $prompt_pure_git_fetch_pattern ]]; then
		# Avoid redoing the pattern check until the working tree changes.
		typeset -g prompt_pure_git_fetch_pattern="pull|fetch"
		async_job "prompt_pure" prompt_pure_async_git_aliases
	fi

	async_job "prompt_pure" prompt_pure_async_git_arrows

	if (( ${PURE_GIT_PULL:-1} )) && [[ $prompt_pure_vcs_info[top] != $HOME ]]; then
		zstyle -t :prompt:pure:git:fetch only_upstream
		local only_upstream=$((? == 0))
		async_job "prompt_pure" prompt_pure_async_git_fetch $only_upstream
	fi

	integer time_since_last_dirty_check=$(( EPOCHSECONDS - ${prompt_pure_git_last_dirty_check_timestamp:-0} ))
	if (( time_since_last_dirty_check > ${PURE_GIT_DELAY_DIRTY_CHECK:-1800} )); then
		unset prompt_pure_git_last_dirty_check_timestamp
		async_job "prompt_pure" prompt_pure_async_git_dirty ${PURE_GIT_UNTRACKED_DIRTY:-1}
	fi

	if zstyle -t ":prompt:pure:git:stash" show; then
		async_job "prompt_pure" prompt_pure_async_git_stash
	else
		unset prompt_pure_git_stash
	fi
}

prompt_pure_check_git_arrows() {
	setopt localoptions noshwordsplit
	local arrows left=${1:-0} right=${2:-0}

	(( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-⇣}
	(( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-⇡}

	[[ -n $arrows ]] || return
	typeset -g REPLY=$arrows
}

prompt_pure_async_callback() {
	setopt localoptions noshwordsplit
	local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
	local do_render=0

	case $job in
		\[async])
			# Exit codes 2/3/130 indicate a crashed async worker — recover.
			if (( code == 2 )) || (( code == 3 )) || (( code == 130 )); then
				typeset -g prompt_pure_async_inited=0
				async_stop_worker prompt_pure
				prompt_pure_async_init
				prompt_pure_async_tasks

				unset prompt_pure_async_render_requested
			fi
			;;
		\[async/eval])
			if (( code )); then
				# async_worker_eval failed; rerun tasks defensively.
				prompt_pure_async_tasks
			fi
			;;
		prompt_pure_async_vcs_info)
			local -A info
			typeset -gA prompt_pure_vcs_info

			# (z) splits output, (Q@) unquotes back to an array.
			info=("${(Q@)${(z)output}}")
			local -H MATCH MBEGIN MEND
			if [[ $info[pwd] != $PWD ]]; then
				return
			fi
			if [[ $info[top] = $prompt_pure_vcs_info[top] ]]; then
				# Stored pwd is part of $PWD: $PWD is shorter and likelier
				# to be top-level, so prefer it.
				if [[ $prompt_pure_vcs_info[pwd] = ${PWD}* ]]; then
					prompt_pure_vcs_info[pwd]=$PWD
				fi
			else
				# Store $PWD to detect if we (maybe) left the Git path.
				prompt_pure_vcs_info[pwd]=$PWD
			fi
			unset MATCH MBEGIN MEND

			# Just entered a new Git directory — kick off refresh tasks.
			[[ -n $info[top] ]] && [[ -z $prompt_pure_vcs_info[top] ]] && prompt_pure_async_refresh

			prompt_pure_vcs_info[branch]=$info[branch]
			prompt_pure_vcs_info[top]=$info[top]
			prompt_pure_vcs_info[action]=$info[action]

			do_render=1
			;;
		prompt_pure_async_git_aliases)
			if [[ -n $output ]]; then
				prompt_pure_git_fetch_pattern+="|$output"
			fi
			;;
		prompt_pure_async_git_dirty)
			local prev_dirty=$prompt_pure_git_dirty
			if (( code == 0 )); then
				unset prompt_pure_git_dirty
			else
				typeset -g prompt_pure_git_dirty="*"
			fi

			[[ $prev_dirty != $prompt_pure_git_dirty ]] && do_render=1

			# Setting last_dirty_check_timestamp switches the branch color to
			# "cached". Render before setting so the color change shows on the
			# *next* render, distinguishing fresh from cached results.
			(( $exec_time > 5 )) && prompt_pure_git_last_dirty_check_timestamp=$EPOCHSECONDS
			;;
		prompt_pure_async_git_fetch|prompt_pure_async_git_arrows)
			# git_fetch runs git_arrows on success, hence the shared handler.
			case $code in
				0)
					local REPLY
					prompt_pure_check_git_arrows ${(ps:\t:)output}
					if [[ $prompt_pure_git_arrows != $REPLY ]]; then
						typeset -g prompt_pure_git_arrows=$REPLY
						do_render=1
					fi
					;;
				97)
					# No remote — clear arrows.
					if [[ -n $prompt_pure_git_arrows ]]; then
						typeset -g prompt_pure_git_arrows=
						do_render=1
					fi
					;;
				99|98)
					;;
				*)
					# Non-zero from git_arrows — no upstream configured.
					if [[ -n $prompt_pure_git_arrows ]]; then
						unset prompt_pure_git_arrows
						do_render=1
					fi
					;;
			esac
			;;
		prompt_pure_async_git_stash)
			local prev_stash=$prompt_pure_git_stash
			typeset -g prompt_pure_git_stash=$output
			[[ $prev_stash != $prompt_pure_git_stash ]] && do_render=1
			;;
	esac

	if (( next_pending )); then
		(( do_render )) && typeset -g prompt_pure_async_render_requested=1
		return
	fi

	[[ ${prompt_pure_async_render_requested:-$do_render} = 1 ]] && prompt_pure_preprompt_render
	unset prompt_pure_async_render_requested
}

prompt_pure_reset_prompt() {
	if [[ $CONTEXT == cont ]]; then
		# PS2 is active: reset-prompt would clobber PS2's %_ execution
		# context, and we can't save/restore %_ (only expands in-prompt).
		return
	fi

	zle && zle .reset-prompt
}

prompt_pure_reset_prompt_symbol() {
	prompt_pure_state[prompt]=${PURE_PROMPT_SYMBOL:-❯}
}

prompt_pure_update_vim_prompt_widget() {
	setopt localoptions noshwordsplit
	prompt_pure_state[prompt]=${${KEYMAP/vicmd/${PURE_PROMPT_VICMD_SYMBOL:-❮}}/(main|viins)/${PURE_PROMPT_SYMBOL:-❯}}

	prompt_pure_reset_prompt
}

prompt_pure_reset_vim_prompt_widget() {
	setopt localoptions noshwordsplit
	prompt_pure_reset_prompt_symbol

	# Can't reset-prompt here: would strip macOS Terminal's prompt marks.
}

prompt_pure_state_setup() {
	setopt localoptions noshwordsplit

	local ssh_connection=${SSH_CONNECTION:-$PROMPT_PURE_SSH_CONNECTION}
	local username hostname
	if [[ -z $ssh_connection ]] && (( $+commands[who] )); then
		# SSH_CONNECTION can be lost on `su`/`sudo -i` — try to recover via `who`.
		local who_out
		who_out=$(who -m 2>/dev/null)
		if (( $? )); then
			# `who -m` not supported (e.g. busybox); fall back to plain who.
			local -a who_in
			who_in=( ${(f)"$(who 2>/dev/null)"} )
			who_out="${(M)who_in:#*[[:space:]]${TTY#/dev/}[[:space:]]*}"
		fi

		local reIPv6='(([0-9a-fA-F]+:)|:){2,}[0-9a-fA-F]+'
		local reIPv4='([0-9]{1,3}\.){3}[0-9]+'
		# Two non-consecutive periods = hostname (matches foo.bar.baz, not foo.bar).
		local reHostname='([.][^. ]+){2}'

		# Address is usually parenthesised but not on all systems (e.g. busybox).
		local -H MATCH MBEGIN MEND
		if [[ $who_out =~ "\(?($reIPv4|$reIPv6|$reHostname)\)?\$" ]]; then
			ssh_connection=$MATCH

			# Propagate detection into spawned shells — tmux doesn't always
			# inherit the same tty, which breaks redetection.
			export PROMPT_PURE_SSH_CONNECTION=$ssh_connection
		fi
		unset MATCH MBEGIN MEND
	fi

	hostname='%F{$prompt_pure_colors[host]}@%m%f'
	[[ -n $ssh_connection ]] && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname"
	[[ -z "${CODESPACES}" ]] && prompt_pure_is_inside_container && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname"
	[[ $UID -eq 0 ]] && username='%F{$prompt_pure_colors[user:root]}%n%f'"$hostname"

	typeset -gA prompt_pure_state
	prompt_pure_state[version]="1.27.0"
	prompt_pure_state+=(
		username "$username"
		prompt	 "${PURE_PROMPT_SYMBOL:-❯}"
	)
}

prompt_pure_is_inside_container() {
	local -r nspawn_file='/run/host/container-manager'
	local -r podman_crio_file='/run/.containerenv'
	local -r docker_file='/.dockerenv'
	local -r k8s_token_file='/var/run/secrets/kubernetes.io/serviceaccount/token'
	local -r cgroup_file='/proc/1/cgroup'
	[[ "$container" == "lxc" ]] \
		|| [[ "$container" == "oci" ]] \
		|| [[ "$container" == "podman" ]] \
		|| [[ -r "$nspawn_file" ]] \
		|| [[ -r "$podman_crio_file" ]] \
		|| [[ -r "$docker_file" ]] \
		|| [[ -r "$k8s_token_file" ]] \
		|| [[ -r "$cgroup_file" && "$(< $cgroup_file)" = *(lxc|docker|containerd)* ]]
}

prompt_pure_system_report() {
	setopt localoptions noshwordsplit

	local shell=$SHELL
	if [[ -z $shell ]]; then
		shell=$commands[zsh]
	fi
	print - "- Zsh: $($shell --version) ($shell)"
	print -n - "- Operating system: "
	case "$(uname -s)" in
		Darwin)	print "$(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))";;
		*)	print "$(uname -s) ($(uname -r) $(uname -v) $(uname -m) $(uname -o))";;
	esac
	print - "- Terminal program: ${TERM_PROGRAM:-unknown} (${TERM_PROGRAM_VERSION:-unknown})"
	print -n - "- Tmux: "
	[[ -n $TMUX ]] && print "yes" || print "no"

	local git_version
	# Splitting removes newlines (in case `hub` adds them).
	git_version=($(git --version))
	print - "- Git: $git_version"

	print - "- Pure state:"
	for k v in "${(@kv)prompt_pure_state}"; do
		print - "    - $k: \`${(q-)v}\`"
	done
	print - "- zsh-async version: \`${ASYNC_VERSION}\`"
	print - "- PROMPT: \`$(typeset -p PROMPT)\`"
	print - "- Colors: \`$(typeset -p prompt_pure_colors)\`"
	print - "- TERM: \`$(typeset -p TERM)\`"
	print - "- Virtualenv: \`$(typeset -p VIRTUAL_ENV_DISABLE_PROMPT)\`"
	print - "- Conda: \`$(typeset -p CONDA_CHANGEPS1)\`"

	local ohmyzsh=0
	typeset -la frameworks
	(( $+ANTIBODY_HOME )) && frameworks+=("Antibody")
	(( $+ADOTDIR )) && frameworks+=("Antigen")
	(( $+ANTIGEN_HS_HOME )) && frameworks+=("Antigen-hs")
	(( $+functions[upgrade_oh_my_zsh] )) && {
		ohmyzsh=1
		frameworks+=("Oh My Zsh")
	}
	(( $+ZPREZTODIR )) && frameworks+=("Prezto")
	(( $+ZPLUG_ROOT )) && frameworks+=("Zplug")
	(( $+ZPLGM )) && frameworks+=("Zplugin")

	(( $#frameworks == 0 )) && frameworks+=("None")
	print - "- Detected frameworks: ${(j:, :)frameworks}"

	if (( ohmyzsh )); then
		print - "    - Oh My Zsh:"
		print - "        - Plugins: ${(j:, :)plugins}"
	fi
}

prompt_pure_setup() {
	# Suppress the trailing `%` indicator when output lacks a newline.
	export PROMPT_EOL_MARK=''

	prompt_opts=(subst percent)

	# Borrowed from promptinit, in case Pure wasn't loaded via it.
	setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

	if [[ -z $prompt_newline ]]; then
		typeset -g prompt_newline=$'\n%{\r%}'
	fi

	zmodload zsh/datetime
	zmodload zsh/zle
	zmodload zsh/parameter
	zmodload zsh/zutil

	autoload -Uz add-zsh-hook
	autoload -Uz vcs_info
	autoload -Uz async && async

	# add-zle-hook-widget was added in Zsh 5.3 — not guaranteed.
	autoload -Uz +X add-zle-hook-widget 2>/dev/null

	typeset -gA prompt_pure_colors_default prompt_pure_colors
	# ANSI 0-15 only — defer the palette to the user's terminal theme.
	prompt_pure_colors_default=(
		execution_time       yellow
		git:arrow            cyan
		git:stash            cyan
		git:branch           15
		git:branch:cached    red
		git:action           yellow
		git:dirty            yellow
		host                 15
		path                 blue
		prompt:error         red
		prompt:success       magenta
		prompt:continuation  15
		suspended_jobs       red
		user                 15
		user:root            default
		virtualenv           15
	)
	prompt_pure_colors=("${(@kv)prompt_pure_colors_default}")

	add-zsh-hook precmd prompt_pure_precmd
	add-zsh-hook preexec prompt_pure_preexec

	prompt_pure_state_setup

	zle -N prompt_pure_reset_prompt
	zle -N prompt_pure_update_vim_prompt_widget
	zle -N prompt_pure_reset_vim_prompt_widget
	if (( $+functions[add-zle-hook-widget] )); then
		add-zle-hook-widget zle-line-finish prompt_pure_reset_vim_prompt_widget
		add-zle-hook-widget zle-keymap-select prompt_pure_update_vim_prompt_widget
	fi

	typeset -gA prompt_pure_vcs_info
	typeset -g prompt_pure_git_branch_color=$prompt_pure_colors[git:branch]

	# psvar[12-20] are updated each render in prompt_pure_preprompt_render.
	PROMPT='%(12V.%F{$prompt_pure_colors[suspended_jobs]}%12v%f .)'
	PROMPT+='%(13V.${prompt_pure_state[username]} .)'
	PROMPT+='%F{${prompt_pure_colors[path]}}%~%f'
	PROMPT+='%(14V. %F{${prompt_pure_git_branch_color}}%14v%(15V.%F{$prompt_pure_colors[git:dirty]}%15v.)%f.)'
	PROMPT+='%(16V. %F{$prompt_pure_colors[git:action]}%16v%f.)'
	PROMPT+='%(17V. %F{$prompt_pure_colors[git:arrow]}%17v%f.)'
	PROMPT+='%(18V. %F{$prompt_pure_colors[git:stash]}${PURE_GIT_STASH_SYMBOL:-≡}%f.)'
	PROMPT+='%(19V. %F{$prompt_pure_colors[execution_time]}%19v%f.)'
	PROMPT+='${prompt_newline}'
	PROMPT+='%(20V.%F{$prompt_pure_colors[virtualenv]}%20v%f .)'
	# Prompt symbol turns to the error color when the previous command failed.
	local prompt_indicator='%(?.%F{$prompt_pure_colors[prompt:success]}.%F{$prompt_pure_colors[prompt:error]})${prompt_pure_state[prompt]}%f '
	PROMPT+=$prompt_indicator

	PROMPT2='%F{$prompt_pure_colors[prompt:continuation]}… %(1_.%_ .%_)%f'$prompt_indicator

	# Stored in a variable so in-place (%) expansion below works — direct
	# inlining of the symbols silently fails to expand.
	typeset -ga prompt_pure_debug_depth
	prompt_pure_debug_depth=('%e' '%N' '%x')

	# `compare` is %N vs %x: if they differ we show both filename + function
	# (main); if they match we show just one (secondary) to avoid duplication.
	local -A ps4_parts
	ps4_parts=(
		depth 	  '%F{yellow}${(l:${(%)prompt_pure_debug_depth[1]}::+:)}%f'
		compare   '${${(%)prompt_pure_debug_depth[2]}:#${(%)prompt_pure_debug_depth[3]}}'
		main      '%F{blue}${${(%)prompt_pure_debug_depth[3]}:t}%f%F{242}:%I%f %F{242}@%f%F{blue}%N%f%F{242}:%i%f'
		secondary '%F{blue}%N%f%F{242}:%i'
		prompt 	  '%F{242}>%f '
	)
	# :+ swaps `compare` for `main` (or empty); :- then replaces empty with `secondary`.
	local ps4_symbols='${${'${ps4_parts[compare]}':+"'${ps4_parts[main]}'"}:-"'${ps4_parts[secondary]}'"}'

	PROMPT4="${ps4_parts[depth]} ${ps4_symbols}${ps4_parts[prompt]}"

	unset ZSH_THEME
	# Stop conda from rewriting PS1 — we render the env via psvar[20].
	export CONDA_CHANGEPS1=no
}

prompt_pure_setup "$@"
