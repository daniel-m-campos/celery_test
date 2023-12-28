#!/bin/bash -xe

SCRIPT_DIR=$(dirname "$0")
"$SCRIPT_DIR/check_environment.sh"

if [[ -z "${REDIS_HOST}" || -z "${REDIS_PORT}" ]]; then
    echo "REDIS_HOST or REDIS_PORT environment variables are not set."
    exit 1
fi

docker-compose -f "$SCRIPT_DIR"/../docker-compose.celery-worker.yml up --build --remove-orphans
