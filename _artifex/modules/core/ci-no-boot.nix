{
  config,
  lib,
  core,
  ...
}:
{
  core.ci-no-boot = {
    nixos = {
      boot.loader.grub.enable = lib.mkDefault false;
      fileSystems."/".device = lib.mkDefault "/dev/noroot";
    };

    description = "Disable booting when running on CI on all NixOS hosts.";
  };

  den.schema.host.includes = lib.optionals (config ? _module.args.CI) [
    core.ci-no-boot
  ];
}
