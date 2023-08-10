{
  description = "ctsk's nix configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, deploy-rs }: {

    nixosConfigurations = {
      crucible = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules =
          [
            ./lib/systems/crucible.nix
          ];
      };
    };

  };

}
