{ lib
, stdenv
, fetchzip
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "irscrutinizer";
  version = "2.4.2";

  src = fetchzip {
    url = "https://github.com/bengtmartensson/IrScrutinizer/releases/download/Version-2.4.2/IrScrutinizer-2.4.2-bin.zip";
    hash = "sha256-ZFbfuhTTTpeOn+55a9kJikFmjNC9P1myX1IomcmRlsw=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out

    # remove binaries for other architectures
    rm -r $out/Linux-arm/ $out/Linux-i386/

    install -m 444 -D ${pname}.desktop -t $out/share/applications
    install -m 444 -D ${pname}.png -t $out/share/icons

    # create symlink for each application
    mkdir -p $out/bin
    ln -s $out/${pname}.sh $out/bin/irscrutinizer
    ln -s $out/${pname}.sh $out/bin/irptransmogrifier
    ln -s $out/${pname}.sh $out/bin/harchardware

    # put udev rules in proper place
    mkdir -p $out/etc
    mv $out/contributed/udev-rules $out/etc/udev

    # hardcode java path
    substituteInPlace $out/${pname}.sh \
      --replace-fail 'JAVA=''${JAVA:-java}' 'JAVA="${pkgs.jdk}/bin/java"'
  '';

  # i cannot build it properly yet, but it kinda works without it
  autoPatchelfIgnoreMissingDeps = [ "liblockdev.so.1" ];

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    libcxx
    jdk
  ];

  meta.mainProgram = "irscrutinizer";
}
