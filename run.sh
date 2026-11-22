#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"

STAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORK/logs/run_${STAMP}.log"
mkdir -p "$WORK/backups" "$WORK/logs"

log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

dump_db() {
    local target_file="$1"
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB" -F c -Z "$COMPRESS_LEVEL" -f "$target_file"
}

run_task() {
file="$WORK/backups/${DB}_${STAMP}.dump"
dump_db "$file"
test -s "$file"
pg_restore --list "$file" > "$file.toc.txt"
log INFO "custom_archive=$file"
}

log INFO "Старт задачи резервного копирования БД=$DB"
run_task
log INFO "Задача успешно завершена (exit_code=0)"
