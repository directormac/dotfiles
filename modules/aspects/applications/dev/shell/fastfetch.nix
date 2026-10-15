# Fastfetch & Microfetch System Info Aspect
{
  den.aspects.applications.dev.shell.fastfetch = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          fastfetch
          microfetch
        ];
      };
  };
}
