#!/usr/bin/env bash

release_tools prepare_release -wn

if [ -e VERSION.txt ]
then
  # We can release
  releaseVersionNoBuild=$(cat VERSION-NO-BUILD.txt)
  releaseVersion=$(cat VERSION.txt)
  summary=$(cat RELEASE_SUMMARY.txt)

  # Build
  flutter build linux --release
  git add .
  git commit -m "chore(release): prepare release for ${releaseVersionNoBuild}"

  # Gzip release
  cwd=`pwd`
  cd build/linux/x64/
  tar -czvf release-linux-x64-${releaseVersionNoBuild}.tar.gz release
  cd $cwd

  # Create AppImage
  # Assumes appimagetool-x86_64.AppImage is found in $PATH
  # See https://github.com/AppImage/AppImageKit
  cp -r ./build/linux/x64/release/bundle/* ./Diligence.AppDir/
  appimagetool-x86_64.AppImage  Diligence.AppDir/ Diligence-x64-${releaseVersionNoBuild}.AppImage
fi
