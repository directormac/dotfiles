{
  core,
  den,
  ...
}:
{
  /**
    # This diretory is dedicated to `core` namespace.

    What are [Namespaces](https://den.denful.dev/guides/namespaces/#what-are-namespaces)
  */
  # Basic usage where all the options are avaialble
  # just because its a namespace doesnt mean it doesnt have the aspects has.
  core.guide = {
    homeManager = {
      programs.vim.enable = true;
    };

    # We can call aspects from den, and also with our own aspects
    # other aspects can also use our aspects defined in our namespace
    includes = [
      (den.batteries.user-shell "zsh")

      (den.batteries.unfree [
        "steam"
      ])

      core.shell
    ];

    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.vim ];
    };

    # Options that are shaed between darwin and nixos
    # https://den.denful.dev/reference/batteries/#denbatteriesos-class
    os = {
      os.networking.hostName = "foo";
    };
  };

  # Always prefer doing `parametric aspects`
  # Read more https://den.denful.dev/explanation/parametric/#where-parametric-args-work
  core.params = { host, ... }: {
    nixos.networking.hostName = host.name;
  };

  # This only activates for standalone {home} contexts
  core.shell-config = { 
    # deadnix: skip
    home, 
    ...} : {
    homeManager.programs.zsh.enable = true;
  };

  core.user-group = { user, ... }: {
    nixos.users.users.${user.userName}.extraGroups = [ "wheel" ];
  };

  core.zero = {
    includes = with core; [
      # Even if included here if this aspect doesnt have a host
      # it will not be activated
      params
    ];
  };



  # Policies


}
