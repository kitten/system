{ pkgs, lib, config, ... } @ inputs:

{
  home.packages = [
    pkgs.git-crypt
    pkgs.git-get
  ];

  programs.git = {
    enable = true;
    userName = "Phil Pluckthun";
    userEmail = "phil@kitten.sh";

    signing = {
      signByDefault = true;
      key = "303B6A9A312AA035";
    };

    ignores = [
      ".DS_Store"
      "*.sw[nop]"
      "*.undodir"
      ".env"
      "*.orig"
    ];

    lfs = {
      enable = true;
    };

    aliases = {
      s = "status -s";
      last = "log -1";
      lol = "log --pretty=longline";
      recommit = "commit -a --amend --no-edit";
      pushf = "push --force-with-lease";
      glog = "log --pretty=longline --decorate --all --graph --date=relative";
      journal = "!f() { git commit -a -m \"$(date +'%Y-%m-%d %H:%M:%S')\"; }; f";
    };

    extraConfig = {
      commit.gpgSign = true;
      tag.gpgSign = true;
      push.gpgSign = "if-asked";

      color.ui = "auto";
      init.defaultBranch = "main";

      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";

      status = {
        showUntrackedFiles = "all";
        submoduleSummary = true;
      };

      diff = {
        tool = "vimdiff";
        submodule = "log";
        algorithm = "histogram";
        colorMovedWS = "allow-indentation-change";
        compactionHeuristic = true;
        context = 10;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
        followtags = true;
      };

      rebase = {
        autosquash = true;
        autostash = true;
        updateRefs = true;
        missingCommitsCheck = "error";
      };

      merge = {
        ff = "only";
        tool = "vimdiff";
        keepbackup = false;
      };

      fetch = {
        prune = true;
        prunetags = true;
      };

      gitget = {
        root = "${config.home.homeDirectory}/git";
        host = "github.com";
        skip-host = true;
      };

      core.autocrlf = false;
      pull.rebase = true;
      rerere.enabled = true;
      difftool.prompt = false;
      mergetool.prompt = true;
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckObjects = true;
      submodule.recurse = true;

      "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      pretty.longline = "tformat:%Cgreen%h %Cred%D %Creset%s %Cblue(%cd, by %an)";

      "remote \"origin\"" = {
        fetch = "+refs/pull/*/head:refs/remotes/origin/pr/*";
        pruneTags = true;
      };
    };
  };
}
