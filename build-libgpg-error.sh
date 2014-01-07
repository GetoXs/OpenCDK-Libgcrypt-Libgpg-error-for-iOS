#!/bin/sh

# Automatic build script for Libgpg-error library (http://www.gnupg.org/related_software/libgpg-error/)
#  for i386 (iPhoneSimulator) and armv7(iPhoneOS)
#
# 
# Note:
#  Static libraries are disabled by default we need to change it in configure. 
#
# Created by Mateusz Przybylek
# Created on 2014-01-07
# Copyright 2014 Mateusz Przybylek. All rights reserved.
#
# You can change values here
#=================================================================================
# Library version
VERSION="1.12"
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


mkdir -p "${CURRENTPATH}/build"
mkdir -p "${CURRENTPATH}/include"
mkdir -p "${CURRENTPATH}/lib"
mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/tar"
mkdir -p "${CURRENTPATH}/usr"
cd "${CURRENTPATH}/tar"

if [ ! -e libgpg-error-${VERSION}.tar.xbz2z ]; then
        echo "Downloading libgpg-error-${VERSION}.tar.bz2"
        curl -O ftp://ftp.gnutls.org/gcrypt/libgpg-error/libgpg-error-${VERSION}.tar.bz2
else
        echo "Using libgpg-error-${VERSION}.tar.bz2"
fi
echo "Extracting files..."
tar zxf libgpg-error-${VERSION}.tar.bz2 -C ${CURRENTPATH}/src/


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


	mkdir -p "${CURRENTPATH}/build/libgpg-error-${ARCH}"
	cd ${CURRENTPATH}/build/libgpg-error-${ARCH}

	echo "Configure..."
	${CURRENTPATH}/src/libgpg-error-${VERSION}/configure --prefix=${PREFIX} --host=${ARCH}-apple-darwin --enable-static
	echo "Build..."
	make
	make install

	cd ${CURRENTPATH}
	
done

cd ${CURRENTPATH}

echo "Build library..."
# libgpg-error
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgpg-error.a ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgpg-error.a -output ${CURRENTPATH}/lib/libgpg-error.a
lipo -create ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/lib/libgpg-error.dylib ${CURRENTPATH}/usr/${PLATFORMS[1]}${SDKVERSIONS[1]}-${ARCHS[1]}.sdk/lib/libgpg-error.dylib -output ${CURRENTPATH}/lib/libgpg-error.dylib

echo "Copy headers..."
cp -r ${CURRENTPATH}/usr/${PLATFORMS[0]}${SDKVERSIONS[0]}-${ARCHS[0]}.sdk/include/* include

echo "Done"
