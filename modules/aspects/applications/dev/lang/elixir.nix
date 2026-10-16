# Elixir & BEAM Language Aspect
{
  den.aspects.applications.dev.lang.elixir = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.beam29Packages.hex
          pkgs.beam29Packages.elixir_1_20
          pkgs.beam29Packages.expert
          pkgs.elixir-ls
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.beam29Packages.hex
          pkgs.beam29Packages.elixir_1_20
          pkgs.beam29Packages.expert
          pkgs.elixir-ls
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.elixir = {
        data = null;

        runtimePkgs = [
          pkgs.beam29Packages.expert
          pkgs.elixir-ls
        ];
      };
    };
}
