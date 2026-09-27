{
  den,
  lib,
  ...
}: {
  # ===========================================================================
  # 1. THE ASPECT (CONFIGURATION DATA)
  # ===========================================================================
  # GUIDELINE: Use aspects purely for storing data and configuration.
  # Do not put complex functional logic (like pkgs.runCommand or mkDerivation)
  # inside the aspect itself. Keep it clean and declarative!
  #
  # If you want to share a theme, you would simply add:
  # includes = [ den.aspects.my-base16-theme ];
  den.aspects.terminal.kitty = {
    kitty = {
      dynamicMode = false;
      dynamicConfigPath = "$HOME/.config/kitty/kitty.conf";
      shell = "";

      keybindings = {
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "ctrl+shift+w" = "close_tab";
        "ctrl+t" = "new_tab_with_cwd";
        "ctrl+shift+t" = "new_tab";
      };

      settings = {
        enable_audio_bell = "no";
        font_size = 15;
        font_family = "Fira Mono Nerd Font";
        cursor_text_color = "background";
        allow_remote_control = "yes";
        shell_integration = "enabled";
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        cursor_trail_color = "#94e2d5";
      };
    };
  };

  # ===========================================================================
  # 2. THE BUILDER (LOGIC & WRAPPING)
  # ===========================================================================
  # GUIDELINE: Place your wrapper logic in `den.lib.<name>.package`.
  # This function takes the configuration from the aspect (resolved via den.lib.aspects.resolve)
  # and turns it into a concrete derivation.
  # This entirely replaces the need for heavyweight "wrapper-modules".
  den.lib.kitty.package = pkgs: kittyAspect: ctx: let
    # Resolve the `kitty` class attributes from the provided aspect
    aspect = den.lib.parametric.fixedTo ctx {
      includes = [kittyAspect];
    };
    module = den.lib.aspects.resolve "kitty" aspect;

    # Generate the kitty.conf configuration file from settings & keybindings
    configText = ''
      # Generated Kitty Settings
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} ${toString v}") (module.settings or {}))}

      # Generated Keybindings
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "map ${k} ${v}") (module.keybindings or {}))}
    '';

    configFile = pkgs.writeText "kitty.conf" configText;

    # Implement dynamicMode logic
    extraArgs =
      if (module.dynamicMode or false)
      then "--config ${module.dynamicConfigPath}"
      else "--config ${configFile}";

    shellArg =
      if (module.shell or "") != ""
      then module.shell
      else "";
  in
    pkgs.symlinkJoin {
      name = "kitty-wrapped";
      paths = [pkgs.kitty];
      buildInputs = [pkgs.makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/kitty \
          --add-flags "${extraArgs} ${shellArg}"
      '';

      # Tell `nix run` what executable to launch
      meta.mainProgram = "kitty";
    };

  # ===========================================================================
  # 3. EXPORTING THE PACKAGES (FLAKE-PARTS)
  # ===========================================================================
  # GUIDELINE: Use perSystem to seamlessly export the package to all architectures.
  # You can dynamically inject overrides (like dynamicMode = true) directly into the
  # aspect at build time using `includes`!
  perSystem = {pkgs, ...}: let
    buildKitty = den.lib.kitty.package pkgs;
  in {
    # 1. The default static package
    packages.kitty = buildKitty den.aspects.terminal.kitty {};

    # 2. The dynamic package (overriding dynamicMode to true!)
    packages.kittyDynamic = buildKitty {
      includes = [den.aspects.terminal.kitty];
      kitty.dynamicMode = true;
    } {};
  };
}
