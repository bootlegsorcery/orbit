{ lib, stdenv, rustPlatform, pkg-config, gtk4, gtk4-layer-shell, bluez, dbus, systemd }:

rustPlatform.buildRustPackage rec {
  pname = "orbit";
  version = "2.4.6";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    bluez
    dbus
    systemd
  ];

  # Required for BlueZ D-Bus integration
  PKG_CONFIG_PATH = "${dbus.dev}/lib/pkgconfig:${bluez}/lib/pkgconfig";

  meta = with lib; {
    description = "A WiFi/Bluetooth manager for Wayland";
    homepage = "https://github.com/LifeOfATitan/orbit";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}