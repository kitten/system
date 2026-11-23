inputs:
{ home }:

import ../../../lib/mk-nono-sandbox.nix inputs {
  name = "t3code";
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
      # OpenSSH can create known_hosts on first use and append new host keys.
      ''(allow file-read-data file-write-data file-write-create (literal "${home}/.ssh/known_hosts"))''
      # IOKit access for developer tools and Simulator.
      "(allow iokit-open)"
      # Expo opens Simulator or DeviceHub and queries its process through System Events.
      "(allow lsopen)"
      ''(allow appleevent-send (appleevent-destination "com.apple.systemevents"))''
      # macOS's setuid ps cannot inherit Seatbelt; keep this exception path-specific.
      ''(allow process-exec (literal "/bin/ps") (with no-sandbox))''
    ];
  };
}
