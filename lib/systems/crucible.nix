{ pkgs, ... }: 
let
  portMapping = {
    cgit = 10001;
  };
in
{
  imports = [
    ./crucible-hardware.nix
    ../modules/cgit.nix
  ];

  nixpkgs.overlays = [
    (super: self: { h2o = super.callPackage ../packages/h2o {}; })
    (super: self: { cgit-server = super.callPackage ../packages/cgit-server {}; })
    (super: self: { logo = super.callPackage ../packages/logo {}; })
  ];

  system.stateVersion = "23.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    openssh.enable = true;
    cgit = {
      enable = true;
      port = portMapping.cgit;
      logo = builtins.elemAt pkgs.logo 1;
    };
    nginx = {
      enable = true;
      virtualHosts."git.ctsk.dev" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:10001/";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  programs.mosh.enable = true;

  users.users = {
    christian = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [ vim git cgit-server ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/6lhq/GRRlWRqBQaw/XJ8GVFLHyR+uM0p0KKJ3JQN9qufArGzfVPMMlTGGqZ2DA8P25tv96Ac9Wc0yOHXzQkO7PnFKqV8jh9imDJHec8I5v9HFMpsPCmg++4/COZyc5sUwG1l/UAdxj1H78i1MsYSri0NM3nVt9igicxfbOSdE48VtCasrEh6+oItiLCNfpSr8KgdbFp+MHDlL5Z/fik0xm1CN/41Cnjb7q6pAigwV/5CNBEkbAYKh5ALFNzHeWCa0t5Xg+ap6PRR1jHhWMuJ5jfV+0CXcQciL4Oaxsv/CPdkqgg21LKlnSvw4j8/RXBgEXMvkJdIlCtFbraHoUOSIkDd6ivFqRL15nBFoza3ZPHQez6vEmehY0B0WIW089W2o0nym6tb5fwKQCeX2fbA06TiyOmXU/aaMtN620OJPaSu7K840vluiAqyZA6pqIzcDDYkOPFISWR0ALaFwWxDwthYK3FyBRRe0Ob6z93N4+PXc3sHmSjgRI1E4g7Lotc= christian@labyrinth"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDGkL+t/CJG3r/Tao0IjJr5VyiyzqqohK7+C9RFEqVbGoBiJ/1itbHmZCwEVYPiQSVfTTMf+qmtlaJYAblVF1T/O0FxXsxTMJbpxF6zSsHMzSMpICVSFoXSuFzuSEtFq7O/L22tKwPW7c3jUWNebfm3sObhZcMNtqKhvcL0MpWgW7XDzcq0Lu8+AjVG92C3RVVxnKC8kic2Smz1B4QthLA7oH50Pdb1PyWL4eR4jIEsXeCnMOIfIyxPYoisuXWuKy1zrk/hKBIkxTBT2t3nxaUAcrNfHS/Yv0EQdj+L8dqsEqIi2oX+SFWeDV7x4bDJVDhDn+TJ/9n7BCs01DWnuDispQDmZsmn59K0QX8EojQnrZ5D7weNu45b6s+XNDvnSpZ/jFCf24JwfBp7OINwmSsN1Sh65ThXt5naelLd+ulQ2bddqKhPwAlDK2R1zEro0qzta8UjJzCK90AD9V9c5t8TMnDrBcbbbBgamWcCML0dsxTM2Hib/e1XAyTL34AAH0= christian@labyrinth"
      ];
    };
  };

  nix.settings = {
    trusted-users = [ "@wheel" ];
    require-sigs = false;
  };

  security = {
    sudo.wheelNeedsPassword = false;
    acme = {
      acceptTerms = true;
      defaults.email = "me@ctsk.xyz";
    };
  };
}
