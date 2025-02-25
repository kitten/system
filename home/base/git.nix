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
    home.packages = with pkgs; [ git-crypt git-get ];

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

        gitget = {
          root = "${home}/git";
          host = "github.com";
          skip-host = true;
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
  };
}
