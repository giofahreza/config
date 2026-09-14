#!/usr/bin/env bash

set -euo pipefail

if pgrep -x pavucontrol >/dev/null 2>&1; then
    pkill -TERM -x pavucontrol
    exit 0
fi

exec pavucontrol
