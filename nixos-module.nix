{ config, lib, pkgs, orbitPackage, ... }:

with lib;

let
  cfg = config.services.orbit;
in {
  options.services.orbit = {
    enable = mkEnableOption "Orbit WiFi/Bluetooth manager";
    
    position = mkOption {
      type = types.str;
      default = "center";
      description = "Window position (center, top-left, top-right, bottom-left, bottom-right)";
    };
    
    margin = mkOption {
      type = types.ints.positive;
      default = 10;
      description = "Window margin in pixels";
    };
    
    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User to run the service as (null for systemd --user)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ orbitPackage ];

    # System-wide configuration file
    environment.etc."orbit/config.toml" = {
      text = ''
        position = "${cfg.position}"
        margin_top = ${toString cfg.margin}
        margin_right = ${toString cfg.margin}
        margin_bottom = ${toString cfg.margin}
        margin_left = ${toString cfg.margin}
      '';
    };

    # Service configuration
    systemd.services.orbit = mkIf (cfg.user != null) {
      description = "Orbit WiFi/Bluetooth Manager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${orbitPackage}/bin/orbit daemon";
        Restart = "always";
        RestartSec = "3";
        User = cfg.user;
      };
    };

    # User service for systemd --user
    systemd.user.services.orbit = mkIf (cfg.user == null) {
      description = "Orbit WiFi/Bluetooth Manager";
      after = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      
      serviceConfig = {
        ExecStart = "${orbitPackage}/bin/orbit daemon";
        Restart = "always";
        RestartSec = "3";
      };
    };
  };
}