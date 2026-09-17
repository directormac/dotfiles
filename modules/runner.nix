# enables `nix run .#vm`. it is very useful to have a VM
# you can edit your config and launch the VM to test stuff
# instead of having to reboot each time.
{
  inputs,
  runner,
  ...
}: {
  den.aspects.igloo.includes = [
    runner.vm.gui
    # eg.vm.tui
  ];

  perSystem = {pkgs, ...}: {
    packages.run-igloo = pkgs.writeShellApplication {
      name = "run-igloo";
      text = ''
        ${inputs.self.nixosConfigurations.igloo.config.system.build.vm}/bin/run-igloo-vm "$@"
      '';
    };
  };
}
