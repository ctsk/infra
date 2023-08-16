{
  description = "ctsk's nix configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    impermanence.url = "github:nix-community/impermanence";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, impermanence, deploy-rs }: {

    nixosConfigurations = {
      crucible = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules =
          [
            ./lib/systems/crucible
          ];
      };

      fugitive = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            (impermanence + "/nixos.nix")
            ./lib/systems/fugitive
          ];
      };
    };

  };

}
