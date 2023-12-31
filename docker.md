## Docker Instructions

If you have [Docker](https://www.docker.com/) installed, you can run this
in your terminal:

```bash
docker build -f ./Dockerfile --tag=devcontainer:latest .
docker run -it --rm devcontainer:latest
docker create --name Hello devcontainer:latest
docker cp Hello:/home/app/stagedir.tar.gz Hello-ubuntu-v22.04.tgz
docker rm -f Hello
```

If may activate as `ENTRYPOINT ["/bin/bash"]` in Dockerfile and build it again.

```bash
docker run -it --rm devcontainer:latest
```

This command may put you in a `bash` session in a Ubuntu 22.04 Docker container,
with all of the build tools already installed.
Additionally, you will have `g++-13` installed as the default versions of `g++` .

You will be logged in as root, so you will see the `#` symbol as your prompt.
You will be in a directory that contains a copy of the `project`;
any changes you make to your local copy will not be updated in the Docker image
until you rebuild it.
If you need to mount your local copy directly in the Docker image, see
[Docker volumes docs](https://docs.docker.com/storage/volumes/).
TLDR:

```bash
docker run -it \
	-v absolute_path_on_host_machine:absolute_path_in_guest_container \
	devcontainer:latest
```

You can configure, build, and install using these command:

```bash
/home/app# cmake --workflow --preset Release
```
