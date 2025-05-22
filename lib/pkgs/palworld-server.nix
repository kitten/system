self: {
  lib,
  ...
}:

with lib;
self.mkSteamPackage {
  name = "palworld-server";
  version = "17403768";
  appId = "2394010";
  depotId = "2394012";
  manifestId = "1367771460964183113";
  hash = "sha256-L/lRfVmc3tkMiPSPJSg6uum0/DJB97dkuPzOA3LtDEw=";
  meta = {
    description = "Palworld Dedicated Server";
    homepage = "https://steamdb.info/app/2394010/";
    changelog = "https://store.steampowered.com/news/app/1623730?updates=true";
    sourceProvenance = with sourceTypes; [ sourceTypes.binaryNativeCode ];
  };
}
