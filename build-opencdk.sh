#!/bin/sh

# Automatic build script for OpenCDK (Open Crypto Development Kit) library  (http://savannah.nongnu.org/projects/opencdk)
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
#
# Required:
#  1. Libgcrypt
# 
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#
# You can change values here
#=================================================================================
# Library version
VERSION="0.6.6"
# Architectures array
ARCHS=("i386" "armv7")
# Platforms array
PLATFORMS=("iPhoneSimulator" "iPhoneOS")
# SDK versions array
SDKVERSIONS=("6.1" "7.0")
#=================================================================================
#
# You don't need to change values here
#=================================================================================

CURRENTPATH=${PWD}


if ! [ -f ${CURRENTPATH}/lib/libgcrypt.a ];
then
   	echo "Please build libgcrypt first"
   	exit 1
fi

mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e opencdk-${VERSION}.tar.bz2 ]; then
        echo "Downloading opencdk-${VERSION}.tar.bz2"
        curl -O http://ftp.heanet.ie/disk1/www.gnu.org/software/gnutls/releases/opencdk/opencdk-${VERSION}.tar.bz2
else
        echo "Using opencdk-${VERSION}.tar.bz2"
fi
echo "Extracting files..."
tar zxf opencdk-${VERSION}.tar.bz2 -C ${CURRENTPATH}/src/


for ((i=0; i<${#ARCHS[*]}; i++))
do
	ARCH=${ARCHS[i]}
	PLATFORM=${PLATFORMS[i]}
	SDKVERSION=${SDKVERSIONS[i]}
	
	# For testing purpose
	#ARCH="armv7"
	#PLATFORM="iPhoneOS"
	#SDKVERSION="7.0"
	
	#ARCH="i386"
	#PLATFORM="iPhoneSimulator"
	#SDKVERSION="6.1"

	OUTPUTPATH=${CURRENTPATH}/usr/${PLATFORM}${SDKVERSION}-${ARCH}.sdk
	mkdir -p "${OUTPUTPATH}"
	export PREFIX=${OUTPUTPATH}

	export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk
	export DEVROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr

	export CC=$DEVROOT/bin/cc
	export LD=$DEVROOT/bin/ld
	export CXX=$DEVROOT/bin/c++
	export AS=$DEVROOT/bin/as

	export AR=$DEVROOT/bin/ar
	export NM=$DEVROOT/bin/nm

	export CPP="$DEVROOT/bin/clang -E"
	export CXXCPP="$DEVROOT/bin/clang -E"
	export RANLIB=$DEVROOT/bin/ranlib

	export CC_FOR_BUILD="/usr/bin/clang -isysroot / -I/usr/include"

	export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${PREFIX}/lib"
	export CCASFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"
	export M4FLAGS="-I${PREFIX}/include"

	export CPPFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${PREFIX}/include"


	mkdir -p "${CURRENTPATH}/build/opencdk-${ARCH}"
	cd ${CURRENTPATH}/build/opencdk-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/opencdk-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --with-libgcrypt-prefix=${PREFIX}
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
	
done

cd ${CURRENTPATH}

echo "Build library..."
# libopencdk
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libopencdk.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libopencdk.a -output ${CURRENTPATH}/lib/libopencdk.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libopencdk.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libopencdk.dylib -output ${CURRENTPATH}/lib/libopencdk.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"
