self:
{ config, lib, pkgs, ... }:
let
  inherit (self.lib) lib;
  inherit (lib) types;

  cfg = config.wayland.windowManager.hyprland;
in {
  options = {
    wayland.windowManager.hyprland = {
      systemdIntegration = lib.mkOption {
        type = types.bool;
        default = pkgs.stdenv.isLinux;
        description = lib.mdDoc ''
          Whether to enable {file}`hyprland-session.target` on
          hyprland startup. This links to {file}`graphical-session.target`.
          Some important environment variables will be imported to systemd
          and dbus user environment before reaching the target, including:
          - {env}`DISPLAY`
          - {env}`HYPRLAND_INSTANCE_SIGNATURE`
          - {env}`WAYLAND_DISPLAY`
          - {env}`XDG_CURRENT_DESKTOP`
        '';
      };

      recommendedEnvironment = lib.mkOption {
        type = types.bool;
        default = pkgs.stdenv.isLinux;
        description = lib.mdDoc ''
          Whether to set some recommended environment variables.
        '';
      };

      dbusEnvironment = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "HYPRLAND_INSTANCE_SIGNATURE"
          "XDG_CURRENT_DESKTOP"
        ];
        description = lib.mkDoc ''
          Names of environment variables to be exported for
          all D-Bus session services.

          These variables will also be exported for systemd if
          {option}`wayland.windowManager.hyprland.systemdIntegration`
          is enabled.
        '';
      };

      extraDbusEnvironment = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
        description = lib.mdDoc ''
          Extra names of environment variables to be added to
          {option}`wayland.windowManager.hyprland.dbusEnvironment`.

          It is recommended to use this option instead of modifying
          the option mentioned above.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      wayland.windowManager.hyprland.config.exec_once = lib.mkOrder 10 [
        "${pkgs.dbus}/bin/dbus-update-activation-environment ${
          lib.concatStringsSep " "
          ((lib.optional cfg.systemdIntegration "--systemd")
            ++ cfg.dbusEnvironment ++ cfg.extraDbusEnvironment)
        }"
      ];
    }
    (lib.mkIf cfg.systemdIntegration {
      systemd.user.targets.hyprland-session = {
        Unit = {
          Description = "hyprland compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
      wayland.windowManager.hyprland.config.exec_once =
        lib.mkOrder 11 [ "systemctl --user start hyprland-session.target" ];
    })
    (lib.mkIf cfg.recommendedEnvironment {
      home.sessionVariables = { NIXOS_OZONE_WL = "1"; };
    })
  ];
}