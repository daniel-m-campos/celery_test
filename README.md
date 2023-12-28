## Celery Test
This is a simple project to test setting up celery workers on a home network of MacBooks.

The hardest part of this, for me, was setting up the network and getting the various docker containers running
with the correct hosts/ports exposed.

The setup below shows how to do this manually and builds up to a `docker-compose` setup.

## Setup
### 1. Enable remote login on the worker MacBooks.
For each MacBook that you want to use as a worker, you need to enable remote login:
1. Open System Preferences.
2. Go to Sharing.
3. Enable Remote Login.
4. Add your user account to the list of allowed users.
5. Get the hostname. You should be able to use the `<computer-name>.local` hostname from machines on the local subnet.
6. Go to networks, configure IPv4 to use DHCP with manual address. Set the address to the previously assigned address. Otherwise you'll need to figure out a valid address to use.
7. Test that you can ssh into the machine from another machine on the network.
    ```shell
    ssh <user>@<hostname>
    ```
8. Setup rsa keys so that you don't need to enter a password every time you ssh into the machine.
    ```shell
    ssh-keygen -t rsa
    ssh-copy-id <user>@<hostname>
    ```

Get more help from ChatGPT [SSH & Remote Desktop Setup](https://chat.openai.com/share/9c078d24-3e47-474a-9296-ed6e7e587e13)

### 2. Launch Redis
On one of the MacBooks, launch `redis`.
```shell
docker run -p <host-ip>:6379:6379 --name REDIS -d redis
```
where `<host-ip>` is the subnet address of the host MacBook. This is a prerequisite for celery workers since they all coordinate in this setup with `redis`. This step can be bundled with the launch of a celery worker but then you'll need another script to launch celery workers on other MacBooks since there should only be one `redis` instance.

You can also use the `redis` container that is launched by `docker-compose` if you don't want 
to manually launch it. This will be explained in a later section.

#### 2.1 Test Redis
On a different MacBook, test that you can connect to the `redis` instance using:
```shell
redis-cli -h <host-ip> -p 6379 ping
```
This should return `PONG` if the connection is successful. `<host-ip>` is the subnet address of the host MacBook running `redis`. This requires that you have `redis-cli` installed on the MacBook that you're using to test the connection. You can install it with `brew install redis`.

### 3. Launch Celery Worker
On each MacBook, launch a celery worker.
```shell
docker run -it --rm \
    --name celery-worker \
    -w /usr/src/myapp python:3.11 \
    /bin/bash -c "pip install -r requirements.txt \
    && celery -A tasks worker -l INFO"
```
This is not ideal because it repeatedly pip installs for each celery worker. It's better to build a docker image with the dependencies installed and then launch the celery worker from that image.

#### 3.1. Alternatively, Build the Celery Docker Image and Run it
On each of the MacBooks that you want to use as a worker, build and the celery docker image and run it.
```shell
docker build -t celery-worker .
docker run -it --rm celery-worker
```

## Dockerfile
The `Dockerfile` is used to build the celery docker image. It installs the dependencies and sets the working directory to `/usr/src/myapp`. It also copies the `tasks.py` file into the image.

## Docker Compose
The follow two docker-compose files are used to launch `redis` and `celery-worker` containers:
1. `docker-compose.redis.yml`: This file is used to launch the `redis` and `celery-worker` containers. It also sets up the network so that the containers can communicate with each other. The `celery-worker` container is built from the `Dockerfile` in the current directory. You can optionally override the default `6379` redis port with the `REDIS_PORT` environment variable.
2. `docker-compose.celery-worker.yml`: This file is used to launch just a `celery-worker` container. You must proved `REDIS_HOST` and `REDIS_PORT` environment variables to the container so that it can connect to the `redis` instance. This is done in the `run_worker.sh` script.

## Scripts
The following scripts convienently check and launch the docker containers:
1. `scipts/run_redis_with_worker.sh`
1. `scipts/run_worker.sh`
