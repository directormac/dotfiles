# Carapace Multi-Shell Completion Engine Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.shell.carapace = {
    homeManager =
      { pkgs, ... }:
      {
        programs.carapace = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
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
