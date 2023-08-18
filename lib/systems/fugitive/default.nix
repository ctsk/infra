{ impermanence, pkgs, ... }:
let
  portMapping = {
    cgit = 10001;
  };

  pubkeyGithost = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuTsySm/n8r33CECu5dbYC4rSbBjsgN5BBRCM9/xNSYxj7rOArPf70TsVfycnkk23bNL3uk4ns/HFg2ZeUySNxzqXALxJxBNqCGts9BX6It2s7I7VaD5EzsPDumYhrJGp/g1Abkl5O0BBZgY28iJxoMvq/EA1NgG9wvElGDX4hsg7itoJD9H3zkLO6N+EJ44g6vhYZqPHE/vZOuSw7d3JIP+ALKF00TtDHLEuW5IvqsbLhppTGurFqY9tHnK3h/znUmazWQAUEMeUazJn97bcg3UzF3poAP2Msug3gDdnv3cjXgD7dYXaqesdLGXSfBUzfE2SxhrdR52anpYCgQtQuY9hFlH2ccccaSNowjvuK//ECSAJUzbpeRNBIvpvz63cK6CakjPzDs4L6OskDLW9cxFaiPHiqtQXr6d6L2/Eql7EyPtY9y1On1DlVEkjazB0VPVHlGyDnoDZmhen56TLwOxq+ie9o8te3JWGj0/wQiiOpOf5PKzqJQpvknVS3SWU= christian@labyrinth";

in
{
  imports = [
    ./hardware.nix
    ../../modules/cgit.nix
    ../../modules/githost.nix
  ];

  nixpkgs.overlays = [
    (super: self: { h2o = super.callPackage ../../packages/h2o { }; })
    (super: self: { cgit-server = super.callPackage ../../packages/cgit-server { }; })
    (super: self: { logo = super.callPackage ../../packages/logo { }; })
    (super: self: { githost-scripts = super.callPackage ../../packages/githost-scripts { }; })
  ];

  services = {
    openssh = {
      enable = true;
      ports = [ 2323 ];
    };
    githost = {
      enable = true;
      authorizedKeys = [ pubkeyGithost ];
    };
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


  networking = {
    interfaces = {
      ens3.ipv6.addresses = [{
        address = "2a03:4000:6:30cc::";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  programs.mosh.enable = true;

  users.mutableUsers = false;
  users.users = {
    christian = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [ vim git ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxmpQ8O9Tt7qWEfGBII4JcIfrJenFoxEk6TrQcXJAOUX3O1j9HCRfsjZqn6s4hqGqDa+49bEPWiI0JGqa1SApXALrC3jZdpv9PplLfHthdW/iv4L4gGwJQaw5D3hRWWxA4zM27MEz9TN74IeA7rSlzy3bxyFocjmUbiNA2aM9mq8tIqNr4+OK+aM624fi7cfLjvJ6cpxSYWPDOpYJcMatLlswj3q/QlXuNW+dXT3mcIlsB+tEBqknyTN3IoGrRx8k2XSSnfTIEBm1yVUqN5lhXGSVKZ7hwn5+I/ihzblMgOfiz44DZfnFoi3DZOeqD/hYWKX1nlID1uLGZwA0RTfq/3ACfq9DkJyAOcKRJof/IAWnTHrWCZQIn+e8d5SK/qYX57U62NCNQCXMAhEKzQkby/6oq56wHtpLEhtYqQZ7+Wbv1vkAmpI1OROYc8zvKsHV3K9Xnn7Y7aASRv6ZNW55Z5aZ5xxo8ShoVGkc/GWKNxYvZHuKvr6HJ1wT+w30aXO0= christian@labyrinth"
      ];
    };
  };


  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/srv"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  security = {
    sudo = {
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults lecture = never
      '';
    };
    acme = {
      acceptTerms = true;
      defaults.email = "me@ctsk.xyz";
    };
  };

  nix.settings = {
    trusted-users = [ "@wheel" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.05";
}
