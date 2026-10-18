# GitHub CLI Aspect
{
  den.aspects.applications.dev.git.github = {
    homeManager =
      { pkgs, ... }:
      {

        # Dont expose API keys to env vars
        # home.sessionVariablesExtra = ''
        #   if [ -f "${config.age.secrets.github_api_key.path}" ]; then
        #     export GITHUB_TOKEN="$(cat "${config.age.secrets.github_api_key.path}")"
        #     export GH_TOKEN="$GITHUB_TOKEN
        #     export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_TOKEN''${NIX_CONFIG:+ $NIX_CONFIG}"
        #     if [ ! -f "${config.home.homeDirectory}/.config/nix/nix.conf" ] || ! grep -q "extra-access-tokens" "${config.home.homeDirectory}/.config/nix/nix.conf" 2>/dev/null; then
        #       mkdir -p "${config.home.homeDirectory}/.config/nix"
        #       echo "extra-access-tokens = github.com=$GITHUB_TOKEN" > "${config.home.homeDirectory}/.config/nix/nix.conf"
        #       chmod 0600 "${config.home.homeDirectory}/.config/nix/nix.conf"
        #     fi
        #   fi
        # '';

        programs.gh = {
          settings.git_protocol = "ssh";
          enable = true;

          extensions = with pkgs; [
            gh-dash
            gh-f
            gh-s
            gh-stack
            gh-markdown-preview
          ];
        };

      };

    persistHome.directories = [
      ".config/gh"
      ".config/gh-dash"
    ];
  };
}
