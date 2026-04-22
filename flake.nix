{
  description = "Shared local packages for viicslen-nix subflakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    packages = forAllSystems (system:
      nixpkgs.lib.packagesFromDirectoryRecursive {
        callPackage = (import nixpkgs {inherit system;}).callPackage;
        directory = ./by-name;
      });
  };
}
