{
  den.aspects.applications.editors.helix = {

    # nixos = { pkgs, ... }: {
    #   environment.systemPackages = [
    #     pkgs.helix
    #   ];
    # };

    homeManager = {
      programs.helix = {
        enable = true;
      };
    };

    # devenv = { pkgs, ... }: {
    #   env = {
    #     DENDRITIC = "helix";
    #   };
    #
    #   packages = [ pkgs.helix ];
    # };
  };
}
