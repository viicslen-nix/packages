{
  description = "Shared local packages for viicslen-nix subflakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Leave `nixpkgs` un-overridden — it is what keeps cache.numtide.com hitting.
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
    llm-agents,
    ...
  }: let
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    treefmtEval =
      forAllSystems (system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
  in {
    formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      treefmt = treefmtEval.${system}.config.build.check self;
      statix = pkgs.runCommandLocal "statix-check" {} ''
        ${pkgs.lib.getExe pkgs.statix} check ${./.} && touch $out
      '';
    });

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      nixpkgs.lib.packagesFromDirectoryRecursive {
        callPackage = pkgs.newScope {
          llm-agents = llm-agents.packages.${system};
        };
        directory = ./by-name;
      });
  };
}
