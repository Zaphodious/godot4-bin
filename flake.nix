{
  description = "Official Godot binary packages for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Add files needed to create a launcher icon for Godot
    godot-desktop-file = {
      url = "https://raw.githubusercontent.com/godotengine/godot/1a2e0b22b6278cef95a528e9101a53f4cb93b548/misc/dist/linux/org.godotengine.Godot.desktop";
      flake = false;
    };
    godot-icon-png = {
      url = "https://raw.githubusercontent.com/godotengine/godot/1a2e0b22b6278cef95a528e9101a53f4cb93b548/icon.png";
      flake = false;
    };
    godot-icon-svg = {
      url = "https://raw.githubusercontent.com/godotengine/godot/1a2e0b22b6278cef95a528e9101a53f4cb93b548/icon.svg";
      flake = false;
    };
    godot-manpage = {
      url = "https://raw.githubusercontent.com/godotengine/godot/1a2e0b22b6278cef95a528e9101a53f4cb93b548/misc/dist/linux/godot.6";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    rec {
      packages.${system} = rec {
        godot = pkgs.callPackage ./pkgs/godot {
          godotDesktopFile = inputs.godot-desktop-file;
          godotIconPNG = inputs.godot-icon-png;
          godotIconSVG = inputs.godot-icon-svg;
          godotManpage = inputs.godot-manpage;
        };
        godot-mono = pkgs.callPackage ./pkgs/godot/mono.nix {
          godotDesktopFile = inputs.godot-desktop-file;
          godotIconPNG = inputs.godot-icon-png;
          godotIconSVG = inputs.godot-icon-svg;
          godotManpage = inputs.godot-manpage;
          godotBin = godot;
        };
        default = godot-mono;
      };
    };

}
