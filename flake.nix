{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, ... }:
    let
      # todo : move crane logic out of flake.nix for readability

      systems = [ "x86_64-linux" "aarch64-linux" ];

      # helper to build for multiple system
      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
        (system: function nixpkgs.legacyPackages.${system});

      src = ./.;

      bevy = pkgs: import ./nix/bevy.nix pkgs;
      bevyCrates = pkgs:
        (import ./nix/crane.nix {
          inherit pkgs crane src;
          buildArgs = bevy pkgs;
        });

    in {

      # pre-defined bevy engine 
      packages =
        forAllSystems (pkgs: { default = (bevyCrates pkgs).defaultPackage; });

      # build checks
      checks = forAllSystems (pkgs: (bevyCrates pkgs).checks);

      # shell
      devShells = forAllSystems (pkgs: { default = pkgs.mkShell (bevy pkgs); });

    };
}
