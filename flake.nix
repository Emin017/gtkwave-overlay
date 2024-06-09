{
  description = "Install GTKWave with the latest version";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      gtkwaveOverlay = import ./default.nix {
        inherit system pkgs;
      };

      apps = rec {
        default = apps.gtkwave;
        gtkwave = flake-utils.lib.mkApp {drv = gtkwaveOverlay;};
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          gtkwaveOverlay
          gtk3
        ];
        shellHook = ''
          export GSETTINGS_SCHEMA_DIR=${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.pname}-${pkgs.gtk3.version}/glib-2.0/schemas
        '';
      };

      # nix fmt
      formatter = pkgs.alejandra;
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # Use `gtkwaveNightly` to access the package
      overlays.default = final: prev: {
        gtkwaveNightly = outputs.overlays.gtkwaveNightly;
      };
    };
}
