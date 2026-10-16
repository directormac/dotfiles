# Carapace Multi-Shell Completion Engine Leaf Aspect
{
  den.aspects.applications.shell.carapace = {
    homeManager =
      { pkgs, ... }:
      {
        programs.carapace = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;

          environment = {
            CARAPACE_BRIDGES = "zsh,bash";
            CARAPACE_MATCH = true;
          };

          extraPackages = with pkgs; [
            carapace-bridge
          ];
        };
      };
  };
}
