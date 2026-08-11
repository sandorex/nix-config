{ kdePackages
, ...
}:

# NOTE: this is qt6ct patched by ilya-fedin on AUR
# https://aur.archlinux.org/packages/qt6ct-kde

kdePackages.qt6ct.overrideAttrs (oldAttrs: {
  buildInputs = oldAttrs.buildInputs ++ (with kdePackages; [
    qtdeclarative
    kconfig
    kcolorscheme
    kiconthemes
  ]);

  patches = [
    # adds support for KDE colorschemes to properly theme KDE apps
    ./qt6ct/kcolorscheme.patch
  ];
})
