# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    checkCond = name: cond:
      pkgs.runCommandLocal name {} (
        if cond
        then "touch $out"
        else ""
      );
    sandbox = inputs.self.nixosConfigurations.sandbox.config;
    mac-at-sandbox = sandbox.home-manager.users.mac;
    sandbox-nixosBuilds =
      !pkgs.stdenvNoCC.hostPlatform.isLinux || builtins.pathExists sandbox.system.build.toplevel;
  in {
    checks."sandbox builds" = checkCond "sandbox-nixosBuilds" sandbox-nixosBuilds;

    checks."sandbox enabled mac helix" =
      checkCond "sandbox.provides.mac" mac-at-sandbox.programs.helix.enable;
  };
}
