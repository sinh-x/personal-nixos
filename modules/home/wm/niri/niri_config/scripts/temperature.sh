#!/usr/bin/env bash

## Temperature reading script for waybar custom modules.
## Auto-discovers hwmon paths for CPU package and NVMe disk temperatures.
## Outputs JSON: {"text": "<value>°C", "class": "<normal|warning|critical>", "tooltip": "<source>: <temp>°C"}
##
## Usage: temperature.sh <cpu|disk>

set -euo pipefail

HWMON_DIR="/sys/class/hwmon"

# Map a millidegree Celsius value from hwmon temp*_input to a class.
class_for_temp() {
	local temp="$1"
	if (( temp >= 75000 )); then
		echo "critical"
	elif (( temp >= 60000 )); then
		echo "warning"
	else
		echo "normal"
	fi
}

# Discover the CPU package temperature sensor by scanning hwmon temp*_label
# for "Package id 0", "Tctl", or "CPU". Returns "<hwmon>/tempN_input <label>".
discover_cpu_sensor() {
	local hwmon label_file label input_file
	for hwmon in "$HWMON_DIR"/hwmon*; do
		[ -d "$hwmon" ] || continue
		for label_file in "$hwmon"/temp*_label; do
			[ -f "$label_file" ] || continue
			label=$(cat "$label_file" 2>/dev/null || true)
			case "$label" in
				"Package id 0"|"Tctl"|"CPU")
					input_file="${label_file%_label}_input"
					if [ -f "$input_file" ]; then
						echo "$input_file $label"
						return 0
					fi
					;;
			esac
		done
	done
	return 1
}

# Discover the NVMe disk temperature sensor by scanning hwmon entries whose
# device name is "nvme" for temp*_label "Composite" or "Sensor 1".
discover_nvme_sensor() {
	local hwmon hwmon_name label_file label input_file
	for hwmon in "$HWMON_DIR"/hwmon*; do
		[ -d "$hwmon" ] || continue
		hwmon_name=$(cat "$hwmon/name" 2>/dev/null || true)
		[ "$hwmon_name" = "nvme" ] || continue
		for label_file in "$hwmon"/temp*_label; do
			[ -f "$label_file" ] || continue
			label=$(cat "$label_file" 2>/dev/null || true)
			case "$label" in
				"Composite"|"Sensor 1")
					input_file="${label_file%_label}_input"
					if [ -f "$input_file" ]; then
						echo "$input_file $label"
						return 0
					fi
					;;
			esac
		done
	done
	return 1
}

# Emit waybar JSON for a discovered sensor.
emit_json() {
	local input_file="$1"
	local source_label="$2"
	local raw temp_c temp_str klass

	raw=$(cat "$input_file" 2>/dev/null || true)
	if [ -z "$raw" ]; then
		printf '{"text":"N/A","class":"normal","tooltip":"%s: unavailable"}\n' "$source_label"
		return 0
	fi

	temp_c=$(awk -v m="$raw" 'BEGIN { printf "%.0f", m / 1000 }')
	temp_str="${temp_c}°C"
	klass=$(class_for_temp "$raw")
	printf '{"text":"%s","class":"%s","tooltip":"%s: %s"}\n' \
		"$temp_str" "$klass" "$source_label" "$temp_str"
}

main() {
	local target="${1:-}"
	case "$target" in
		cpu)
			if read -r input_file label < <(discover_cpu_sensor); then
				emit_json "$input_file" "$label"
			else
				printf '{"text":"N/A","class":"normal","tooltip":"CPU: sensor not found"}\n'
			fi
			;;
		disk)
			if read -r input_file label < <(discover_nvme_sensor); then
				emit_json "$input_file" "NVMe $label"
			else
				printf '{"text":"N/A","class":"normal","tooltip":"NVMe: sensor not found"}\n'
			fi
			;;
		*)
			printf '{"text":"N/A","class":"normal","tooltip":"usage: temperature.sh <cpu|disk>"}\n' >&2
			return 1
			;;
	esac
}

main "$@"
