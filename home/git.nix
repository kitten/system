{ pkgs, lib, ... } @ inputs:

{
  home.packages = [ pkgs.git-crypt ];

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
      pretty.longline = "tformat:%Cgreen%h %Cred%D %Creset%s %Cblue(%cd, by %an)";
      "remote \"origin\"" = {
        fetch = "+refs/pull/*/head:refs/remotes/origin/pr/*";
        pruneTags = true;
      };
    };
  };
}
