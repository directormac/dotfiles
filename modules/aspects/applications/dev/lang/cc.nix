# C/C++ & LLVM Toolchain Aspect
{ den, ... }:
{
  den.aspects.applications.dev.lang.cc = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          gnumake
          gcc
          binutils
          llvm
          llvm-manpages
        ];
      };
  };
}
