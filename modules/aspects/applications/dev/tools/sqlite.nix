# C/C++ & LLVM Toolchain Aspect
_: {
  den.aspects.applications.dev.tools.sqlite = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          sqlite
          # Make a check if we are in
          # a desktop environment, use config settings
          # sqlitebrowser
        ];
      };
  };
}
