#!/bin/bash
docker run -it --rm \
    --name celery-worker \
    -v "$PWD":/usr/src/myapp \
    -w /usr/src/myapp python:3.11 \
    /bin/bash -c "pip install -r requirements.txt \
    && celery -A tasks worker -l INFO"
