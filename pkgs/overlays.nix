# This file defines overlays
{ inputs, ... }: {
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    collie =
      if
        inputs ? llm-agents && (inputs.llm-agents.packages.${final.stdenv.hostPlatform.system} ? collie)
      then
        inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.collie
      else
        final.callPackage ./by-name/collie/package.nix { };

    # khal in nixpkgs declares `sphinxBuilders = [ "html" "man" ];`.
    # In nixpkgs with structuredAttrs enabled, bash arrays in .attrs.sh
    # cause sphinx-hook's `eval "__sphinxBuilders=($sphinxBuilders)"` to
    # expand only the first element `${sphinxBuilders[0]}` ("html"),
    # skipping the "man" builder entirely so the 'man' output is never produced.
    # Setting sphinxBuilders to a string ensures both builders are run.
    khal = prev.khal.overrideAttrs {
      sphinxBuilders = "html man";
    };

    mermaid-cli =
      if inputs ? mermaid-rs-renderer then
        final.symlinkJoin {
          name = "mermaid-cli-${final.mermaid-rs-renderer.version or "rs"}";

          paths = [
            final.mermaid-rs-renderer
            (final.writeShellScriptBin "mmdc" ''
              set -euo pipefail

              args=()
              format="svg"

              while [[ $# -gt 0 ]]; do
                case "$1" in
                  -o|--output)
                    output="$2"
                    args+=("$1" "$2")
                    if [[ "$output" == *.png ]]; then
                      format="png"
                    elif [[ "$output" == *.svg ]]; then
                      format="svg"
                    fi
                    shift 2
                    ;;
                  -o=*|--output=*)
                    output="''${1#*=}"
                    args+=("$1")
                    if [[ "$output" == *.png ]]; then
                      format="png"
                    elif [[ "$output" == *.svg ]]; then
                      format="svg"
                    fi
                    shift
                    ;;
                  -e|--outputFormat)
                    format="$2"
                    shift 2
                    ;;
                  -e=*|--outputFormat=*)
                    format="''${1#*=}"
                    shift
                    ;;
                  -b|--backgroundColor)
                    shift 2
                    ;;
                  -b=*|--backgroundColor=*)
                    shift
                    ;;
                  -s|--scale)
                    shift 2
                    ;;
                  -s=*|--scale=*)
                    shift
                    ;;
                  *)
                    args+=("$1")
                    shift
                    ;;
                esac
              done

              exec "${final.mermaid-rs-renderer}/bin/mmdr" -e "$format" "''${args[@]}"
            '')
          ];

          meta = (final.mermaid-rs-renderer.meta or { }) // {
            mainProgram = "mmdc";
          };
        }
      else
        prev.mermaid-cli;

    mermaid-rs-renderer =
      if inputs ? mermaid-rs-renderer then
        inputs.mermaid-rs-renderer.packages.${final.stdenv.hostPlatform.system}.default
      else
        prev.mermaid-cli;

    mmdr = final.mermaid-rs-renderer;
    nixfmt = inputs.nixfmt-rs.packages.${final.stdenv.hostPlatform.system}.default or prev.nixfmt;
    nixfmt-rfc-style = final.nixfmt;
    zsh-histdb-src = inputs.zsh-histdb-src or null;
  };

  # Thread the gen-lsp flake source to pkgs-by-name so pkgs/by-name/gen-lsp-mcp
  # can take `gen-lsp-src` as a callPackage arg and build the mcp/ subdir
  # hermetically (from the locked gen-lsp input, not a re-export of its package).
  # gen-lsp-src = _final: _prev: {
  #   gen-lsp-src = inputs.gen-lsp;
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
