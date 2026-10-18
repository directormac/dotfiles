# MCP
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.mcp = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages = lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              mcp-remote
              executor
              # gno
              ;
          }
        );

        programs.mcp = {
          enable = true;

          servers = {

            context7 = {
              headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
              url = "https://mcp.context7.com/mcp";
            };

            everything = {
              args = [
                "-y"
                "@modelcontextprotocol/server-everything"
              ];

              command = "npx";
            };

            svelte = {
              args = [
                "-y"
                "@sveltejs/mcp"
              ];

              command = "npx";
              # url = "https://mcp.svelte.dev/mcp";
            };

          };
        };
      };

    persistHome.directories = [
      ".config/mcp"
    ];
  };
}
