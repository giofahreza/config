#!/usr/bin/env bash

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if command -v blueman-manager >/dev/null 2>&1; then
    if pgrep -x blueman-manager >/dev/null 2>&1; then
        pkill -TERM -x blueman-manager
        exit 0
    fi

    exec blueman-manager
fi

if command -v gnome-control-center >/dev/null 2>&1; then
    if pgrep -x gnome-control-center >/dev/null 2>&1; then
        pkill -TERM -x gnome-control-center
        exit 0
    fi

    exec gnome-control-center bluetooth
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Bluetooth GUI not installed" "Install blueman with: sudo pacman -S blueman"
fi

exec "${script_dir}/toggle-foot-app.sh" \
    waybar-bluetooth \
    "Bluetooth Manager" \
    "${script_dir}/bluetooth-manager.sh"
