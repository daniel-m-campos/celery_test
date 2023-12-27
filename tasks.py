from celery import Celery

REDIS_HOST = "redis://10.0.0.21:6379/0"

app = Celery("tasks", broker=REDIS_HOST, backend=REDIS_HOST)


@app.task
def hello():
    return "hello world"


@app.task
def add(a, b):
    return a + b
