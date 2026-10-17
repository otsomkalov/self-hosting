#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cron_entry="0 0 */14 * * /bin/bash \"$script_dir/clean-space.sh\""
current_crontab="$(crontab -l 2>/dev/null || true)"

if ! grep -Fqx -- "$cron_entry" <<< "$current_crontab"; then
  {
    if [[ -n "$current_crontab" ]]; then
      printf '%s\n' "$current_crontab"
    fi
    printf '%s\n' "$cron_entry"
  } | crontab -
fi