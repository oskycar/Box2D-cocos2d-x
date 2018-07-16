#!/bin/sh

#set Xcode project name,should same as in CMakeLists.txt
PROJECT_NAME="libBox2D"

#set library name,should same as in CMakeLists.txt
LIBNAME="box2d"
THIN=`pwd`"/thin_ios/"
FAT=`pwd`"/prebuilt/lib/"

XCODE_DEVELOPER_PATH=`xcode-select -p`
CWD=`pwd`
mkdir -p ${THIN}
mkdir -p ${FAT}

#build for ios and ios simulator
cd ${CWD}
rm -rf build.ios
mkdir build.ios
cd build.ios

#generate ios project
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/iOS.cmake  -DCMAKE_IOS_DEVELOPER_ROOT=${XCODE_DEVELOPER_PATH}/Platforms/iPhoneOS.platform/Developer/ -GXcode ..
echo "generate ios project finished"
read

echo "build x86_64 iphonesimulator lib"
xcodebuild -project ${PROJECT_NAME}.xcodeproj -arch x86_64 -sdk iphonesimulator -configuration Release
#this cmdline will build i386 and x86_64 ,but we just need x86_64
#xcodebuild -project Project.xcodeproj -alltargets  -sdk iphonesimulator -configuration Release

mkdir -p ${THIN}/iphonesimulator
cp ./lib/Release/lib"${LIBNAME}".a ${THIN}/iphonesimulator

echo "build iosx86_64 simulator finished"
read

# build iphone os, this is a ios fat lib,contains arm7 and arm64lib
echo "build armv7 arm64 iphoneos lib"
xcodebuild -project ${PROJECT_NAME}.xcodeproj -alltargets -sdk iphoneos -configuration Release  
mkdir -p ${THIN}/iphoneos
cp ./lib/Release/lib"${LIBNAME}".a ${THIN}/iphoneos
echo "build ios alltargets iphone finished"
#rm -rf build.ios
read

# create the fat package
mkdir -p ${FAT}/ios/
lipo  ${THIN}/iphonesimulator/lib"${LIBNAME}".a  ${THIN}/iphoneos/lib"${LIBNAME}".a -create -output ${FAT}/ios/lib"${LIBNAME}".a
lipo -info ${FAT}/ios/lib"${LIBNAME}".a
echo "lipo ios lib finished"


echo " generate mac project "
cd ${CWD}
rm -rf build.mac
mkdir build.mac
cd build.mac

cmake -G Xcode ..
#build mac project
xcodebuild -project ${PROJECT_NAME}.xcodeproj  -arch x86_64 -configuration Release
mkdir -p ${FAT}/mac/
cp ./lib/Release/lib"${LIBNAME}".a ${FAT}/mac/lib"${LIBNAME}".a
#rm -rf build.mac
echo "build mac lib finished"

echo "press enter to clean tmp build dir and files,or press ctrl-c to reserve the file"
read
cd ${CWD}
rm -rf ${THIN}
rm -rf ./build.ios
rm -rf ./build.mac


