{ pkgs
, lib
, ...
}:

pkgs.stdenvNoCC.mkDerivation rec {
  name = "BreezeX-Light";
  version = "2.0.1";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/icons
    cp -r ${./BreezeX/BreezeX-Light} $out/share/icons/${name}
  '';

  meta = {
    description = "BreezeX-Light";
    longDescription = ''
      Extended KDE cursor, Highly inspired on KDE Breeze for Windows and Linux with HiDPi Support
    '';
    homepage = "https://github.com/ful1e5/BreezeX_Cursor";
    changelog = "https://github.com/ful1e5/BreezeX_Cursor/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
  };
}
