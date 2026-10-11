#!/usr/bin/env bash
# =============================================================================
# update-neovim.sh
# Check and update Neovim flake inputs (blink-cmp, blink-lib) and GitHub plugins
# defined in nixos/modules/apps/neovim.nix in-place.
# =============================================================================
set -euo pipefail

# ANSI color codes
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

# Paths
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FLAKE_DIR="$REPO_ROOT/nixos"
FLAKE_LOCK="$FLAKE_DIR/flake.lock"
NEOVIM_NIX="$FLAKE_DIR/modules/apps/neovim.nix"

# Flags
CHECK_ONLY=false
AUTO_APPLY=false
CHECK_NIGHTLY=true
CHECK_BLINK=true
CHECK_PLUGINS=true

show_help() {
  echo -e "${BOLD}Usage:${RESET} update-nvim [OPTIONS]

${BOLD}Options:${RESET}
  -c, --check        Check for updates only without modifying files
  -y, --apply, --yes Apply updates immediately without prompting
  -n, --nightly      Check and update only Neovim nightly overlay
  -b, --blink        Check and update only Blink flake inputs (blink-cmp, blink-lib)
  -p, --plugins      Check and update only GitHub plugins in neovim.nix
  -h, --help         Show this help message

${BOLD}Examples:${RESET}
  update-nvim            # Check all (nightly, blink, plugins) and prompt to apply
  update-nvim --check    # Only view available updates and new hashes
  update-nvim --nightly  # Check and update only Neovim nightly overlay
  update-nvim --apply    # Automatically update all out-of-date inputs/plugins"
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--check)
      CHECK_ONLY=true
      shift
      ;;
    -y|--apply|--yes)
      AUTO_APPLY=true
      shift
      ;;
    -n|--nightly)
      CHECK_NIGHTLY=true
      CHECK_BLINK=false
      CHECK_PLUGINS=false
      shift
      ;;
    -b|--blink)
      CHECK_NIGHTLY=false
      CHECK_BLINK=true
      CHECK_PLUGINS=false
      shift
      ;;
    -p|--plugins)
      CHECK_NIGHTLY=false
      CHECK_BLINK=false
      CHECK_PLUGINS=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      show_help
      exit 1
      ;;
  esac
done

if [[ ! -f "$NEOVIM_NIX" ]]; then
  echo -e "${RED}Error: Cannot find neovim.nix at $NEOVIM_NIX${RESET}" >&2
  exit 1
fi

echo -e "${BOLD}${CYAN}🔍 Checking Neovim inputs and plugins...${RESET}\n"

TOTAL_UPDATES=0
FLAKE_UPDATE_LIST=()

# =============================================================================
# 1. Check Flake Inputs (neovim-nightly-overlay, blink-cmp, blink-lib)
# =============================================================================
FLAKE_INPUTS=()
if [[ "$CHECK_NIGHTLY" = true ]]; then
  FLAKE_INPUTS+=("neovim-nightly-overlay:nix-community:neovim-nightly-overlay")
fi
if [[ "$CHECK_BLINK" = true ]]; then
  FLAKE_INPUTS+=("blink-cmp:saghen:blink.cmp" "blink-lib:saghen:blink.lib")
fi

