{
  pkgs,
  fetchurl,
}:

pkgs.tmux.overrideAttrs (_oldAttrs: rec {
  pname = "tmux";

  src = fetchurl {
    hash = "sha256-55xpnH6UnczQpKEl4XuNEmHjEbFpedvI6zRULzlm2C4=";
    url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
  };

  version = "3.8";
})
