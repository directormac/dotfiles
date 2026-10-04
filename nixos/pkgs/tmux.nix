{
  tmux,
  fetchurl,
}:

tmux.overrideAttrs (oldAttrs: rec {
  pname = "tmux";
  version = "3.8-rc3";

  src = fetchurl {
    url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
    hash = "sha256-vAh1xw0LnkfZ+QYbkv5QM3ab9QrDVBr/3TqFYh9yMNU=";
  };
})
