{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.git;
  home = config.home.homeDirectory;

  excludesFile = pkgs.writeTextFile {
    name = ".gitignore";
    text = ''
      # macOS: General
      .DS_Store
      .AppleDouble
      .LSOverride
      ._*

      # macOS: Files that might appear in the root of a volume
      .DocumentRevisions-V100
      .fseventsd
      .Spotlight-V100
      .TemporaryItems
      .Trashes
      .VolumeIcon.icns
      .com.apple.timemachine.donotpresent

      # Xcode
      xcuserdata/

      # Linux: hidden files
      *~
      .fuse_hidden*
      .directory
      .Trash-*
      .nfs*
    '';
  };

  userType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        example = "Sample Name";
      };
      email = mkOption {
        type = types.str;
        example = "sample@name.com";
      };
    };
  };
in {
  options.modules.git = {
    enable = mkOption {
      default = true;
      description = "Git Configuration";
      type = types.bool;
    };

    user = mkOption {
      default = {
        name = "Phil Pluckthun";
        email = "phil@kitten.sh";
      };
      description = "Git user information";
      type = userType;
    };

    signingKey = mkOption {
      description = "Git Signing key";
      type = types.nullOr types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ git-crypt ];

    programs.git = {
      enable = true;
      userName = cfg.user.name;
      userEmail = cfg.user.email;

      signing = mkIf (cfg.signingKey != null) {
        signByDefault = true;
        key = cfg.signingKey;
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
        lol = "log --pretty=longline --decorate --date=relative";
        lrel = "log --pretty=longline --pretty=longline --graph --decorate --date=relative --boundary remotes/origin/HEAD...HEAD";
        lloc = "log --pretty=longline --graph --decorate --date=relative --boundary ^remotes/origin/HEAD HEAD";
        recommit = "commit -a --amend --no-edit";
        pushf = "push --force-with-lease";
        glog = "log --pretty=longline --decorate --all --graph --date=relative";
        base = "!f() { git cherry remotes/origin/HEAD HEAD | awk '/^\\+/ {print $2;exit}'; }; f";
        journal = "!f() { git commit -a -m \"$(date +'%Y-%m-%d %H:%M:%S')\"; }; f";
        get = "!f() { git clone \"git@github.com:$1.git\" \"$HOME/git/$1\" --no-single-branch --shallow-since=\"1 year ago\"; }; f";
      };

      extraConfig = {
        commit.gpgSign = true;
        tag.gpgSign = true;
        push.gpgSign = "if-asked";

        column.ui = "auto";
        color.ui = "auto";
        init.defaultBranch = "main";
        help.autocorrect = "prompt";

        branch.sort = "-committerdate";
        tag.sort = "-version:refname";
        commit.verbose = true;

        status = {
          showUntrackedFiles = "all";
          submoduleSummary = true;
        };

        diff = {
          tool = "vimdiff";
          submodule = "log";
          algorithm = "histogram";
          colorMoved = "plain";
          colorMovedWS = "allow-indentation-change";
          mnemonicPrefix = true;
          compactionHeuristic = true;
          rename = true;
        };

        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
          atomic = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
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
          pruneTags = true;
          all = true;
        };

        rerere = {
          enabled = true;
          autoupdate = true;
        };

        core = {
          autocrlf = false;
          excludesfile = toString excludesFile;
        };

        pull.rebase = true;
        difftool.prompt = false;
        mergetool.prompt = true;
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        submodule.recurse = true;

        receive = {
          denyNonFastForwards = false;
          shallowUpdate = true;
          fsckObjects = true;
          autogc = true;
        };

        "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        pretty.longline = "tformat:%C(yellow)%h %Cred%D %Creset%<(50,mtrunc)%s %Cblue(%cd, %al)";

        "remote \"origin\"" = {
          fetch = "+refs/pull/*/merge:refs/remotes/origin/pr/*";
          partialclonefilter = "blob:none";
          tagOpt = "--no-tags";
          promisor = true;
          pruneTags = true;
        };
      };
    };
  };
}
