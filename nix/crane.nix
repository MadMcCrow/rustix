# crane.nix
# All the code from crane to help build bevy and its dependancies 
# pkgs : basically nixpkgs
# system : either "x86_64-linux" or "aarch64-linux" 
{ pkgs, crane, src, buildArgs, ... }:
let
  # shortcuts
  inherit (pkgs) lib;
  system = pkgs.system;
  craneLib = crane.lib.${system};

  commonArgs = buildArgs // {
    src = craneLib.cleanCargoSource (craneLib.path src);
  };

  # Build *just* the cargo dependencies, so we can reuse
  # all of that work (e.g. via cachix) when running in CI
  cargoArtifacts = craneLib.buildDepsOnly (buildArgs // { inherit src; });

  # Note : Clippy is a tool to write better Rust code
  # Run clippy (and deny all warnings) on the crate source,
  # resuing the dependency artifacts (e.g. from build scripts or
  # proc-macros) from above.
  #
  # Note that this is done as a separate derivation so it
  # does not impact building just the crate by itself.
  my-crate-clippy = craneLib.cargoClippy (commonArgs // {
    inherit cargoArtifacts;
    cargoClippyExtraArgs = "-- --deny warnings";
  });

  #Build the actual crate itself, reusing the dependency
  # artifacts from above.
  my-crate = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

  # Also run the crate tests under cargo-tarpaulin so that we can keep
  # track of code coverage
  my-crate-coverage =
    craneLib.cargoTarpaulin (commonArgs // { inherit cargoArtifacts; });

in {
  defaultPackage = my-crate;
  checks = {
    inherit
    # Build the crate as part of `nix flake check` for convenience
      my-crate my-crate-clippy my-crate-coverage;
  };
}
