# GPG & GPG-Agent Aspect
{
  den.aspects.applications.dev.security.gpg = {
    homeManager =
      { pkgs, ... }:
      {
        programs.gpg.enable = true;

        services.gpg-agent = {
          defaultCacheTtl = 10800;
          defaultCacheTtlSsh = 10800;
          enable = true;
          enableBashIntegration = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          maxCacheTtl = 10800;
          maxCacheTtlSsh = 10800;
          noAllowExternalCache = true;
          pinentry.package = pkgs.pinentry-all;

          sshKeys = [
            "E9A28495202EB6723965F5C42E0855AA109CF7D1"
          ];
        };
      };

    persistHome.directories = [
      ".gnupg"
    ];
  };
}
