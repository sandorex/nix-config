{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, ffmpeg-full
, ffmpegPackage ? ffmpeg-full
, ...
}:

rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "alass";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "sandorex";
    repo = "alass";
    rev = "f2dd9eb1e4c47561dd791aac45a3dfe31fd07e44";
    hash = "sha256-i4p/Kf3vi/gVkYkgdt1jv7qZATd+9f49EiMEJGqEKwI=";
  };

  cargoHash = "sha256-U1rwktvRSr34V0lNQrrxg8fdchVpeSbyPClnZHRUpQs=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    mv $out/bin/alass-cli $out/bin/alass
    wrapProgram $out/bin/alass \
      --prefix PATH : ${lib.makeBinPath [ ffmpegPackage ]}
  '';

  meta = {
    mainProgram = "alass";
    description = "Automatic Language-Agnostic Subtitle Synchronization Utility";
    homepage = "https://github.com/sandorex/alass";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
})

# # this is unreleased latest master atm
# stdenv.mkDerivation rec {
#   pname = "alass";
#   version = "2.0.0-master";

#   src = fetchGit {
#     url = "https://github.com/kaegi/alass.git";
#     ref = "master";
#     rev = "874f02d9577182752a0f969b6d6b98fd65bdf1fc";
#     # hash = "sha256-ZFbfuhTTTpeOn+55a9kJikFmjNC9P1myX1IomcmRlsw=";
#     # stripRoot = false;
#   };

#   # dontBuild = true;

#   # installPhase = ''
#   #   mkdir -p $out
#   #   cp -r ./* $out

#   #   # remove binaries for other architectures
#   #   rm -r $out/Linux-arm/ $out/Linux-i386/

#   #   install -m 444 -D ${pname}.desktop -t $out/share/applications
#   #   substituteInPlace $out/share/applications/${pname}.desktop \
#   #     --replace-fail '${""}''${project.exepath}' "$out/bin/irscrutinizer" \
#   #     --replace-fail '${""}''${project.icon}' "irscrutinizer"

#   #   # copy the icon
#   #   mkdir -p $out/share/icons/hicolor/64x64/apps
#   #   cp irscrutinizer.png $out/share/icons/hicolor/64x64/apps/irscrutinizer.png

#   #   # create symlink for each application
#   #   mkdir -p $out/bin
#   #   ln -s $out/${pname}.sh $out/bin/irscrutinizer
#   #   ln -s $out/${pname}.sh $out/bin/irptransmogrifier
#   #   ln -s $out/${pname}.sh $out/bin/harchardware

#   #   # put udev rules in proper place
#   #   mkdir -p $out/etc
#   #   mv $out/contributed/udev-rules $out/etc/udev

#   #   # hardcode java path
#   #   substituteInPlace $out/${pname}.sh \
#   #     --replace-fail 'JAVA=''${JAVA:-java}' 'JAVA="${pkgs.jdk}/bin/java"'
#   # '';

#   # # i cannot build it properly yet, but it kinda works without it
#   # autoPatchelfIgnoreMissingDeps = [ "liblockdev.so.1" ];

#   # nativeBuildInputs = with pkgs; [
#   #   autoPatchelfHook
#   # ];

#   # buildInputs = with pkgs; [
#   #   libcxx
#   #   jdk
#   # ];

#   meta.mainProgram = "alass";
# }
