{
  pkgs,
  lib ? pkgs.lib,
}:
{
  policies = import ./policies.nix;
  extensions = import ./extensions.nix { inherit pkgs; };
  search = import ./search.nix { inherit pkgs; };
  nativeMessagingHosts = import ./native-hosts.nix { inherit pkgs; };
  findbarCss = builtins.readFile ./styles/better-findbar.css;
  autohideToolboxCss = builtins.readFile ./styles/autohide_toolbox.css;
  autohideSidebarCss = builtins.readFile ./styles/autohide_sidebar.css;
  floatingFindbarCss = builtins.readFile ./styles/floating_findbar.css;
}
