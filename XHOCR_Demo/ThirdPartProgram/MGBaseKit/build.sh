#!/bin/bash

rm -rf build
mkdir -p build
pushd `pwd`
rm -rf MGBaseKit/build/
xcodebuild -project MGBaseKit.xcodeproj -scheme MGBaseKit -derivedDataPath MGBaseKit/build/ -configuration Release
popd

#copy framework
cp -rp  ./MGBaseKit/build/Build/Products/Release-iphoneos/MGBaseKit.framework build/
rm -rf MGBaseKit/build
