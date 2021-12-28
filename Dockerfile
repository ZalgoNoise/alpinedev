FROM alpine:edge

RUN apk add --update --no-cache \
    abuild \
    build-base \
    bash openjdk11 libarchive zip unzip g++ coreutils git \
    linux-headers protobuf python2 gcc bison flex texinfo gawk \
    gmp-dev mpfr-dev mpc1-dev zlib-dev libucontext-dev \
    sudo \
    gcc-gnat-bootstrap isl-dev \
    tmux zsh curl tzdata shadow procps ca-certificates openssh-server 

RUN echo "alias tdev='tmux attach-session -t dev'" >> /etc/profile \
    && echo "alias tn='tmux new-session -As dev'" >> /etc/profile \
    && echo "alias tk='tmux kill-session -t dev'" >> /etc/profile 

RUN usermod -s /bin/zsh root \
  && echo -e '# Pathnames of valid login shells.\n# See shells(5) for details.\n\n/bin/zsh' > /etc/shells \
  && mkdir -p /config  \
  && groupmod -g 1000 users \
  && useradd -u 1005 -U -d /config -s /bin/zsh apkdev \
  && usermod -G abuild apkdev \
  && echo 'apkdev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
  && /usr/bin/ssh-keygen -A \
  && ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key 

EXPOSE 22

COPY init /init
ENTRYPOINT [ "/init" ]