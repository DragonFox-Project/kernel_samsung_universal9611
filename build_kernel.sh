#/bin/bash
set -e

[ ! -e "scripts/packaging/pack.sh" ] && git submodule init && git submodule update
[ ! -d "toolchain" ] && echo "Make toolchain avaliable at $(pwd)/toolchain" && exit

export KBUILD_BUILD_USER=DragonFox
export KBUILD_BUILD_HOST=GrassLand

PATH=$PWD/toolchain/bin:$PATH

if [ "$1" = "oneui" ]; then
FLAGS=ONEUI=1
else
CONFIG_AOSP=vendor/aosp.config
fi

if [ "$2" = "ksu" ]; then
CONFIG_KSU=vendor/ksu.config
fi

if [ "$3" = "permissive" ]; then
CONFIG_SELINUX=vendor/permissive.config
fi

if [ -z "$DEVICE" ]; then
export DEVICE=a51
fi

rm -rf out
make O=out CROSS_COMPILE=aarch64-linux-gnu- CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar \
	OBJDUMP=llvm-objdump READELF=llvm-readelf -j$(nproc) \
	vendor/${DEVICE}_defconfig vendor/grass.config vendor/${DEVICE}.config $CONFIG_AOSP $CONFIG_KSU ${CONFIG_SELINUX}
make O=out CROSS_COMPILE=aarch64-linux-gnu- CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar \
	OBJDUMP=llvm-objdump READELF=llvm-readelf ${FLAGS} -j$(nproc)
