import os

from celery import Celery

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = os.getenv("REDIS_PORT", "6379")
BROKER_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}/0"

app = Celery("tasks", broker=BROKER_URL, backend=BROKER_URL)


@app.task
def hello():
    return "hello world"


@app.task
def add(a, b):
    return a + b
