{ pkgs, lib ? pkgs.lib }:
{
  policies = import ./policies.nix;
  extensions = import ./extensions.nix { inherit pkgs; };
  search = import ./search.nix { inherit pkgs; };
  nativeMessagingHosts = import ./native-hosts.nix { inherit pkgs; };
  findbarCss = builtins.readFile ./styles/better-findbar.css;
}
