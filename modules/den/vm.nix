# Enables `nix run .#vm-<host-name>`.
# It is very useful to have a VM: You can edit your config and launch the VM to test stuff instead of having to reboot each time.
{
  den,
  inputs,
  ...
}: {
  den.aspects.sandbox.includes = [
    # runner.vm.gui
    # runner.vm.tui
  ];

  perSystem = {pkgs, ...}: let
    hosts = builtins.attrNames inputs.self.nixosConfigurations;
    vms =
      map (
        hostName: let
          vmName = "vm-${hostName}";
          host = inputs.self.nixosConfigurations.${hostName}.config;
        in {
          name = vmName;
          value = {
            meta.description = "Run {vmName} in a VM for testing before applying changes.";
            program = pkgs.writeShellApplication {
              name = vmName;
              text = ''
                ${host.system.build.vm}/bin/run-${hostName}-vm "$@"
              '';
            };
          };
        }
      )
      hosts;
  in {
    apps = builtins.listToAttrs vms;
  };
}
