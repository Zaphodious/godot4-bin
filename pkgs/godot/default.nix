{
  stdenv,
  lib,
  autoPatchelfHook,
  makeWrapper,
  fetchurl,
  unzip,
  buildFHSUserEnv,
  godotDesktopFile,
  godotIconPNG,
  godotIconSVG,
  godotManpage,
  #
  alsa-lib,
  dbus,
  fontconfig,
  libGL,
  libpulseaudio,
  speechd,
  udev,
  vulkan-loader,
  xorg,
  libxkbcommon,
  libdecor,
  wayland,
  version ? "4.3-stable",
  versionHash ? "sha256-feVkRLEwsQr4TRnH4M9jz56ZN+5LqUNkw7fdEUJTyiE=",
  arch ? "linux.x86_64",
}:
stdenv.mkDerivation rec {
  pname = "godot";
  inherit version;
  src = fetchurl {
    url = "https://github.com/godotengine/godot-builds/releases/download/${version}/Godot_v${version}_${arch}.zip";
    sha256 = versionHash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];
  buildInputs = [
    alsa-lib
    libGL
    vulkan-loader
    #Xorg
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    libxkbcommon
    #Wayldnd
    libdecor
    wayland
    #Dbus
    dbus
    dbus.lib
    #Fontconfig
    fontconfig
    fontconfig.lib
    #Pulseaudio
    libpulseaudio

    #Speechd
    speechd

    #udev
    udev
  ];
  runtimeDependencies = buildInputs;
  dontAutoPatchelf = false;

  unpackPhase = ''
    mkdir source
    unzip $src -d source
  '';
  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 source/Godot_v${version}_${arch} $out/bin/godot

    # Only create a desktop file, if the necessary variables are set
    # these are set only, if one installs this program using flakes.
    if [[ -f "${godotDesktopFile}" ]]; then
      mkdir -p "$out/man/share/man/man6"
      cp ${godotManpage} "$out/man/share/man/man6/"

      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}
      cp ${godotDesktopFile} "$out/share/applications/org.godotengine.Godot.desktop"
      cp ${godotIconSVG} "$out/share/icons/hicolor/scalable/apps/godot.svg"
      cp ${godotIconPNG} "$out/share/icons/godot.png"
      substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
        --replace "Exec=godot" "Exec=$out/bin/godot"
    fi
  '';

  libraries = lib.makeLibraryPath buildInputs;
  postFixup = ''
    wrapProgram $out/bin/godot \
      --set LD_LIBRARY_PATH ${libraries}
  '';
}
