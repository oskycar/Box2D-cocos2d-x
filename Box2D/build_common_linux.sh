#!/bin/sh

LIBNAME="box2d"

OSNAME=`uname -s`

mkdir build.${OSNAME}
cd build.${OSNAME}
cmake -DCMAKE_BUILD_TYPE=Release  ..
make

cd ..
mkdir -p prebuilt/lib/${OSNAME}/
cp build.${OSNAME}/lib/lib"${LIBNAME}".a prebuilt/lib/${OSNAME}/
rm -rf build.${OSNAME}