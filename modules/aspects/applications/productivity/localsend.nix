# LocalSend Local File Sharing Aspect
_:
{
  den.aspects.applications.productivity.localsend = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.localsend
        ];

        programs.localsend = {
          enable = true;
          openFirewall = true;
        };
      };
  };
}
