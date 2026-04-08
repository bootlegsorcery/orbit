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
    
    marginTop = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Top margin in pixels (overrides margin if set)";
    };
    
    marginRight = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Right margin in pixels (overrides margin if set)";
    };
    
    marginBottom = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Bottom margin in pixels (overrides margin if set)";
    };
    
    marginLeft = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Left margin in pixels (overrides margin if set)";
    };
    
    windowTransition = mkOption {
      type = types.str;
      default = "slidedown";
      description = "Window transition effect (slidedown, slideup, slideleft, slideright, fade)";
    };
    
    windowTransitionDuration = mkOption {
      type = types.ints.positive;
      default = 200;
      description = "Window transition duration in milliseconds";
    };
    
    stackTransition = mkOption {
      type = types.str;
      default = "slidehorizontal";
      description = "Stack transition effect (slidehorizontal, slidevertical, fade)";
    };
    
    stackTransitionDuration = mkOption {
      type = types.ints.positive;
      default = 200;
      description = "Stack transition duration in milliseconds";
    };
    

    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional TOML configuration content";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ orbitPackage ];

    # System-wide configuration file
    environment.etc."orbit/config.toml" = {
      text = ''
        position = "${cfg.position}"
        margin_top = ${toString (if cfg.marginTop != null then cfg.marginTop else cfg.margin)}
        margin_right = ${toString (if cfg.marginRight != null then cfg.marginRight else cfg.margin)}
        margin_bottom = ${toString (if cfg.marginBottom != null then cfg.marginBottom else cfg.margin)}
        margin_left = ${toString (if cfg.marginLeft != null then cfg.marginLeft else cfg.margin)}
        window_transition = "${cfg.windowTransition}"
        window_transition_duration = ${toString cfg.windowTransitionDuration}
        stack_transition = "${cfg.stackTransition}"
        stack_transition_duration = ${toString cfg.stackTransitionDuration}
        ${cfg.extraConfig}
      '';
    };



    # User service - Orbit must run as a user service for Wayland compatibility
    systemd.user.services.orbit = {
      description = "Orbit WiFi/Bluetooth Manager";
      after = [ "graphical-session.target" ];
      wants = [ "pipewire.service" "wireplumber.service" ];
      wantedBy = [ "default.target" ];
      
      serviceConfig = {
        ExecStart = "${orbitPackage}/bin/orbit daemon";
        Restart = "always";
        RestartSec = "3";
        # Let GTK auto-discover Wayland display through DBus
        Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
      };
    };
  };
}