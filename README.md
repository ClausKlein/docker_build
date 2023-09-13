## Usage example of CMake install `(RUNTIME_DEPENDENCY_SET ...)`

In our use case we build an C++ executable on `ubuntu 22.04` but with `gcc-13`.

It has to be delivered to [Linux Mint 20.1](https://linuxmint.com/download_all.php) with an older `libstd++` installed.

So we need to install all the required system runtime libraries too with our executable.


### This project is based [setup-cpp inside a docker build](https://github.com/aminya/setup-cpp#inside-docker).

See too [Docker Instructions](docker.md) and [Dockerfile](Dockerfile).
