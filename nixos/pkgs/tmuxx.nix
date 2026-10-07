{
  tmux,
  fetchFromGitHub,
}:

tmux.overrideAttrs (oldAttrs: {
  pname = "tmuxx";
  version = "0-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "2b5b538152a1ecdeac4c080f77f6af062349bdb7";
    hash = "sha256-xUYIpIOKzfd34+KlwQjPhmfE1qUbDJ8IvcL0bZy5CH8=";
  };

  # git builds report `tmux -V` as "next-3.x", failing versionCheckHook
  doInstallCheck = false;

  # NOTE: plugins that shell out to `tmux` (e.g. tmux-menus via TMUX_BIN) will
  # use the 3.8-rc3 client against this next-3.9 server. If something
  # misbehaves under tmuxx, launch with: TMUX_BIN=tmuxx tmuxx

  postInstall = (oldAttrs.postInstall or "") + ''
    mv $out/bin/tmux $out/bin/tmuxx
    mv $man/share/man/man1/tmux.1 $man/share/man/man1/tmuxx.1
  '';

  meta = oldAttrs.meta // {
    mainProgram = "tmuxx";
  };
})
