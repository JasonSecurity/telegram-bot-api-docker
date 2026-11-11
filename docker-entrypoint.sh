#!/bin/sh
set -eu

work_dir="${TELEGRAM_WORK_DIR:-/var/lib/telegram-bot-api}"
temp_dir="${TELEGRAM_TEMP_DIR:-/tmp/telegram-bot-api}"
http_port="${TELEGRAM_HTTP_PORT:-8081}"

mkdir -p "$work_dir" "$temp_dir"

exec /usr/local/bin/telegram-bot-api \
  --local \
  --http-port="$http_port" \
  --dir="$work_dir" \
  --temp-dir="$temp_dir" \
  "$@"
