#!/bin/bash

SCRIPTFILE=$0
SCRIPTPATH=$(dirname $(readlink -f $SCRIPTFILE))
ROOTPATH=$(readlink -f $SCRIPTPATH/..)
OPENSSLDIR="openssl"
OPENSSLPATH=$(readlink -f $ROOTPATH/$OPENSSLDIR)
ZLIBDIR="zlib"
ZLIBPATH=$(readlink -f $ROOTPATH/$ZLIBDIR)
CURLDIR="curl"
CURLPATH=$(readlink -f $ROOTPATH/$CURLDIR)
DSTPATH=$(readlink -f $ROOTPATH/prebuilt-with-ssl/linux)

rm -rf $DSTPATH || true

ARCH64=x86_64
ARCH86=i386

#x86 and x64
#ARCHS=($ARCH64 $ARCH86)
#ARCHSOPENSSL=("linux-x86_64" "-m32 linux-generic32")
#ARCHSCURL=($ARCH64 $ARCH86)

#x64 only
ARCHS=($ARCH64)
ARCHSOPENSSL=("linux-x86_64")
ARCHSCURL=($ARCH64)

#x86 only
#ARCHS=($ARCH86)
#ARCHSOPENSSL=("-m32 linux-generic32")
#ARCHSCURL=($ARCH86)

echo "script:   $SCRIPTFILE"
echo "scripts:  $SCRIPTPATH"
echo "root:     $ROOTPATH"
echo "openssl:  $OPENSSLPATH"
echo "zlib:     $ZLIBPATH"
echo "curl:     $CURLPATH"

cd $ROOTPATH

echo "patching openssl"
patch -t -p0 < $ROOTPATH/ssl_ciph.patch

for (( a=0; a<${#ARCHS[@]}; a++ )); do

	ARCH=${ARCHS[$a]}
    ARCHOPENSSL=${ARCHSOPENSSL[$a]}
    ARCHCURL=${ARCHSCURL[$a]}

    export CC=gcc

    DSTPATHARC=$DSTPATH/$ARCH
    rm -rf $DSTPATHARC || true
    mkdir -p $DSTPATHARC || true

    cd $ZLIBPATH

    make clean || true

    ./configure --prefix=$DSTPATHARC --static

    EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "configuring zlib error $ARCH"
		exit $EXITCODE
	fi

    make && make test && make install

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "building zlib error $ARCH"
		exit $EXITCODE
	fi

    cd $OPENSSLPATH

    make clean || true

    ./Configure --prefix=$DSTPATHARC --with-zlib-include=$DSTPATHARC/include --with-zlib-lib=$DSTPATHARC/lib no-dso no-rdrand no-rsax no-mdc2 no-seed no-asm no-shared no-cast no-idea no-camellia no-whirpool no-hw $ARCHOPENSSL 

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "configuring openssl error $ARCH"
		exit $EXITCODE
	fi

    make depend && make && make install

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "building openssl error $ARCH"
		exit $EXITCODE
	fi

    cd $CURLPATH

    make clean || true

    ./buildconf

    EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "preparing to configure curl error $ARCH"
		exit $EXITCODE
	fi

    export LIBS="$LIBS -lssl -lcrypto -lz"
	if [ "$ARCH" == "$ARCH86" ]; then
		export CPPFLAGS="$CPPFLAGS -m32"
	fi

    export CPPFLAGS="-I${DSTPATHARC}/include $CPPFLAGS"
    export LDFLAGS="-L${DSTPATHARC}/lib $LDFLAGS"

    CONFIGURE="./configure --host=$ARCHCURL-linux-gnu --target=$ARCHCURL-linux-gnu --build=$ARCHCURL-linux-gnu --prefix=$DSTPATHARC --enable-static --disable-shared --enable-threaded-resolver --enable-ipv6 --with-ssl --with-zlib"
    echo $CONFIGURE

    $CONFIGURE

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "configuring curl error $ARCH"
		exit $EXITCODE
	fi
    
    make && make test && make install

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "building curl error $ARCH"
		exit $EXITCODE
	fi

    cd ${DSTPATHARC}/lib
    mkdir repack
    cd repack
    for f in ../*.a; do ar -x $f; done
    ar cr ../libcurlssl.a *.o
    cd ..
    rm -rf repack

    for f in *.a; do strip --info $f; done
    for f in *.a; do strip -v --strip-debug $f; done
    
done
