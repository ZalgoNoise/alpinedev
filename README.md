# alpinedev

_____

A Dockerized Alpine container with the needed toolchain to build and sign Alpine APK files, with `abuild`

_______

Your environment should be added to the `src`, `keys` and `build` folders on the same path as the Dockerfile / docker-compose file, as the container will reference them as volumes:

- `src` - your source code goes here, where you will need to place your APKBUILD file.
- `keys` - your APK keys will be linked from this folder to `~/.abuild/`. If you don't have any, you can add an empty folder and the keys will be generated automatically
- `build` - your build files' output directory

Also, you will need to define variables for the container's environment:
- `PASSWORD` - the Unix password for your users in the container, used in SSH.
- `NAME` - First/Last name combination to use when creating an `~/.abuild/abuild.conf` file
- `EMAIL` - Email address to use when creating an `~/.abuild/abuild.conf` file

Files linked into the container should keep their permissions, as the `apkdev` user will have the same UID/GID as the container executer.

`tmux` is installed with a new session spawned once the container launches, so that you don't need to keep a terminal window open while a large project compiles (thus the SSH service, as well). A few alias are already defined in `/etc/profile`:

Alias | Command
:--:|:--:
`tdev` | `tmux attach-session -t dev`
`tn` | `tmux new-session -As dev`
`tk` | `tmux kill-session -t dev`

_______


To deploy locally, clone the repository and review the software being installed, since it will result in a large image:


```
RUN apk add --update --no-cache \
    abuild \
    build-base \
    bash openjdk11 libarchive zip unzip g++ coreutils git \
    linux-headers protobuf python2 gcc bison flex texinfo gawk \
    gmp-dev mpfr-dev mpc1-dev zlib-dev libucontext-dev \
    gcc-gnat-bootstrap isl-dev \
    tmux zsh curl tzdata shadow procps ca-certificates openssh-server 
```

Once you've verified the software you need to install, build and run with docker-compose:

```
docker-compose up --build 
```

Or in the background:

```

docker-compose up -d --build 
```

Or via Docker:

```
APKPASSWD="secret"
NAME="APK Developer"
EMAIL="example@domain.com"

docker build -t alpinedev:1.0 . 

docker run -ti \
        -e PUID=$UID \
        -e PGID=$GID \
        -e NAME=$NAME \
        -e EMAIL=$EMAIL \
        -e PASSWORD=$APKPASSWD \
        -p 9922:22 \
        -v $(pwd)/src:/config/src \
        -v $(pwd)/keys:/config/.abuild \
        -v $(pwd)/build:/config/build \
        --name alpinedev \
        alpinedev:1.0


```