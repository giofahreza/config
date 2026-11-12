#!/bin/sh
set -eu

window_id=${1:?missing window id}
target=${2:?missing destination index}

case "$target" in
  ''|*[!0-9]*)
    tmux display-message "Destination must be a window number"
    exit 1
    ;;
esac

# Window indexes in this config start at 1 and are renumbered without gaps.
[ "$target" -ge 1 ] || {
  tmux display-message "Destination must be 1 or greater"
  exit 1
}

read -r session_id source <<EOF_INFO
$(tmux display-message -p -t "$window_id" '#{session_id} #{window_index}')
EOF_INFO
count=$(tmux list-windows -t "$session_id" | wc -l | tr -d ' ')
[ "$target" -le "$count" ] || {
  tmux display-message "Destination must be between 1 and $count"
  exit 1
}

if [ "$source" -lt "$target" ]; then
  i=$((source + 1))
  while [ "$i" -le "$target" ]; do
    tmux swap-window -s "$window_id" -t "$session_id:$i"
    i=$((i + 1))
  done
elif [ "$source" -gt "$target" ]; then
  i=$((source - 1))
  while [ "$i" -ge "$target" ]; do
    tmux swap-window -s "$window_id" -t "$session_id:$i"
    i=$((i - 1))
  done
fi
