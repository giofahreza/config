#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "usage: $0 <app-id> <title> [command ...]" >&2
    exit 1
fi

app_id=$1
title=$2
shift 2

pattern="foot -a ${app_id}"
foot_theme=(
    -o colors-dark.background=000000
    -o colors-dark.foreground=f5f5f5
    -o colors-dark.regular0=000000
    -o colors-dark.regular4=111111
    -o colors-dark.regular6=222222
    -o colors-dark.regular7=e5e5e5
    -o colors-dark.bright0=4a4a4a
    -o colors-dark.bright4=333333
    -o colors-dark.bright6=3a3a3a
    -o colors-dark.bright7=ffffff
)
newt_colors='root=white,black window=white,black border=white,black title=white,black textbox=white,black button=white,black actbutton=black,white compactbutton=white,black checkbox=white,black actcheckbox=black,white entry=white,black label=white,black listbox=white,black actlistbox=black,white sellistbox=white,black actsellistbox=black,white helpline=white,black roottext=white,black emptyscale=white,black fullscale=black,white disentry=gray,black'

if pgrep -f "$pattern" >/dev/null; then
    pkill -TERM -f "$pattern"
    exit 0
fi

exec foot "${foot_theme[@]}" -a "$app_id" -T "$title" env NEWT_COLORS="$newt_colors" "$@"
