FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1
RUN apt update && apt upgrade -y
RUN apt install binutils-gold bison build-essential ccache ecj fastjar file flex g++ gawk gcc-arm* gettext git libbsd-dev libelf-dev libncurses-dev libssl-dev meson mold ninja-build pbzip2 pigz pkg-config python3-dev python3-setuptools rsync subversion swig time unzip wget xsltproc xxd zlib1g-dev zstd -y
WORKDIR /home/builder/openwrt
RUN git clone https://git.openwrt.org/openwrt/openwrt.git .
RUN git checkout openwrt-25.12
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
