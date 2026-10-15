# Host Capabilities: defines traits like isWorkstation and isServer on host schema
{ lib, ... }:
{
  den.schema.host.imports = [
    {
      options = {
        description = lib.mkOption {
          default = "";
          description = "Human-readable description of the host";
          type = lib.types.str;
        };

        isServer = lib.mkOption {
          default = false;
          description = "Whether the host is a headless server";
          type = lib.types.bool;
        };

        isWorkstation = lib.mkOption {
          default = true;
          description = "Whether the host is an interactive GUI workstation";
          type = lib.types.bool;
        };
      };
    }
  ];
}
