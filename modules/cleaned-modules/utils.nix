{ super, lib, ... }:

let
  customModule = { name, description, extraOptions, getConfig, params, extra }: {
    options.custom."${name}" = {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = description;
      };
    } // extraOptions;

    config =
      let
        cfg = params.config.custom."${name}";
      in
      lib.mkIf cfg.enable (getConfig { cfg = cfg; });
  } // extra;
in
{
  lib = super.lib // {
    custom = {
      customModule = customModule;
    };
  };
}
