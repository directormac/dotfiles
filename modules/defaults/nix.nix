# [nix.settings](https://search.nixos.org/options?channel=unstable&query=nix.settings&type=options)
{pkgs}: {
  den.default.nixos.nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    use-xdg-base-directories = true;
    accept-flake-config = true;
  };
  den.default.nixos = {
    environment.systemPackages = with pkgs; [
      # Nix tooling
      nixd
      statix
      alejandra
      manix
      nix-inspect
      devenv

      nil
      nixfmt
    ];
  };
}
# {inputs, ...}: {
#   perSystem = {...}: {
#     _module.args = {
#       # Make flakeLocation universally addressable
#       flakeLocation = builtins.getEnv "PWD";
#     };
#   };
#
#   flake.nixosModules.nix = {
#     pkgs,
#     config,
#     ...
#   }: {
#     imports = [
#       inputs.nix-index-database.nixosModules.nix-index
#     ];
#
#     programs = {
#       nix-index-database.comma.enable = true;
#       nix-ld.enable = true;
#       # command-not-found.enable = false;
#     };
#
#     nix = {
#       # [Available settings](https://nix.dev/manual/nix/2.24/command-ref/conf-file#available-settings)
#       settings = {
#         trusted-users = ["root" config.preferences.user.name];
#         use-xdg-base-directories = true;
#         keep-derivations = true;
#         auto-optimise-store = true;
#         experimental-features = [
#           "nix-command"
#           "flakes"
#         ];
#         accept-flake-config = true;
#       };
#       # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md#configuration
#       nixPath = ["nixpkgs=${inputs.nixpkgs}"];
#       optimise.automatic = false;
#       gc = {
#         automatic = true;
#         dates = "daily";
#         options = "--delete-older-than 5d";
#       };
#     };
#
#     nixpkgs = {
#       config = {
#         allowUnfree = true;
#       };
#     };
#
#     # Nix related tools
#     environment.systemPackages = with pkgs; [
#       # Nix tooling
#       nil
#       nixd
#       statix
#       alejandra
#       nixfmt
#       manix
#       nix-inspect
#       devenv
#     ];
#   };
# }
