# Enables `nix run .#vm-<host-name>`.
# It is very useful to have a VM: You can edit your config and launch the VM to test stuff instead of having to reboot each time.
{
  core,
  den,
  inputs,
  ...
}:
{
  den.aspects.sandbox.includes = [
    core.vm.gui
    core.xfce-desktop
    (den.batteries.vm-autologin "mac")
  ];

  perSystem =
    { pkgs, ... }:
    let
      hosts = builtins.attrNames inputs.self.nixosConfigurations;
      vms = map (
        hostName:
        let
          host = inputs.self.nixosConfigurations.${hostName}.config;
          vmName = "vm-${hostName}";
        in
        {
          name = vmName;

          value = {
            program = pkgs.writeShellApplication {
              name = vmName;

              text = ''
                ${host.system.build.vm}/bin/run-${hostName}-vm "$@"
              '';
            };

            meta.description = "Run adda@${vmName} in a VM for testing before applying changes.";
          };
        }
      ) hosts;
    in
    {
      apps = builtins.listToAttrs vms;
    };
}
