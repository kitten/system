{ ... }:

{
  services.avahi = {
    enable = true;
    allowInterfaces = [ "intern0" ];
    denyInterfaces = [ "extern0" ];
  };
}
