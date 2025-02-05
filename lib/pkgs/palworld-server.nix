self: {
  lib,
  ...
}:

with lib;
self.mkSteamPackage {
  name = "palworld-server";
  version = "17082920";
  appId = "2394010";
  depotId = "2394012";
  manifestId = "2423583208459052375";
  hash = "sha256-gAFEDf/rKPQ5zTH8EJ93e4KKHUGi8uiYlPS7G2lWGWk=";
  meta = {
    description = "Palworld Dedicated Server";
    homepage = "https://steamdb.info/app/2394010/";
    changelog = "https://store.steampowered.com/news/app/1623730?updates=true";
    sourceProvenance = with sourceTypes; [ sourceTypes.binaryNativeCode ];
  };
}
