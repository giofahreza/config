#!/usr/bin/env bash

set -euo pipefail

printf 'Bluetooth controls\n'
printf 'Useful commands: scan on, devices, pair <MAC>, trust <MAC>, connect <MAC>, remove <MAC>\n\n'
printf 'Preparing adapter...\n'
printf 'power on\nagent on\ndefault-agent\npairable on\n' | bluetoothctl >/dev/null

exec bluetoothctl
