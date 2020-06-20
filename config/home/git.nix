{
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
      lol = "log --oneline";
      recommit = "commit -a --amend --no-edit";
      pushf = "push --force-with-lease";
      glog = "log --oneline --decorate --all --graph";
    };

    delta = {
      enable = true;
      options = [
        "--tabs=2"
        "--theme=base16"
      ];
    };

    extraConfig = {
      status.showUntrackedFiles = "all";
      push.default = "simple";
      color.ui = "auto";
      pull.rebase = true;
      fetch.prune = true;
      diff.tool = "vimdiff";
      diff.sunmodule = "log";
      diff.compactionHeuristic = true;
      merge.ff = "only";
      merge.tool = "vimdiff";
      difftool.prompt = false;
      mergetool.prompt = true;
      "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
    };
  };
}
