# Codium / VSCode / Antigravity IDE Aspect Variants
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };
  };

  # Core shared configuration, settings, and extensions for VSCode/Codium variants
  den.aspects.applications.dev.editor.codium.core = {

    nixpkgs-overlays =
      _:
      lib.optionals (
        inputs ? nix-vscode-extensions
        && inputs.nix-vscode-extensions ? overlays
        && inputs.nix-vscode-extensions.overlays ? default
      ) [
        inputs.nix-vscode-extensions.overlays.default
      ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.prettier
        ];
      };

    codium-settings = [
      {
        "catppuccin-icons.hidesExplorerArrows" = false;
        "catppuccin-icons.specificFolders" = true;
        "catppuccin-icons.monochrome" = false;
        "chat.mcp.autostart" = "newAndOutdated";
        "claudeCode.preferredLocation" = "panel";
        "projectManager.git" = {
          baseFolders = [
            "~/Code"
          ];
          maxDepthRecursion = 5;
        };
        "cSpell.userWords" = [
          "shellcheck"
          "Vulkan"
          "Xwayland"
        ];
        "direnv.restart.automatic" = true;
        "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
        "editor.fontLigatures" = true;
        "editor.fontWeight" = "400";
        "editor.guides.bracketPairs" = true;
        "editor.guides.bracketPairsHorizontal" = true;
        "editor.inlineSuggest.enabled" = true;
        "editor.renderWhitespace" = "all";
        "editor.rulers" = [
          80
          120
        ];
        "editor.semanticHighlighting.enabled" = true;
        "explorer.confirmDragAndDrop" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.ignoreRecommendations" = true;
        "[xml]"."editor.defaultFormatter" = "DotJoshJohnson.xml";
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "git.openRepositoryInParentFolders" = "always";
        "github.copilot.chat.agent.thinkingTool" = true;
        "github.copilot.chat.codesearch.enabled" = true;
        "githubPullRequests.pullBranch" = "never";
        "partialDiff.enableTelemetry" = false;
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "telemetry.feedback.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.scrollback" = 10240;
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.cursorBlinking" = true;
        "update.mode" = "none";
        "vsicons.dontShowNewVersionMessage" = true;
        "workbench.tree.indent" = 20;
        "workbench.startupEditor" = "none";
        "workbench.editor.empty.hint" = "hidden";
      }
    ];

    codium-extensions =
      { pkgs, ... }:
      lib.optionals (pkgs ? vscode-marketplace) [
        pkgs.vscode-marketplace.aaron-bond.better-comments
        pkgs.vscode-marketplace.editorconfig.editorconfig
        pkgs.vscode-marketplace.esbenp.prettier-vscode
        # pkgs.vscode-marketplace.evan-buss.font-switcher
        pkgs.vscode-marketplace-release.github.copilot-chat
        pkgs.vscode-marketplace.alefragnani.project-manager
        pkgs.vscode-marketplace.catppuccin.catppuccin-vsc
        pkgs.vscode-marketplace.catppuccin.catppuccin-vsc-icons
        pkgs.vscode-marketplace.pkief.material-product-icons
        pkgs.vscode-marketplace.codezombiech.gitignore
        pkgs.vscode-marketplace.coolbear.systemd-unit-file
        pkgs.vscode-marketplace.dotjoshjohnson.xml
        pkgs.vscode-marketplace.github.vscode-github-actions
        pkgs.vscode-marketplace-release.github.vscode-pull-request-github
        pkgs.vscode-marketplace.hoovercj.vscode-power-mode
        pkgs.vscode-marketplace.oxc.oxc-vscode
        pkgs.vscode-marketplace.automatalabs.copilot-mcp
        # pkgs.vscode-marketplace.datakure.devenv
        pkgs.vscode-marketplace.mkhl.direnv
        pkgs.vscode-marketplace.nefrob.vscode-just-syntax
        pkgs.vscode-marketplace.jeff-hykin.better-csv-syntax
        pkgs.vscode-marketplace.jeff-hykin.better-dockerfile-syntax
        pkgs.vscode-marketplace.tobiashochguertel.just-formatter
        pkgs.vscode-marketplace.viktorzetterstrom.non-breaking-space-highlighter
        pkgs.vscode-marketplace.vscode-icons-team.vscode-icons
        pkgs.vscode-marketplace.jeroen-meijer.pubspec-assist
        pkgs.vscode-marketplace.mechatroner.rainbow-csv
        pkgs.vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
        pkgs.vscode-marketplace.nico-castell.linux-desktop-file
        pkgs.vscode-marketplace.redhat.vscode-yaml
        pkgs.vscode-marketplace.ryu1kn.partial-diff
        pkgs.vscode-marketplace.sanjulaganepola.github-local-actions
        pkgs.vscode-marketplace.saoudrizwan.claude-dev
        pkgs.vscode-marketplace.streetsidesoftware.code-spell-checker
        pkgs.vscode-marketplace.tamasfe.even-better-toml
        pkgs.vscode-marketplace.trond-snekvik.simple-rst
        pkgs.vscode-marketplace.zainchen.json
        pkgs.vscode-marketplace.eamodio.gitlens
      ];
  };

  # Antigravity IDE variant
  den.aspects.applications.dev.editor.codium.antigravity = {
    includes = [
      den.aspects.applications.dev.editor.codium.core
      (den.batteries.unfree [ "antigravity-ide" ])
    ];

    homeManagerModules = [
      (
        { ... }:
        {
          disabledModules = [ "programs/antigravity.nix" ];

          imports = [
            (import (inputs.home-manager.outPath + "/modules/programs/vscode/mkVscodeModule.nix") {
              modulePath = [
                "programs"
                "antigravity"
              ];
              name = "Antigravity IDE";
              packageName = "antigravity-ide";
              nameShort = "Antigravity IDE";
              dataFolderName = ".antigravity-ide";
              skipVersionCheck = true;
            })
          ];
        }
      )
    ];

    homeManager =
      {
        codium-settings ? [ ],
        codium-extensions ? [ ],
        lib,
        pkgs,
        ...
      }:
      let
        resolvedExtensions = lib.unique (
          lib.flatten (
            map (ext: if lib.isFunction ext then ext { inherit pkgs; } else ext) codium-extensions
          )
        );
      in
      {
        disabledModules = [ "programs/antigravity.nix" ];

        imports = [
          (import (inputs.home-manager.outPath + "/modules/programs/vscode/mkVscodeModule.nix") {
            modulePath = [
              "programs"
              "antigravity"
            ];
            name = "Antigravity IDE";
            packageName = "antigravity-ide";
            nameShort = "Antigravity IDE";
            dataFolderName = ".antigravity-ide";
            skipVersionCheck = true;
          })
        ];

        programs.antigravity = {
          enable = true;
          mutableExtensionsDir = false;
          profiles.default = {
            userSettings = lib.mkMerge codium-settings;
            extensions = resolvedExtensions;
          };
        };
      };

    persistHome = {
      directories = [
        ".antigravity-ide"
        ".config/Antigravity IDE"
      ];
    };
  };

  # Standard VSCode variant
  den.aspects.applications.dev.editor.codium.vscode = {
    includes = [
      den.aspects.applications.dev.editor.codium.core
    ];

    homeManager =
      {
        codium-settings ? [ ],
        codium-extensions ? [ ],
        lib,
        pkgs,
        ...
      }:
      let
        resolvedExtensions = lib.unique (
          lib.flatten (
            map (ext: if lib.isFunction ext then ext { inherit pkgs; } else ext) codium-extensions
          )
        );
      in
      {
        programs.vscode = {
          enable = true;
          mutableExtensionsDir = false;
          profiles.default = {
            userSettings = lib.mkMerge codium-settings;
            extensions = resolvedExtensions;
          };
        };
      };

    persistHome = {
      directories = [
        ".config/VSCodium"
        ".config/Code"
        ".vscode"
        ".vscode-oss"
        ".vscode-shared"
      ];
    };
  };

  # Default codium alias to vscode variant
  den.aspects.applications.dev.editor.codium.default =
    den.aspects.applications.dev.editor.codium.vscode;
}
