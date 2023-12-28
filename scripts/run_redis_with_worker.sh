#!/bin/bash -xe

SCRIPT_DIR=$(dirname "$0")
"$SCRIPT_DIR/check_environment.sh"

docker-compose -f "$SCRIPT_DIR"/../docker-compose.redis.yml up --build --remove-orphans
