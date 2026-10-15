# AI & Developer Agents Aspect: Pi, Antigravity CLI, OpenCode
{
  core,
  inputs,
  lib,
  ...
}:
{
  core.ai = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { };
      in
      {
        home.packages = lib.attrValues {
          inherit (llmPkgs)
            antigravity-cli
            opencode
            pi
            ;
        };

        home.file = {
          ".gemini/antigravity-cli/settings.json" = {
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/antigravity-cli/settings.json";
            force = true;
          };
          ".pi/agent/settings.json" = {
            source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/pi/agent/settings.json";
            force = true;
          };
        };
      };

    persistHome.directories = [
      ".pi"
      ".gemini"
      ".local/share/opencode"
    ];
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.ai
  ];
}