if [[ "${#FLAKE_INPUTS[@]}" -gt 0 ]] && [[ -f "$FLAKE_LOCK" ]]; then
  echo -e "${BOLD}📦 Flake Inputs (flake.lock):${RESET}"

  for entry in "${FLAKE_INPUTS[@]}"; do
    IFS=":" read -r input_name owner repo <<< "$entry"

    cur_rev=$(jq -r --arg name "$input_name" '.nodes[$name].locked.rev // empty' "$FLAKE_LOCK" 2>/dev/null || true)
    if [[ -z "$cur_rev" ]]; then
      echo -e "  ${YELLOW}• $input_name:${RESET} not found in flake.lock"
      continue
    fi
    cur_short="${cur_rev:0:8}"

    # Query upstream
    upstream_json=$(nix eval --impure --refresh --json --expr "
      let
        t = builtins.fetchTree { type = \"github\"; owner = \"$owner\"; repo = \"$repo\"; };
        d = t.lastModifiedDate;
      in {
        rev = t.rev;
        shortRev = t.shortRev;
        date = \"\${builtins.substring 0 4 d}-\${builtins.substring 4 2 d}-\${builtins.substring 6 2 d}\";
      }
    " 2>/dev/null || true)

    if [[ -z "$upstream_json" ]]; then
      echo -e "  ${RED}• $input_name:${RESET} failed to query upstream ($owner/$repo)"
      continue
    fi

    new_rev=$(echo "$upstream_json" | jq -r '.rev')
    new_short=$(echo "$upstream_json" | jq -r '.shortRev')
    new_date=$(echo "$upstream_json" | jq -r '.date')

    if [[ "$cur_rev" == "$new_rev" ]]; then
      echo -e "  ${GREEN}✓${RESET} ${BOLD}$input_name${RESET} ${DIM}($cur_short, $new_date)${RESET}: ${GREEN}UP-TO-DATE${RESET}"
    else
      echo -e "  ${YELLOW}▲${RESET} ${BOLD}$input_name${RESET}: ${YELLOW}UPDATE AVAILABLE${RESET}"
      echo -e "      Current:  ${DIM}$cur_short${RESET}"
      echo -e "      Upstream: ${GREEN}$new_short${RESET} ${DIM}($new_date)${RESET}"
      FLAKE_UPDATE_LIST+=("$input_name")
      ((TOTAL_UPDATES++)) || true
    fi
  done
  echo ""
fi

# =============================================================================
# 2. Check GitHub Plugins in neovim.nix
# =============================================================================
PLUGIN_UPDATES_JSON="[]"

if [[ "$CHECK_PLUGINS" = true ]]; then
  echo -e "${BOLD}🧩 GitHub Plugins (${NEOVIM_NIX##*/}):${RESET}"

  # Scan neovim.nix for all fetchFromGitHub blocks using Perl
  RAW_PLUGINS=$(perl -0777 -e '
    use strict;
    use warnings;
    use JSON::PP;

    my $file = $ARGV[0];
    open my $fh, "<", $file or die $!;
    my $content = do { local $/; <$fh> };
    close $fh;

    my @plugins;
    while ($content =~ /(?:pname\s*=\s*"([^"]+)";\s*)?(?:version\s*=\s*"([^"]+)";\s*)?src\s*=\s*pkgs\.fetchFromGitHub\s*\{\s*owner\s*=\s*"([^"]+)";\s*repo\s*=\s*"([^"]+)";\s*rev\s*=\s*"([^"]+)";\s*hash\s*=\s*"([^"]+)";/g) {
      my $pname = $1 // $4;
      my $version = $2 // "";
      my ($owner, $repo, $rev, $hash) = ($3, $4, $5, $6);
      push @plugins, {
        pname => $pname,
        version => $version,
        owner => $owner,
        repo => $repo,
        rev => $rev,
        hash => $hash
      };
    }
    print encode_json(\@plugins);
  ' "$NEOVIM_NIX")

  PLUGIN_COUNT=$(echo "$RAW_PLUGINS" | jq '. | length')

  if [[ "$PLUGIN_COUNT" -eq 0 ]]; then
    echo -e "  ${DIM}No GitHub-sourced plugins found in $NEOVIM_NIX${RESET}"
  else
    for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
      pname=$(echo "$RAW_PLUGINS" | jq -r ".[$i].pname")
      version=$(echo "$RAW_PLUGINS" | jq -r ".[$i].version")
      owner=$(echo "$RAW_PLUGINS" | jq -r ".[$i].owner")
      repo=$(echo "$RAW_PLUGINS" | jq -r ".[$i].repo")
      cur_rev=$(echo "$RAW_PLUGINS" | jq -r ".[$i].rev")
      cur_hash=$(echo "$RAW_PLUGINS" | jq -r ".[$i].hash")
      cur_short="${cur_rev:0:8}"

      # Query upstream rev and narHash
      upstream_json=$(nix eval --impure --refresh --json --expr "
        let
          t = builtins.fetchTree { type = \"github\"; owner = \"$owner\"; repo = \"$repo\"; };
          d = t.lastModifiedDate;
        in {
          rev = t.rev;
          shortRev = t.shortRev;
          hash = t.narHash;
          date = \"\${builtins.substring 0 4 d}-\${builtins.substring 4 2 d}-\${builtins.substring 6 2 d}\";
        }
      " 2>/dev/null || true)

      if [[ -z "$upstream_json" ]]; then
        echo -e "  ${RED}• $pname ($owner/$repo):${RESET} failed to query upstream"
        continue
      fi

      new_rev=$(echo "$upstream_json" | jq -r '.rev')
      new_short=$(echo "$upstream_json" | jq -r '.shortRev')
      new_hash=$(echo "$upstream_json" | jq -r '.hash')
      new_date=$(echo "$upstream_json" | jq -r '.date')

      if [[ "$cur_rev" == "$new_rev" ]]; then
        echo -e "  ${GREEN}✓${RESET} ${BOLD}$pname${RESET} ${DIM}($owner/$repo, $cur_short)${RESET}: ${GREEN}UP-TO-DATE${RESET}"
      else
        echo -e "  ${YELLOW}▲${RESET} ${BOLD}$pname${RESET} ${DIM}($owner/$repo)${RESET}: ${YELLOW}UPDATE AVAILABLE${RESET}"
        echo -e "      Current:  ${DIM}$cur_short${RESET} ${DIM}($version)${RESET}"
        echo -e "      Upstream: ${GREEN}$new_short${RESET} ${DIM}(unstable-$new_date)${RESET}"
        echo -e "      New Hash: ${CYAN}$new_hash${RESET}"

        # Append to updates array
        PLUGIN_UPDATES_JSON=$(jq -c \
          --arg pname "$pname" \
          --arg owner "$owner" \
          --arg repo "$repo" \
          --arg cur_rev "$cur_rev" \
          --arg cur_hash "$cur_hash" \
          --arg new_rev "$new_rev" \
          --arg new_hash "$new_hash" \
          --arg new_date "$new_date" \
          '. += [{ pname: $pname, owner: $owner, repo: $repo, cur_rev: $cur_rev, cur_hash: $cur_hash, new_rev: $new_rev, new_hash: $new_hash, new_date: $new_date }]' \
          <<< "$PLUGIN_UPDATES_JSON")

        ((TOTAL_UPDATES++)) || true
      fi
    done
  fi
  echo ""
fi

# =============================================================================
# 3. Summary & Apply Logic
# =============================================================================
if [[ "$TOTAL_UPDATES" -eq 0 ]]; then
  echo -e "${BOLD}${GREEN}✨ Everything is up-to-date! No changes needed.${RESET}"
  exit 0
fi

echo -e "${BOLD}Summary:${RESET} ${YELLOW}$TOTAL_UPDATES update(s) available.${RESET}"

if [[ "$CHECK_ONLY" = true ]]; then
  echo -e "${DIM}Check mode: No changes made. Run 'update-nvim' to apply.${RESET}"
  exit 0
fi

# Ask for confirmation if not auto-apply
if [[ "$AUTO_APPLY" = false ]]; then
  read -r -p "Apply these updates now? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${DIM}Cancelled. No changes made.${RESET}"
    exit 0
  fi
fi

echo ""

# Apply Flake updates
if [[ "${#FLAKE_UPDATE_LIST[@]}" -gt 0 ]]; then
  echo -e "${BOLD}${CYAN}📦 Updating flake inputs in $FLAKE_LOCK...${RESET}"
  nix flake update "${FLAKE_UPDATE_LIST[@]}" --flake "$FLAKE_DIR"
  echo -e "${GREEN}✓ Updated flake inputs: ${FLAKE_UPDATE_LIST[*]}${RESET}\n"
fi

# Apply neovim.nix updates
PLUGIN_UPDATE_COUNT=$(echo "$PLUGIN_UPDATES_JSON" | jq '. | length')
if [[ "$PLUGIN_UPDATE_COUNT" -gt 0 ]]; then
  echo -e "${BOLD}${CYAN}🧩 Updating neovim.nix in-place...${RESET}"

  perl -0777 -i -e '
    use strict;
    use warnings;
    use JSON::PP;

    my $updates_file = $ARGV[0];
    my $target_file = $ARGV[1];

    open my $ufh, "<", $updates_file or die $!;
    my $updates_raw = do { local $/; <$ufh> };
    close $ufh;
    my $updates = decode_json($updates_raw);

    open my $tfh, "<", $target_file or die $!;
    my $content = do { local $/; <$tfh> };
    close $tfh;

    for my $u (@$updates) {
      my $owner = quotemeta($u->{owner});
      my $repo = quotemeta($u->{repo});
      my $cur_rev = quotemeta($u->{cur_rev});
      my $cur_hash = quotemeta($u->{cur_hash});

      my $new_rev = $u->{new_rev};
      my $new_hash = $u->{new_hash};
      my $new_date = $u->{new_date};

      # 1. Update version date if present
      $content =~ s/(version\s*=\s*)"unstable-[^"]+";(\s*src\s*=\s*pkgs\.fetchFromGitHub\s*\{\s*owner\s*=\s*"$owner";\s*repo\s*=\s*"$repo";)/${1}"unstable-$new_date";${2}/s;

      # 2. Update rev and hash
      $content =~ s/(owner\s*=\s*"$owner";\s*repo\s*=\s*"$repo";\s*rev\s*=\s*)"$cur_rev";(\s*hash\s*=\s*)"$cur_hash";/${1}"$new_rev";${2}"$new_hash";/s;

      print "✓ Updated " . $u->{pname} . "\n";
    }

    open my $wfh, ">", $target_file or die $!;
    print $wfh $content;
    close $wfh;
  ' <(echo "$PLUGIN_UPDATES_JSON") "$NEOVIM_NIX"

  echo -e "${GREEN}✓ Updated $PLUGIN_UPDATE_COUNT plugin(s) in $NEOVIM_NIX${RESET}\n"
fi

echo -e "${BOLD}${GREEN}✨ Done! All updates successfully applied.${RESET}"
