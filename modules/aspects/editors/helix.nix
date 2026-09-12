{
  den,
  lib,
  ...
}: {
  # Expose it as a flake package using flake-parts, so `nix run .#helix` works.
  perSystem = {pkgs, ...}: {
    packages.helix = pkgs.helix;
  };

  den.aspects.editor.helix = {
    config,
    pkgs,
    ...
  }: {
    homeManager.programs.helix = {
      enable = true;
      extraConfig = builtins.readFile "${config.repoConfigDir}/helix/config.toml";

      settings = {
        theme = "catppuccin_mocha";
        editor = {
          line-number = "relative";
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.alejandra;
            language-servers = ["nixd"];
          }
        ];
        language-server = {
          nixd = {
            command = lib.getExe pkgs.nixd;
            args = ["--semantic-tokens=true"];
            config.nixd = let
              nixosConfiguration = "igloo";
              flakeRef = "(builtins.getFlake (toString ./.))";
              nixosOpts = "${flakeRef}.nixosConfigurations.${nixosConfiguration}.options";
            in {
              nixpkgs.expr = "${flakeRef}.inputs.nixpkgs";
              options = {
                nixos.expr = nixosOpts;
                home_manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
              };
            };
          };
        };
      };
    };
  };
}
