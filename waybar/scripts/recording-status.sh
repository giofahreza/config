#!/usr/bin/env bash

set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder-start"

if pgrep -x wf-recorder >/dev/null; then
    if [ -f "$state_file" ]; then
        start_time=$(cat "$state_file")
        now=$(date +%s)
        elapsed=$((now - start_time))
        if [ "$elapsed" -lt 0 ]; then
            elapsed=0
        fi
    else
        elapsed=0
    fi

    minutes=$((elapsed / 60))
    seconds=$((elapsed % 60))
    printf '{"text":"■ %02d:%02d","tooltip":"Recording in progress - click to stop","class":"recording"}\n' "$minutes" "$seconds"
else
    rm -f "$state_file"
    printf '{"text":"","tooltip":"","class":"idle"}\n'
fi
