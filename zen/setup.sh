#!/bin/sh
set -eu

if [ "$#" -gt 1 ]; then
  printf 'Usage: %s [Zen profile directory]\n' "$0" >&2
  exit 1
fi

zen_config_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
zen_profile=${1:-}

if [ -z "$zen_profile" ]; then
  case "$(uname -s)" in
    Darwin) zen_home="$HOME/Library/Application Support/zen" ;;
    Linux) zen_home="$HOME/.zen" ;;
    *) printf 'Pass the Zen profile directory explicitly on this platform.\n' >&2; exit 1 ;;
  esac

  if [ ! -f "$zen_home/profiles.ini" ]; then
    printf 'Open Zen once, or pass its profile directory explicitly.\n' >&2
    exit 1
  fi

  zen_profile=$(awk '
    { sub(/\r$/, "") }
    /^\[/ { section = $0 }
    /^Path=/ { paths[section] = substr($0, 6) }
    /^Default=/ {
      value = substr($0, 9)
      if (section ~ /^\[Install/ && install == "") install = value
      if (section ~ /^\[Profile/ && value == "1") selected = section
    }
    END { print (install != "" ? install : paths[selected]) }
  ' "$zen_home/profiles.ini")

  if [ -z "$zen_profile" ]; then
    printf 'No default Zen profile found. Pass its directory explicitly.\n' >&2
    exit 1
  fi

  case "$zen_profile" in
    /*) ;;
    *) zen_profile="$zen_home/$zen_profile" ;;
  esac
fi

if [ ! -d "$zen_profile" ]; then
  printf 'Zen profile does not exist: %s\n' "$zen_profile" >&2
  exit 1
fi

for zen_filename in customKeys.json user.js; do
  zen_source="$zen_config_dir/$zen_filename"
  zen_target="$zen_profile/$zen_filename"

  if [ ! -f "$zen_source" ]; then
    printf 'Zen config file does not exist: %s\n' "$zen_source" >&2
    exit 1
  fi

  if [ -L "$zen_target" ] && [ "$(readlink "$zen_target")" = "$zen_source" ]; then
    printf 'Zen config already linked: %s\n' "$zen_target"
    continue
  fi

  if [ -e "$zen_target" ] || [ -L "$zen_target" ]; then
    if [ -d "$zen_target" ]; then
      printf 'Refusing to replace a directory: %s\n' "$zen_target" >&2
      exit 1
    fi
    zen_backup="$zen_target.before-config-link-$(date +%Y%m%d-%H%M%S)"
    if [ -e "$zen_backup" ] || [ -L "$zen_backup" ]; then
      printf 'Backup already exists: %s\n' "$zen_backup" >&2
      exit 1
    fi
    mv "$zen_target" "$zen_backup"
    printf 'Previous config backed up: %s\n' "$zen_backup"
  fi

  ln -s "$zen_source" "$zen_target"
  printf 'Zen config linked: %s -> %s\n' "$zen_target" "$zen_source"
done

printf 'Restart Zen to load the configuration.\n'
