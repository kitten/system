{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.development.instructions;
  isAgent = config.modules.agent.enable or false;
  sharedInstructions = ''
    - Shared repos live at `~/git/<org>/<repo>`; clone with `git get <org>/<repo>`
      - Use SSH remotes
      - For forks, `origin` is the fork and `upstream` the canonical repo. The local default branch tracks `upstream/<default>`
      - After adding any remote, run `git normalize-remotes`
      - Fetch third-party PRs with `git pr <number>` (detached HEAD)
      - Send your branch to other accounts or machines with `git send [user@host|host]`
      - Receive a branch with `git receive [user@host|host]`; updates are fast-forward only. Add `--branch <name>` to select another branch
      - Check branch/status; preserve unrelated changes in shared checkouts
    - Tools come from Nix; use `nix run nixpkgs#tool -- args` for additional tools
      - Don't directly alter live configs or tooling outside ~/git unless requested
      - Use configured devshells: `nix develop -c <command>` or `direnv exec . <command>`
      - Don't assume Homebrew, nvm, or Cargo paths
      - Check installed/pinned versions; discover supported commands and flags via CLI help
      - Shells use zsh. Quote search globs
    - Follow repo instructions, package managers, scripts, and formatters; read each checkout's agent instructions before editing
      - Verify checkout dependencies before diagnosing test failures
      - Cross-repo tests: verify resolved packages and built artifacts, including native binaries; links affect resolution
      - Prefer headless/offscreen testing
      - When benchmarking, use representative workloads and the intended baseline
      - Keep changes and explanations focused. Avoid redundant docs/comments and committed temporary artifacts

    Use linn for cross-session memory. Identify the question from supplied material; before further research, search its specific behavior, decision or constraint (`linn search`). Avoid product-only queries and issue numbers. Read relevant results (`linn show`); search again as questions arise. Stop when sufficiently supported; verify time-sensitive claims against current primary sources. Consult `linn <command> --help` as needed. Save useful findings, insights and explanations across repositories, with context and sources (`linn add`). Correct outdated memories. Do not use linn as a task journal or changelog. Keep plans/tasks elsewhere and enduring docs in-repo. No need to mention linn.
  '';
  agentInstructions = ''
    Agent account:
    - Running as `${config.home.username}`; operator: `${user}`
    - Headless; don't depend on a desktop login
    - Use `git send ${user}@localhost` to send a branch to the operator's matching repo; this destination is the default. Add `--local-only` to prevent the destination from forwarding the branch to its `origin`
  '';

in {
  options.modules.development.instructions = {
    enable = mkOption {
      type = types.bool;
      default = config.modules.development.enable;
      description = "Whether to install shared personal agent instructions.";
    };

    extra = mkOption {
      type = types.lines;
      default = "";
      description = "Additional instructions for this account. Public text only; stored in the Nix store.";
    };

    text = mkOption {
      type = types.lines;
      readOnly = true;
      default = sharedInstructions
        + optionalString isAgent ("\n" + agentInstructions)
        + optionalString (cfg.extra != "") ("\n" + cfg.extra + "\n");
      description = "Shared personal instructions, including account-specific additions.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.linn ];
    home.file."${config.modules.git.directory}/AGENTS.md".text = cfg.text;
  };
}
