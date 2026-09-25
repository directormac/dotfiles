{
  ...
}:
{
  flake.homeModules.git = { pkgs, ... }: {

    # GPG
    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-all;

      defaultCacheTtl = 10800;
      maxCacheTtl = 10800;

      enableSshSupport = true;
      defaultCacheTtlSsh = 10800;
      maxCacheTtlSsh = 10800;
      sshKeys = [ ];

      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    # GIT
    programs.git = {
      enable = true;
      settings = {
        user = {
          email = "mac@mkra.dev";
          name = "Mark Asena";
        };
        credential.helper = "store";
      };

    };

    programs = {
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
        extensions = with pkgs; [
          gh-dash
          gh-f
          gh-s
          gh-stack
          gh-markdown-preview
        ];
      };

    };
  };
}
