# bevy.nix
# things only related to how to build bevy with nix
pkgs:
let
  # shortcut
  inherit (pkgs) lib;
  # for now : nothing is requiered for all platforms
  defaultDeps = [ ];
  # basically xOrg and wayland support
  linuxDeps = with pkgs; [
    udev
    alsa-lib
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    libxkbcommon
    wayland
  ];
  # libiconv is a conversion library for Unicode characters
  darwinDeps = with pkgs; [ libiconv ];

in rec {
  # runtime deps :
  buildInputs = defaultDeps ++ (lib.optionals pkgs.stdenv.isLinux linuxDeps)
    ++ (lib.optionals pkgs.stdenv.isDarwin darwinDeps);
  # build deps :
  nativeBuildInputs = [ pkgs.pkg-config pkgs.makeWrapper ] ++ buildInputs;
  # env-var to find libs :
  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

    installPhase = ''wrapProgram $out/bin/bevy_game \
      --set PATH ${lib.makeBinPath buildInputs}
  '';
}
