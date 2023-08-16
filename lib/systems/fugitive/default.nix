{ impermanence, ... }:
{
  imports = [
    ./hardware.nix
  ];

  services.openssh = {
    enable = true;
    ports = [ 2323 ];
  };

  programs.mosh.enable = true;

  users.users = {
    christian = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxmpQ8O9Tt7qWEfGBII4JcIfrJenFoxEk6TrQcXJAOUX3O1j9HCRfsjZqn6s4hqGqDa+49bEPWiI0JGqa1SApXALrC3jZdpv9PplLfHthdW/iv4L4gGwJQaw5D3hRWWxA4zM27MEz9TN74IeA7rSlzy3bxyFocjmUbiNA2aM9mq8tIqNr4+OK+aM624fi7cfLjvJ6cpxSYWPDOpYJcMatLlswj3q/QlXuNW+dXT3mcIlsB+tEBqknyTN3IoGrRx8k2XSSnfTIEBm1yVUqN5lhXGSVKZ7hwn5+I/ihzblMgOfiz44DZfnFoi3DZOeqD/hYWKX1nlID1uLGZwA0RTfq/3ACfq9DkJyAOcKRJof/IAWnTHrWCZQIn+e8d5SK/qYX57U62NCNQCXMAhEKzQkby/6oq56wHtpLEhtYqQZ7+Wbv1vkAmpI1OROYc8zvKsHV3K9Xnn7Y7aASRv6ZNW55Z5aZ5xxo8ShoVGkc/GWKNxYvZHuKvr6HJ1wT+w30aXO0= christian@labyrinth"
      ];
    };
  };

  users.mutableUsers = false;

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

  security.sudo = {
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults lecture = never
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # rollback results in sudo lectures after each reboot
  # rollback results in sudo lectures after each reboot
  system.stateVersion = "23.05";
}
