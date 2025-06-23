{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
in {
  options.modules.server.sshd = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable SSH server.";
      type = types.bool;
    };
  };

  config = mkIf cfg.sshd.enable {
    users.users."${user}".openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZVcY+kkbEtIiYjSyIMeIJNZjUpK+kgpMQEIOqtG5GIkTV5rb9DOoruAYy1/2HPpAaDUl7ISorBc4g0v/98cEaF04PIOWpm+HctLhPNyI0f7TClQIFNU8PLO5bMzAvIdJQmJavd42cVZmz44N8C12nL3mzCIaLGsVW/iAc2H2viHoOT3ZYxhq1f0kaDhLYjaserNgLqX12E3q5f3z1HkAg2ivRt5NHs4t4N5L6dqS/GnLAaK9rT1yCuIPQT4+XvKycaos/dMLWSPzz3ROV9mATg2uzQx9DiQd7s0pQ4UjUNL/XHlVj0TnQAS6fioVlkfb6dAxzIm9D+O4NI6b2m23Jo2XXoChKkRtVbBX/bJH8YZS2QdIlwlm57yyEbipCFjha8/GH2LUSqEkAZpbDFkIl77aSDX/D+l5svXIZke3PUmL9VX31UglP6/1hqFjMNvZHMbf+bjpjw2UILPph3QogMw8LeSfndFDDtkCDuP25MyjWi4h2QGVc8ibtQnDu3Lj8HhdQ2dOXPuHgMnty9YZXWfGaStIIsS26ZiXbkvRG5e8rlIXQbz8V1aS9851ODOeoXAU87aAG8MKiWJgtrcJRtBcZJHTZHk/I/fSKsyARWz8xtfrIOsCLSWWiY0lpCUYTCrZ4uh9jFEkYda9S8efh7QmOLXraqn6Gw+psKiU9Fw=="
    ];

    services.openssh = {
      enable = true;
    } // helpers.linuxAttrs {
      openFirewall = mkDefault (!config.modules.router.enable);
    };
  };
}
