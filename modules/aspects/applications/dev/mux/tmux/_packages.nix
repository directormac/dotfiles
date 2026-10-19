# Pinned Tmux Builds
#
# Exposes a pinned tmux 3.8 release and a `next` (git) build through
# `perSystem.packages`. The `next` build is useful to try out upstream
# features without replacing the stable binary.
{
  inputs,
  ...
}:
{ pkgs, ... }:
let
  tmux = pkgs.tmux.overrideAttrs (_oldAttrs: rec {
    pname = "tmux";

    src = pkgs.fetchurl {
      hash = "sha256-55xpnH6UnczQpKEl4XuNEmHjEbFpedvI6zRULzlm2C4=";
      url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
    };

    version = "3.8";
  });

  tmuxx = tmux.overrideAttrs (oldAttrs: {
    # git builds report `tmux -V` as "next-3.x", failing versionCheckHook
    doInstallCheck = false;
    pname = "tmuxx";

    # NOTE: plugins that shell out to `tmux` (e.g. tmux-menus via TMUX_BIN) will
    # use the 3.8-rc3 client against this next-3.9 server. If something
    # misbehaves under tmuxx, launch with: TMUX_BIN=tmuxx tmuxx
    postInstall = (oldAttrs.postInstall or "") + ''
      mv $out/bin/tmux $out/bin/tmuxx
      mv $man/share/man/man1/tmux.1 $man/share/man/man1/tmuxx.1
    '';

    src =
      inputs.tmux-src or (pkgs.fetchFromGitHub {
        hash = "sha256-xUYIpIOKzfd34+KlwQjPhmfE1qUbDJ8IvcL0bZy5CH8=";
        owner = "tmux";
        repo = "tmux";
        rev = "2b5b538152a1ecdeac4c080f77f6af062349bdb7";
      });

    version = "0-unstable-${inputs.tmux-src.lastModifiedDate or "2026-10-05"}";

    meta = oldAttrs.meta // {
      mainProgram = "tmuxx";
    };
  });
in
{
  packages = {
    inherit tmux tmuxx;
  };
}
