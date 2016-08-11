#!/bin/bash

# This script downlaods and builds the Mac, iOS and tvOS libcurl libraries with Bitcode enabled

# Credits:
#
# Felix Schwarz, IOSPIRIT GmbH, @@felix_schwarz.
#   https://gist.github.com/c61c0f7d9ab60f53ebb0.git
# Bochun Bai
#   https://github.com/sinofool/build-libcurl-ios
# Jason Cox, @jasonacox
#   https://github.com/jasonacox/Build-OpenSSL-cURL
# Preston Jennings
#   https://github.com/prestonj/Build-OpenSSL-cURL

set -e

usage ()
{
echo "usage: $0 [iOS SDK version (defaults to latest)] [tvOS SDK version (defaults to latest)]"
exit 127
}

if [ "$1" == "-h" ]; then
usage
fi

if [ -z $1 ]; then
IOS_SDK_VERSION="" #"9.1"
IOS_MIN_SDK_VERSION="7.1"

TVOS_SDK_VERSION="" #"9.0"
TVOS_MIN_SDK_VERSION="9.0"
else
IOS_SDK_VERSION=$1
TVOS_SDK_VERSION=$2
fi

CURL_VERSION="curl-7.48.0"
OPENSSL="${PWD}/../openssl"
DEVELOPER=`xcode-select -print-path`
IPHONEOS_DEPLOYMENT_TARGET="6.0"
# HTTP2 support
NOHTTP2="/tmp/no-http2"
if [ ! -f "$NOHTTP2" ]; then
# nghttp2 will be in ../nghttp2/{Platform}/{arch}
NGHTTP2="${PWD}/../nghttp2"
fi
if [ ! -z "$NGHTTP2" ]; then
echo "Building with HTTP2 Support (nghttp2)"
else
echo "Building without HTTP2 Support (nghttp2)"
NGHTTP2CFG=""
NGHTTP2LIB=""
fi
buildIOS()
{
ARCH=$1
BITCODE=$2
pushd . > /dev/null
cd "${CURL_VERSION}"

PLATFORM="iPhoneSimulator"
if [[ "${BITCODE}" == "nobitcode" ]]; then
CC_BITCODE_FLAG=""
else
CC_BITCODE_FLAG="-fembed-bitcode"
fi
if [ ! -z "$NGHTTP2" ]; then
NGHTTP2CFG="--with-nghttp2=${NGHTTP2}/iOS/${ARCH}"
NGHTTP2LIB="-L${NGHTTP2}/iOS/${ARCH}/lib"
fi

export $PLATFORM
export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
export CROSS_SDK="${PLATFORM}${IOS_SDK_VERSION}.sdk"
export BUILD_TOOLS="${DEVELOPER}"
export CC="${BUILD_TOOLS}/usr/bin/gcc"
export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=${IOS_MIN_SDK_VERSION} ${CC_BITCODE_FLAG}"
export LDFLAGS="-arch ${ARCH} -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -L${OPENSSL}/iOS/lib ${NGHTTP2LIB}"

echo "Building ${CURL_VERSION} for ${PLATFORM} ${IOS_SDK_VERSION} ${ARCH} ${BITCODE}"
./configure -prefix="/tmp/${CURL_VERSION}-iOS-${ARCH}-${BITCODE}" -disable-shared --enable-static -with-random=/dev/urandom --with-ssl=${OPENSSL}/iOS ${NGHTTP2CFG} --host="${ARCH}-apple-darwin" &> "/tmp/${CURL_VERSION}-iOS-${ARCH}-${BITCODE}.log"
make -j8 >> "/tmp/${CURL_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
make install >> "/tmp/${CURL_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
make clean >> "/tmp/${CURL_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
popd > /dev/null
}
echo "Cleaning up"
rm -rf include/curl/* lib/*
mkdir -p lib
mkdir -p include/curl/
rm -rf "/tmp/${CURL_VERSION}-*"
rm -rf "/tmp/${CURL_VERSION}-*.log"
rm -rf "${CURL_VERSION}"
if [ ! -e ${CURL_VERSION}.tar.gz ]; then
echo "Downloading ${CURL_VERSION}.tar.gz"
curl -LO https://curl.haxx.se/download/${CURL_VERSION}.tar.gz
else
echo "Using ${CURL_VERSION}.tar.gz"
fi
echo "Unpacking curl"
tar xfz "${CURL_VERSION}.tar.gz"
buildIOS "x86_64" "bitcode"
echo "Copying headers"
cp /tmp/${CURL_VERSION}-x86_64/include/curl/* include/curl/
lipo \
"/tmp/${CURL_VERSION}-iOS-x86_64-bitcode/lib/libcurl.a" \
-create -output lib/libcurl_iOS.a
echo "Cleaning up"
rm -rf /tmp/${CURL_VERSION}-*
rm -rf ${CURL_VERSION}
echo "Checking libraries"
xcrun -sdk iphoneos lipo -info lib/*.a
echo "Done"