# Tree-sitter Grammars Aspect
# Provides all available tree-sitter grammars and CLI for editors across the system.
{ ... }:
let
  grammarsAspect = {
    nixos =
      { pkgs, ... }:
      let
        allTreeSitter = pkgs.tree-sitter.withPlugins (p: builtins.attrValues p);
      in
      {
        environment.systemPackages = [
          pkgs.tree-sitter
          allTreeSitter
        ];
      };

    homeManager =
      { pkgs, ... }:
      let
        allTreeSitter = pkgs.tree-sitter.withPlugins (p: builtins.attrValues p);
      in
      {
        home.packages = [
          pkgs.tree-sitter
          allTreeSitter
        ];

        # Symlink grammars into standard editor lookup paths
        xdg.dataFile."tree-sitter/grammars".source = "${allTreeSitter}/lib";
        xdg.dataFile."helix/runtime/grammars".source = "${allTreeSitter}/lib";
      };
  };
in
{
  den.aspects.applications.dev.tree-sitter.grammars = grammarsAspect;
  den.aspects.applications.dev.lang.grammars = grammarsAspect;
}
