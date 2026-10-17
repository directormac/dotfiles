# LocalSend Local File Sharing Aspect
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

    persistHome.directories = [
      ".local/share/org.localsend.localsend_app"
    ];
  };
}
