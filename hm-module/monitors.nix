self:
{ config, ... }:
let
  inherit (self.lib) lib;
  inherit (lib) types;

  cfg = config.wayland.windowManager.hyprland.monitors;

  point2DType = numType:
    types.submodule {
      options = {
        x = lib.mkOption {
          type = numType;
          description =
            "The X-coordinate of a point, or the width of a rectangle.";
        };
        y = lib.mkOption {
          type = numType;
          description =
            "The Y-coordinate of a point, or the height of a rectangle.";
        };
      };
    };
in {
  options = {
    wayland.windowManager.hyprland.monitors = lib.mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          name = lib.mkOption {
            type = types.singleLineStr;
            description = ''
              The name of the monitor as shown in the output of
              `hyprctl monitors`, for example `eDP-1` or `HDMI-A-1`.
            '';
          };
          pos = lib.mkOption {
            type = types.either (point2DType types.ints.unsigned)
              (types.enum [ "auto" ]);
            default = "auto";
            description = ''
              The position of the monitor as `{ x, y }` attributes.

              This is not the same as {option}`position` which is a
              string or an enum string.
            '';
          };
          size = lib.mkOption {
            type = types.either (point2DType types.ints.positive)
              (types.enum [ "preferred" "highrr" "highres" ]);
            default = "preferred";
            description = ''
              The physical size of the display as `{ x, y }` attributes.

              This is not the same as {option}`option` which is a
              string or an enum string.
            '';
          };
          scale = lib.mkOption {
            type = types.float;
            default = 1.0;
            description = ''
              The fractional scaling factor to use for Wayland-native programs.
              The virtual size of the display will be each dimension divided by
              this float. For example, the virtual size of a monitor with a physical
              size of 2880x1800 pixels would be 1920x1200 virtual pixels.
            '';
          };
          refreshRate = lib.mkOption {
            type = types.nullOr (types.either types.ints.positive types.float);
            default = null;
            description = ''
              The refresh rate of the monitor, if unspecified will choose
              a default mode for your specified resolution.
            '';
          };
          position = lib.mkOption {
            type = types.singleLineStr;
            internal = true;
            readOnly = true;
          };
          resolution = lib.mkOption {
            type = types.singleLineStr;
            internal = true;
            readOnly = true;
          };
        };

        config = let
          posIsPoint = (point2DType types.ints.unsigned).check config.pos;
          sizeIsPoint = (point2DType types.ints.positive).check config.size;
        in {
          position = lib.mkMerge [
            # is X,Y
            (lib.mkIf posIsPoint
              "${toString config.pos.x}x${toString config.pos.y}")
            # is enum string
            (lib.mkIf (!posIsPoint) config.pos)
          ];
          resolution = lib.mkMerge [
            # is X,Y
            (lib.mkIf sizeIsPoint
              "${toString config.size.x}x${toString config.size.y}${
                lib.optionalString (config.refreshRate != null)
                "@${toString config.refreshRate}"
              }")
            # is enum string
            (lib.mkIf (!sizeIsPoint) config.size)
          ];
        };
      }));

      description = ''
        Monitors to configure. The attribute name is not used in the
        Hyprland configuration, but is a convenience for recursive Nix.

        The "name" the monitor will have (the connector, not make and model)
        is specified in the `name` attribute for the monitor.
        It is not the attribute name of the monitor in *this* parent set.
      '';

      example = lib.literalExpression ''
        (with config.wayland.windowManager.hyprland.monitors; {
          # The attribute name `internal` is for usage in recursive Nix.
          internal = {
            name = "eDP-1";
            pos = "auto"; # `auto` is default
            size = "preferred"; # `preferred` is default
            bitdepth = 10;
          };
        })
      '';

      default = { };
    };
  };

  config = {
    wayland.windowManager.hyprland.config.monitor = lib.mapAttrsToList
      (attrName:
        { name, position, resolution, scale, ... }:
        lib.concatStringsSep "," [ name position resolution (toString scale) ])
      cfg;
  };
}
