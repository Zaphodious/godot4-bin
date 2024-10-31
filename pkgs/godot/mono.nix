{
  lib,
  fetchurl,
  godotBin,
  msbuild,
  zlib,
  godotDesktopFile,
  godotIconPNG,
  godotIconSVG,
  godotManpage,
  version ? "4.3-stable",
  versionHash ? "sha256-7N881aYASmVowZlYHVi6aFqZBZJuUWd5BrdvvdnK01E=",
  arch ? "linux.x86_64",
  archWithUnderscore ? "linux_x86_64", # I have no comment on that..
  dotnetPackage,
  setDotnetRoot ? false,
}:
godotBin.overrideAttrs (oldAttrs: let
  godotName = "Godot_v${version}_mono_${arch}";
  godotNameUnderscore = "Godot_v${version}_mono_${archWithUnderscore}";
in rec {
  pname = "godot-mono";

  src = fetchurl {
    url = "https://github.com/godotengine/godot-builds/releases/download/${version}/Godot_v${version}_mono_${archWithUnderscore}.zip";
    sha256 = versionHash;
  };

  buildInputs =
    oldAttrs.buildInputs
    ++ [
      zlib
      msbuild
      dotnetPackage
    ];

  libraries = lib.makeLibraryPath buildInputs;

  #Godot_v4.3-stable_mono_linux.x86_64
  #Godot_v4.3-stable_mono_linux.x86_64
  unpackPhase = ''
    mkdir source
    unzip $src -d source
    mv source/${godotNameUnderscore}/* source
    rmdir source/${godotNameUnderscore}

  '';
  installPhase = ''
    mkdir -p $out/bin $out/opt/godot-mono

    install -m 0755 source/${godotName} $out/opt/godot-mono/${godotName}
    cp -r source/GodotSharp $out/opt/godot-mono


    # Ensure that dotnet is actually available to Godot
    echo "${dotnetPackage}" >> $out/bin/runtime-deps.txt

    ln -s $out/opt/godot-mono/${godotName} $out/bin/godot-mono

    # Only create a desktop file, if the necessary variables are set
    # these are set only, if one installs this program using flakes.
    if [[ -f "${godotDesktopFile}" ]]; then
      mkdir -p "$out/man/share/man/man6"
      cp ${godotManpage} "$out/man/share/man/man6/"


      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}
      cp ${godotDesktopFile} "$out/share/applications/org.godotengine.Godot-Mono.desktop"
      cp ${godotIconSVG} "$out/share/icons/hicolor/scalable/apps/godot.svg"
      cp ${godotIconPNG} "$out/share/icons/godot.png"
      substituteInPlace "$out/share/applications/org.godotengine.Godot-Mono.desktop" \
        --replace "Exec=godot" "Exec=$out/bin/godot-mono"
    fi
  '';

  postFixup =
    if setDotnetRoot
    then ''
      wrapProgram $out/bin/godot-mono \
        --set LD_LIBRARY_PATH ${libraries} \
        --set DOTNET_ROOT ${dotnetPackage}
    ''
    else ''
      wrapProgram $out/bin/godot-mono
        --set LD_LIBRARY_PATH ${libraries}
    '';
})
