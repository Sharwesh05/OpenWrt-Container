# --- STAGE 1: Builder ---
FROM ubuntu:22.04 AS builder
ARG VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1
RUN apt update && apt upgrade -y
RUN apt install binutils-gold bison build-essential ccache ecj fastjar file flex g++ gawk gcc-arm* gettext git libbsd-dev libelf-dev libncurses-dev libssl-dev meson mold ninja-build pbzip2 pigz pkg-config python3-dev python3-setuptools rsync subversion swig time unzip wget xsltproc xxd zlib1g-dev zstd -y
WORKDIR /home/builder/openwrt

RUN git clone https://git.openwrt.org/openwrt/openwrt.git .
RUN git checkout openwrt-25.12

# Fetch the config from your GitHub repo
RUN curl -L "https://raw.githubusercontent.com/Sharwesh05/OpenWrt-Container/main/configs/${VERSION}.config" -o .config

# Prepare feeds and expand config
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
RUN make defconfig

# Kernel-Only Build: Download and Compile
RUN make download -j$(nproc) && \
    make -j$(nproc) V=s 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)" || true

# --- STAGE 2: Final Export ---
FROM alpine:latest
WORKDIR /output

# Copy only kernel binaries and the kmod packages
COPY --from=builder /home/builder/openwrt/bin/ /output/
COPY --from=builder /home/builder/openwrt/build.log /output/build.log

CMD ["ls", "-R", "/output"]