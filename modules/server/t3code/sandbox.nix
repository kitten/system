inputs:
{ home }:

import ../../../lib/mk-nono-sandbox.nix inputs {
  name = "t3code";
  # Disable Chromium's inner sandbox under Seatbelt.
  env.PLAYWRIGHT_MCP_SANDBOX = "false";
  profile = {
    allow_parent_of_protected = true;
    # The default group grants /System/Volumes, including every user's home.
    groups.exclude = [ "system_read_macos" ];
    security = {
      signal_mode = "allow_all";
      process_info_mode = "allow_all";
      ipc_mode = "full";
    };
    filesystem = {
      allow = [ home ];
      read = [
        "/bin"
        "/sbin"
        "/usr/bin"
        "/usr/sbin"
        "/usr/lib"
        "/usr/libexec"
        "/usr/share"
        "/dev"
        "/etc"
        "/run"
        "/System/Library"
        "/System/Cryptexes"
        "/Library"
        "/Applications"
        "/private"
        "/opt"
        "/cores"
        "/nix"
      ];
      bypass_protection = [
        "/nix/store"
        "${home}/Library/Keychains"
      ];
      unix_socket_subtree_bind = [ home "$TMPDIR" ];
    };
    network.block = false;
    unsafe_macos_seatbelt_rules = [
      # Browser subprocesses need Mach service registration.
      ''(allow mach-register (global-name-prefix "org.chromium.Chromium.MachPortRendezvousServer."))''
      ''(allow mach-register (global-name-prefix "com.google.Chrome.MachPortRendezvousServer."))''
      ''(allow mach-register (global-name-prefix "com.google.chrome.for.testing.MachPortRendezvousServer."))''
      ''(allow mach-register (global-name-prefix "org.mozilla.machname."))''
      # OpenSSH host-key updates.
      ''(allow file-read-data file-write-data file-write-create (literal "${home}/.ssh/known_hosts"))''
      # IOKit access for developer tools and Simulator.
      "(allow iokit-open)"
      # Expo's Simulator and DeviceHub integration.
      "(allow lsopen)"
      ''(allow appleevent-send (appleevent-destination "com.apple.systemevents"))''
      # macOS's setuid ps cannot inherit Seatbelt; keep this exception path-specific.
      ''(allow process-exec (literal "/bin/ps") (with no-sandbox))''
    ];
  };
}
