#!/bin/sh

CWD=`pwd`
LIBNAME="box2d"

#1 准备android交叉编译环境

#ndk根目录,如果想指定其他版本的ndk则可以打开该定义以覆盖系统中定义的ndkroot变量
#export ANDROID_NDK_ROOT="/Users/cbav/software/android/ndk-r9b"
if [ "$ANDROID_NDK_ROOT" ]
then
    echo "ANDROID_NDK_ROOT="$ANDROID_NDK_ROOT
else
    echo "use \"export ANDROID_NDK_ROOT=xxx\" to define the ndkbundle path"
    export ANDROID_NDK_ROOT="/Users/cbav/software/android/ndk-r9b"
    if [ ! -d "${ANDROID_NDK_ROOT}"]; then 
        echo “ndk root path not exist ”
        exit -1
    fi 
fi

#修改下面几个变量的值来导出适合的ndk编译环境，后续的ndk编译变量可以基于该编译目录设置，从而避免不同版本ndk目录结构不一致的问题

#toolchain abi的版本
NDK_TOOLCHAIN_ABI_VERSION=4.9
#android平台的版本
export PLATFORM_VERSION=android-19

#==================build for arm ==========================

#生成arm下的toolchain目录
export TOOLCHAIN_PREFIX=`pwd`/toolchain_android

#使用ndk中的脚本创建交叉编译环境，此方法可以避免不同ndk版本目录结构不一致导致编译选项需要修改的问题
if [ ! -d "$TOOLCHAIN_PREFIX" ]; then
  ${ANDROID_NDK_ROOT}/build/tools/make-standalone-toolchain.sh \
            --toolchain=arm-linux-androideabi-$NDK_TOOLCHAIN_ABI_VERSION \
            --platform=$PLATFORM_VERSION \
            --install-dir=${TOOLCHAIN_PREFIX}
fi

echo "gen arm toolchaine finished"
read

export PATH=$PATH:${TOOLCHAIN_PREFIX}/bin
export ANDROID_STANDALONE_TOOLCHAIN=${TOOLCHAIN_PREFIX}


#begombuild for arm
rm -rf build.android/ 
mkdir build.android
cd build.android

#build for armeabi
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi" -DANDROID=1 ..
make
#install the headfile
make install

INSTALLDIR="../prebuilt/lib/android/armeabi/"
mkdir -p ${INSTALLDIR}
mv ./lib/lib${LIBNAME}.a ${INSTALLDIR}
echo "build armeabi finished"
read


#build for armeabi-v7a
cd ${CWD}
rm -rf build.android/ 
mkdir build.android/ 
cd build.android/ 
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi-v7a" -DANDROID=1 ..
make
INSTALLDIR="../prebuilt/lib/android/armeabi-v7a/"
mkdir -p ${INSTALLDIR}
mv ./lib/lib${LIBNAME}.a ${INSTALLDIR}
echo "build armeabi-v7a finished"
read


#==================build for x86==========================
cd ${CWD}
#生成x86下的toolchain目录
export TOOLCHAIN_PREFIX=`pwd`/toolchain_android_x86
#使用ndk中的脚本创建交叉编译环境，此方法可以避免不同ndk版本目录结构不一致导致编译选项需要修改的问题
if [ ! -d "$TOOLCHAIN_PREFIX" ]; then
  ${ANDROID_NDK_ROOT}/build/tools/make-standalone-toolchain.sh \
            --toolchain=x86-$NDK_TOOLCHAIN_ABI_VERSION \
            --platform=$PLATFORM_VERSION \
            --install-dir=${TOOLCHAIN_PREFIX}
fi

echo "gen x86 toolchaine finished"

rm -rf build.android/ 
mkdir build.android/ 
cd build.android/ 

#build for x86
export PATH=$PATH:${TOOLCHAIN_PREFIX}/bin
export PATH=$PATH:$ANDROID_NDK/build/tools/
export ANDROID_STANDALONE_TOOLCHAIN=${TOOLCHAIN_PREFIX}

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI="x86" -DANDROID=1 ..
make
INSTALLDIR="../prebuilt/lib/android/x86/"
mkdir -p ${INSTALLDIR}
mv ./lib/lib${LIBNAME}.a ${INSTALLDIR}
echo "build android x86 finished"
read

cd ${CWD}
rm -rf build.android/ 





