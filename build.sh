#!/bin/bash

# 更新并安装依赖 https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntumint
sudo apt update -y
sudo apt install build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
    python3-setuptools rsync swig unzip zlib1g-dev file wget
sudo apt clean

ROOT_DIR=$PWD
LOG_FILE=$ROOT_DIR/build.log
rm -f $LOG_FILE

if [ ! -d "wrt/" ]; then
    echo "Cloning wrt..."
    git clone https://github.com/VIKINGYFY/immortalwrt --single-branch --depth 1 wrt/ || {
        echo "Failed to clone immortalwrt"
        exit 1
    }
fi
cd wrt/

# 更新并安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 安装自定义软件包
cd package/
$ROOT_DIR/Scripts/Packages.sh
$ROOT_DIR/Scripts/Handles.sh
cd ..

# 复制配置文件
cp -f $ROOT_DIR/ax6600.config .config
make defconfig -j$(nproc)

# 下载和编译
make download -j$(nproc) 2>&1 | tee "$LOG_FILE"
make -j$(nproc) V=s 2>&1 | tee "$LOG_FILE"
