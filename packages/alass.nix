{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, glibc
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

  nativeBuildInputs = [
    makeWrapper
  ];

  postFixup = ''
    mv $out/bin/alass-cli $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ ffmpegPackage ]}
  '';

  meta = {
    mainProgram = pname;
    description = "Automatic Language-Agnostic Subtitle Synchronization Utility";
    homepage = "https://github.com/sandorex/alass";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
})
