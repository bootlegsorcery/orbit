{
  description = "Orbit WiFi/Bluetooth manager for Wayland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          orbit = pkgs.callPackage ./default.nix { };
          default = self.packages.${system}.orbit;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            rustc
            cargo
            pkg-config
          ];

          buildInputs = with pkgs; [
            gtk4
            gtk4-layer-shell
            bluez
            dbus
            systemd
          ];

          # Required for BlueZ D-Bus integration
          PKG_CONFIG_PATH = "${pkgs.dbus.dev}/lib/pkgconfig:${pkgs.bluez}/lib/pkgconfig";
        };
      }
    ) // {
      nixosModules.orbit = { config, lib, pkgs, ... }:
        import ./nixos-module.nix {
          inherit config lib pkgs;
          orbitPackage = self.packages.${pkgs.system}.default;
        };
    };
}