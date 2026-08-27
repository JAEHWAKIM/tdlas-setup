#!/bin/bash

set_config_value() {
    local file=$1
    local key=$2
    local value=$3
    local separator=${4:-=}
    local temp_file

    if [ ! -f "$file" ]; then
        echo "Configuration file not found: $file" >&2
        return 1
    fi
    if [ -z "$key" ] || [[ "$key" == *$'\n'* || "$value" == *$'\n'* ]]; then
        echo "Invalid configuration key or value." >&2
        return 1
    fi

    temp_file=$(mktemp)
    if ! awk -v target_key="$key" -v target_value="$value" -v separator="$separator" '
        function trim(value) {
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            return value
        }

        {
            equals_at = index($0, "=")
            if (equals_at > 0) {
                current_key = trim(substr($0, 1, equals_at - 1))
                if (current_key == target_key) {
                    if (!updated) {
                        print target_key separator target_value
                        updated = 1
                    }
                    next
                }
            }
            print
        }

        END {
            if (!updated) {
                print target_key separator target_value
            }
        }
    ' "$file" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    if ! sudo tee "$file" < "$temp_file" >/dev/null; then
        rm -f "$temp_file"
        return 1
    fi
    rm -f "$temp_file"
    echo "Set $key in $file"
}
