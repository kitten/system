{ ... }:

{
  services.ntp = {
    enable = true;
    extraConfig = ''
      interface listen lo
      interface listen intern0
      interface ignore extern0
    '';
  };
}
