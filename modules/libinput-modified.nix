{ ... }:

# modifies libinput to increase the threshold for debouncing
let
  overlay = (final: prev: {
    libinput = prev.libinput.overrideAttrs (finalAttrs: prevAttrs: {
      # change name so its obvious it has been modified
      pname = prevAttrs.pname + "-modified";

      # append post patch
      postPatch = (prevAttrs.postPatch or "") + ''
        substituteInPlace src/evdev-debounce.c \
          --replace "const int DEBOUNCE_TIMEOUT_BOUNCE = ms2us(25)" "const int DEBOUNCE_TIMEOUT_BOUNCE = ms2us(100)" \
          --replace "const int DEBOUNCE_TIMEOUT_SPURIOUS = ms2us(12)" "const int DEBOUNCE_TIMEOUT_SPURIOUS = ms2us(36)"
      '';
    });
  });
in {
  nixpkgs.overlays = [ overlay ];
}
