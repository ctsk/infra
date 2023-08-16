attrs:
let
  impermanence = builtins.getFlake "github:nix-community/impermanence";
in
{
  imports = [
    impermanence.outputs.nixosModules.impermanence
    ./default.nix
  ];
}
