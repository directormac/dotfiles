# GPG & GPG-Agent Aspect
{ den, ... }:
{
  den.aspects.applications.dev.security.gpg = {
    homeManager =
      { pkgs, ... }:
      {
        programs.gpg.enable = true;

        services.gpg-agent = {
          enable = true;
          pinentry.package = pkgs.pinentry-all;

          defaultCacheTtl = 10800;
          maxCacheTtl = 10800;

          enableSshSupport = true;
          defaultCacheTtlSsh = 10800;
          maxCacheTtlSsh = 10800;

          noAllowExternalCache = true;

          sshKeys = [
            "E9A28495202EB6723965F5C42E0855AA109CF7D1"
          ];

          enableZshIntegration = true;
          enableBashIntegration = true;
        };
      };

    persistHome.directories = [
      ".gnupg"
    ];
  };
}
