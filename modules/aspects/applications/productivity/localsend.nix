# LocalSend Local File Sharing Aspect
{ den, ... }:
{
  den.aspects.applications.productivity.localsend = {
    nixos =
      { pkgs, ... }:
      {
        programs.localsend = {
          enable = true;
          openFirewall = true;
        };

        environment.systemPackages = [
          pkgs.localsend
        ];
      };
  };
}
