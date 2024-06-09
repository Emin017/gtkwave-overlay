{
  pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem,
}: let
  gtkwaveNightly = pkgs.stdenv.mkDerivation {
    pname = "gtkwave";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "gtkwave";
      repo = "gtkwave";
      rev = "27f3a94aede651f232314d0fe0c86cc35308fa85";
      sha256 = "sha256-RxEI1dTMrrFccxuYkb9GQzuFrzTiWOnnfEBR7V918c8=";
    };

    buildInputs = with pkgs;
      [
        flex
        meson
        ninja
        pkg-config
        gtk3
        glib
        gperf
        gobject-introspection
        desktop-file-utils
        shared-mime-info
      ]
      ++ lib.optional stdenv.isDarwin gtk-mac-integration;

    configureFlags = [
      "--enable-judy"
      "--enable-gtk3"
    ];

    nativeBuildInputs = with pkgs; [
      meson
      ninja
    ];

    configurePhase = ''
      meson setup build --prefix=$out
    '';

    buildPhase = ''
      meson compile -C build
    '';

    installPhase = ''
      meson install -C build
    '';
  };
in
  gtkwaveNightly
