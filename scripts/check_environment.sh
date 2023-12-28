#!/bin/bash -xe

if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

if ! docker info &>/dev/null; then
    echo "Docker is not running. Starting Docker..."
    sudo service docker start
fi

