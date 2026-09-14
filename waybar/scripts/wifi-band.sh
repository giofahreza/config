#!/usr/bin/env bash

set -u

json_escape() {
    local value=${1:-}
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    printf '%s' "$value"
}

connection=$(nmcli -t -f DEVICE,TYPE,STATE dev status | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')

if [[ -z "${connection:-}" ]]; then
    printf '{"text":"","tooltip":"Wi-Fi disconnected","class":"disconnected"}\n'
    exit 0
fi

wifi_info=$(nmcli -t -f ACTIVE,SSID,CHAN,FREQ dev wifi list ifname "$connection" 2>/dev/null | awk -F: '$1 == "yes" { print; exit }')

if [[ -z "${wifi_info:-}" ]]; then
    printf '{"text":"wifi ?","tooltip":"Wi-Fi band unavailable","class":"unknown"}\n'
    exit 0
fi

IFS=: read -r _ ssid chan freq_text <<< "$wifi_info"

freq=${freq_text%% *}

if [[ ! "$freq" =~ ^[0-9]+$ ]]; then
    printf '{"text":"wifi ?","tooltip":"Wi-Fi frequency unavailable","class":"unknown"}\n'
    exit 0
fi

if (( freq >= 2400 && freq < 2500 )); then
    band="2.4GHz"
    freq="2.4 GHz"
    class="band-24"
elif (( freq >= 4900 && freq < 5900 )); then
    band="5GHz"
    freq="5 GHz"
    class="band-5"
elif (( freq >= 5925 && freq < 7125 )); then
    band="6GHz"
    freq="6 GHz"
    class="band-6"
else
    band="?GHz"
    freq="unknown"
    class="unknown"
fi

tooltip="Wi-Fi: ${ssid:-unknown}\nInterface: $connection\nBand: $freq\nFrequency: $freq_text\nChannel: $chan"

printf '{"text":"%s wifi","tooltip":"%s","class":"%s"}\n' \
    "$(json_escape "$band")" \
    "$(json_escape "$tooltip")" \
    "$(json_escape "$class")"
