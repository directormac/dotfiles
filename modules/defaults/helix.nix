# Helix editor: modal editing with LSP and tree-sitter.
# Catppuccin Mocha theme, distinct cursor shapes per mode,
# and inline diagnostics on the cursor line.
{lib, ...}: {
  den.default.homeManager.programs.helix = {
    enable = true;
    shellWrapperName = "hx";
    settings = {
      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        inline-diagnostics = {
          cursor-line = "hint";
        };
      };
      theme = lib.mkDefault "catppuccin_mocha";
    };
  };
}
