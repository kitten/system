self: super: {
  fetchSteam = import ./fetch-steam.nix self super;
  mkSteamPackage = import ./mk-steam-package.nix self super;
  mkSteamWrapper = import ./mk-steam-wrapper.nix self super;
  systemd-transparent-udp-forwarderd = import ./systemd-transparent-udp-forwarderd.nix self super;
  force-bind = import ./force-bind-seccomp.nix self super;
  steamworks-sdk-redist = import ./steamworks-sdk-redist.nix self super;
  palworld-server = import ./palworld-server.nix self super;
}
