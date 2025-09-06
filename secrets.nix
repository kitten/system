let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2TB8awz+vq4oPbzztPLBBRKjgu1LvNoTBLVLgTbBmT"
  ];
in
{
  "./modules/base/encrypt/nix-access-tokens.conf.age".publicKeys = keys;

  "./modules/server/encrypt/tailscale.age".publicKeys = keys;
  "./modules/server/encrypt/rclone.conf.age".publicKeys = keys;
  "./modules/server/encrypt/tangled-knot-ssh.age".publicKeys = keys;

  "./home/fonts/encrypt/DankMono-Regular.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/DankMono-Bold.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/DankMono-Italic.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/codicon.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/faicon.ttf.age".publicKeys = keys;

  "./home/base/encrypt/147CBD801C5E0D0C27DD006653D3D96FF952F652.key.age".publicKeys = keys;
  "./home/base/encrypt/DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5.key.age".publicKeys = keys;
  "./home/base/encrypt/F6BECEF8FA360886C588883F90AD03CBE7B6450A.key.age".publicKeys = keys;

  "./home/development/encrypt/npmrc.age".publicKeys = keys;

  "./modules/automation/certs/mqtt.key.age".publicKeys = keys;
  "./modules/automation/certs/mqtt.crt.age".publicKeys = keys;

  "./modules/games/palworld/encrypt/palworld-passwd.age".publicKeys = keys;
}
