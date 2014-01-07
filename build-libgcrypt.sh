#!/bin/sh

# Automatic build script for Libgcrypt library (http://www.gnu.org/software/libgcrypt/)
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
#
# Required:
#  1. Libgpg-error library
# 
# Note:
# 1. We have to use --with-gpg-error-prefix (instead of --with-libgpg-error-prefix) because configure override all variables before
# 2. Cross-compiling under armv7 required missing rules file for arm "blowfish-arm.S", I found it and put it into patches (applies automatically)
# 3. Static libraries are disabled by default we need to change it in configure.
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#
# You can change values here
#=================================================================================
# Library version
VERSION="1.6.0"
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

if ! [ -f ${CURRENTPATH}/lib/libgpg-error.a ];
then
   	echo "Please build libgpg-error first"
   	exit 1
fi

mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e libgcrypt-${VERSION}.tar.bz2 ]; then
        echo "Downloading libgcrypt-${VERSION}.tar.bz2"
        curl -O ftp://ftp.gnutls.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2
else
        echo "Using libgcrypt-${VERSION}.tar.bz2"
fi
echo "Extracting files..."
tar zxf libgcrypt-${VERSION}.tar.bz2 -C ${CURRENTPATH}/src/


if ! [ -f ${CURRENTPATH}/src/libgcrypt-${VERSION}/cipher/blowfish-arm.S ];
then
	
   	echo "Could detect required file => Applying patch"
   	cp ${CURRENTPATH}/patches/libgcrypt/blowfish-arm.S ${CURRENTPATH}/src/libgcrypt-${VERSION}/cipher/blowfish-arm.S
fi

for ((i=0; i<${#ARCHS[*]}; i++))
do
	ARCH=${ARCHS[i]}
	PLATFORM=${PLATFORMS[i]}
	SDKVERSION=${SDKVERSIONS[i]}

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


	mkdir -p "${CURRENTPATH}/build/libgcrypt-${ARCH}"
	cd ${CURRENTPATH}/build/libgcrypt-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/libgcrypt-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --with-gpg-error-prefix=${PREFIX} --enable-static
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
	
done

cd ${CURRENTPATH}

echo "Build library..."
# libgcrypt
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgcrypt.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgcrypt.a -output ${CURRENTPATH}/lib/libgcrypt.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgcrypt.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgcrypt.dylib -output ${CURRENTPATH}/lib/libgcrypt.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"
