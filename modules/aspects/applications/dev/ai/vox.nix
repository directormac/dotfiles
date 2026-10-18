# MCP
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.vox = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages = lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              voxtype
              voxterm
              ;
          }
        );
      };

    persistHome.directories = [
      ".config/mcp"
    ];
  };
}
