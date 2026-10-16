# Herdr Multiplexer Aspect: LLM Agents management service and out-of-store config symlink
{
  den,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.mux.herdr = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        herdrPkg =
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
            or (pkgs.writeShellScriptBin "herdr" "echo herdr");
      in
      {
        home.file.".config/herdr/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/herdr/config.toml";

        home.packages = [ herdrPkg ];

        systemd.user.services.herdr-server = {
          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${herdrPkg}/bin/herdr server";
            KillMode = "mixed";
            Type = "forking";
          };

          Unit = {
            After = [ "graphical-session.target" ];
            Description = "Herdr Server";
            Documentation = "herdr --help";
          };
        };
      };

    persistHome.directories = [
      ".local/share/herdr"
    ];
  };
}
