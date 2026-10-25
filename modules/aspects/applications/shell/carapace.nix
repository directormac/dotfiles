# Carapace Multi-Shell Completion Engine Leaf Aspect
{
  den.aspects.applications.shell.carapace = {
    homeManager =
      { pkgs, ... }:
      {
        programs.carapace = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;

          environment = {
            CARAPACE_BRIDGES = "zsh,fish,bash";
          };

          extraPackages = with pkgs; [
            carapace-bridge
          ];
        };
      };
  };
}
