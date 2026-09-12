# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{inputs, ...}: {
  perSystem = {
    pkgs,
    self',
    lib,
    ...
  }: let
    checkCond = name: cond:
      pkgs.runCommandLocal name {} (
        if cond
        then "touch $out"
        else ""
      );

    mini = inputs.self.nixosConfigurations.mini.config;
    miniBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists (mini.system.build.toplevel);
  in {
    checks."mini builds" = checkCond "igloo-builds" miniBuilds;
  };
}
