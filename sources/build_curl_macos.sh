#! /bin/zsh

curl_src_dir=$1

cd $curl_src_dir
export ARCH=$2
export SDK=$3
export DEPLOYMENT_TARGET=$4
export CFLAGS="-arch $ARCH -isysroot $(xcrun -sdk $SDK --show-sdk-path) -m$SDK-version-min=$DEPLOYMENT_TARGET"
autoreconf -fi configure.ac
./configure --host=$ARCH-apple-darwin --prefix $(pwd)/artifacts --with-secure-transport
make -j8
make install
return 0