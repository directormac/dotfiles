# Obsidian
# [Options](https://search.nixos.org/options?channel=unstable&query=obsidian&source=home_manager&type=options)
{
  den.aspects.applications.productivity.obsidian = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          obsidian-export
        ];

        programs.obsidian = {
          enable = true;
          cli.enable = true;

        };
      };

    persistHome.directories = [
      ".config/obsidian"
    ];
  };
}
