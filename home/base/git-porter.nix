{ config, options, lib, inputs, user, ... }:

let
  cfg = config.programs.git-porter;
  isAgent = config.modules.agent.enable or false;
in {
  imports = [ inputs.git-porter.homeManagerModules.default ];

  options.programs.git-porter.seedFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = null;
    description = "Agenix-encrypted stable Porter wrapped publication key for the operator account. Change only for explicit credential rotation.";
  };

  config = {
    xdg.dataFile = lib.mkIf (cfg.enable && !isAgent) {
      "git-porter/publication.pub".source = ./assets/git-porter/publication.pub;
      "git-porter/publication.source.pub".source = ./assets/git-porter/publication.source.pub;
    };

    programs.git-porter = {
      seedFile = lib.mkIf (!isAgent) ../development/encrypt/git-publication.age;
      sender.destination = "${user}@localhost";
      searchRoot = [ config.modules.git.directory ];
      receiver = {
        searchStrict = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJffcTjACQ0XJLO7iv16MVgM783KAn1q1LsaIT/kWqNn phil+agent@kitten.sh"
        ];
        allowedPushPrefixes = [ "@kitten/" "@kitten-agent/" ];
        publishTo = [ "github.com" ];
      };
    };
  } // lib.optionalAttrs (options ? age.secrets) {
    age.secrets.git-porter-seed = lib.mkIf (cfg.enable && !isAgent && cfg.seedFile != null) {
      file = cfg.seedFile;
      path = "${config.xdg.dataHome}/git-porter/publication.wrapped";
      symlink = true;
      mode = "0400";
    };
  };
}
