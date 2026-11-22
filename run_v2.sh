#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
source "$SCRIPT_DIR/config.env"

STAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORK/logs/run_${STAMP}.log"
KEEP_BACKUPS=3
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
test -s "$file.toc.txt"
sha256sum "$file" > "$file.sha256"
log INFO "custom_archive=$file"
log INFO "sha256_manifest=$(cat "$file.sha256")"
}

rotate_backups() {
    local old_files
    old_files=$(ls -1t "$WORK/backups/${DB}_"*.dump 2>/dev/null | tail -n +$((KEEP_BACKUPS + 1)) || true)
    if [[ -n "$old_files" ]]; then
        for f in $old_files; do
            rm -f "$f" "$f.toc.txt" "$f.sha256"
            log INFO "Ротация: удалён устаревший архив $f"
        done
    fi
}

log INFO "Старт задачи резервного копирования БД=$DB (с контролем SHA-256 и ротацией)"
run_task
rotate_backups
log INFO "Задача успешно завершена (exit_code=0)"
