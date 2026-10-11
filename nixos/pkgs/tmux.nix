{
  tmux,
  fetchurl,
  lib,
}:

tmux.overrideAttrs (oldAttrs: rec {
  pname = "tmux";
  version = "3.8";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
    hash = "sha256-55xpnH6UnczQpKEl4XuNEmHjEbFpedvI6zRULzlm2C4=";
  };
})
