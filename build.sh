#! /bin/bash

set -e

BASEDIR=~/openwrt

OPENWRT=${BASEDIR}/openwrt
REPO=${BASEDIR}/tplinkc7v2

if [[ ! -d ${OPENWRT} ]]; then
  echo "Clone repo first..."
  git clone --single-branch --branch "openwrt-19.07" git://git.openwrt.org/openwrt/openwrt.git ${OPENWRT}
  echo "Feeds..."
  cd ${OPENWRT}
  scripts/feeds update -a
  scripts/feeds install -a
else
  echo "Repo already there!"
fi

echo "Git Pulling..."
cd ${REPO}
git pull

echo "Copying static files"...
cp -vrp ${REPO}/files/* ${OPENWRT}/files/
cp -p ${REPO}/config-c7v2 ${OPENWRT}/.config
cp -p ${REPO}/config-c7v2 ${REPO}/config-c7v2.pre-diff

echo "Prepare for Building..."
cd ${OPENWRT}

make download -j20
make defconfig

if [[ "$1" == "config" ]]; then
  echo "Menuconfig as requested..."
fi

echo "New diff config..."
scripts/diffconfig.sh >${REPO}/config-c7v2
cp .config ${REPO}/config-c7v2-full

echo "Building..."
make -j9 || make -j1 V=s

echo "Deploy at TFTP server via sudo..."
sudo cp -v ${OPENWRT}/bin/targets/ar71xx/generic/openwrt-ar71xx-generic-archer-c7-v2-squashfs-factory.bin /srv/tftp/ArcherC7v2_tp_recovery.bin


echo "Git Commit/push..."
cd ${REPO}
git add .
git commit -m 'build'
git push


echo "Done!"
