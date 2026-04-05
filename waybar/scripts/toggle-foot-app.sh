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

if pgrep -f "$pattern" >/dev/null; then
    pkill -TERM -f "$pattern"
    exit 0
fi

exec foot -a "$app_id" -T "$title" "$@"
