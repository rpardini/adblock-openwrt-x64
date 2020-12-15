FROM ubuntu:bionic as builder
ENV DEBIAN_FRONTEND=noninteractive

RUN date
RUN apt-get update -y
RUN apt-get install -y eatmydata g++ zlib1g-dev build-essential git-core rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget zlib1g-dev flex file automake bison patchelf findutils sudo squashfs-tools sudo time git-core subversion build-essential gcc-multilib libncurses5-dev zlib1g-dev gawk flex gettext wget unzip python3.8-dev
RUN apt-get clean

RUN adduser --disabled-password --gecos '' --shell /bin/bash --home /buildman buildman
RUN mkdir -p /openwrt
RUN chown buildman /openwrt
USER buildman

RUN whoami
RUN git clone --depth 1 --branch "openwrt-19.07" git://git.openwrt.org/openwrt/openwrt.git /openwrt
WORKDIR /openwrt

RUN scripts/feeds update -a
RUN scripts/feeds install -a

ADD files files
ADD config-c7v2 .config
RUN ls -la /openwrt/files /openwrt/.config
USER root
RUN chown -R buildman /openwrt/files /openwrt/.config
USER buildman

RUN make defconfig
RUN make download -j20

# there should be a toolchain-build intermediary.

RUN make -j8

RUN ls -laR /openwrt/bin

#FROM ubuntu:bionic
#COPY --from=builder /openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz /adblock-openwrt-x64.img.gz

# Now, build and get at the file, use:
#  Windows:
#    docker build -t adblock:latest .
#    docker create adblock:latest # Note the ID produced
#    docker cp <ID>:/adblock-openwrt-x64.img.gz .
#    docker rm <ID> -v


