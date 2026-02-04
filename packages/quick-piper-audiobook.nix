{ lib
, stdenv
, fetchurl
, makeWrapper
, autoPatchelfHook
, glibc
, calibre
, ffmpeg-full
, ffmpegPackage ? ffmpeg-full
, ...
}:

stdenv.mkDerivation rec {
  pname = "QuickPiperAudiobook";
  version = "0.0.7";

  src = fetchurl {
    url = "https://github.com/C-Loftus/QuickPiperAudiobook/releases/download/v0.0.7/QuickPiperAudiobook-linux-amd64";
    hash = "sha256-gnzFt60NuHmikbUq9Xh8kDkhyR/9q2za/JdEtKTmyKM=";
  };

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ ffmpegPackage calibre ]}
  '';

  meta = {
    mainProgram = pname;
    description = "With one command, create a natural-sounding audiobook from a variety of input formats (epub, mobi, txt, PDF, HTML and more!)";
    homepage = "https://github.com/C-Loftus/QuickPiperAudiobook";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
  };
}
