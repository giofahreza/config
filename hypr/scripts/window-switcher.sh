#!/usr/bin/env bash
set -euo pipefail

selection=$(
  hyprctl -j clients | python3 -c '
import json
import sys

clients = json.load(sys.stdin)

def sort_key(client):
    return (client.get("focusHistoryID", 10**9), client.get("workspace", {}).get("id", 10**9))

for client in sorted((c for c in clients if c.get("mapped")), key=sort_key):
    workspace = client.get("workspace", {}).get("name", "?")
    app = client.get("class") or client.get("initialClass") or "app"
    title = client.get("title") or client.get("initialTitle") or app
    address = client.get("address", "")
    print(f"[{workspace}] {app} - {title}\t{address}")
' | fuzzel --dmenu --prompt="Switch> " --with-nth=1
)

[ -n "${selection:-}" ] || exit 0

address=${selection##*$'\t'}
[ -n "$address" ] || exit 0

exec hyprctl dispatch focuswindow "address:${address}"
