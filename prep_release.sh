#!/usr/bin/env bash

release_tools prepare_release -wn

if [ -e VERSION.txt ]
then
  # We can release
  releaseVersion=$(cat VERSION-NO-BUILD.txt)
  releaseVersionWithBuild=$(cat VERSION.txt)
  summary=$(cat RELEASE_SUMMARY.txt)

  # Update versions in files
  release_tools update_version --file="snap/snapcraft.yaml" --template="version: [VERSION]" $releaseVersion
  release_tools update_version --file="lib/app_info.dart" --template="final _fullVersion = Version.parse('[VERSION]');" $releaseVersion
  release_tools update_version --file="README.md" --template="/releases/download/[VERSION]/" $releaseVersion

  # Build
  flutter build linux --release
  git add .
  git commit -m "chore(release): prepare release for ${releaseVersion}"

  # Gzip release
  cwd=`pwd`
  cd build/linux/x64/
  tar -czvf release-linux-x64-${releaseVersion}.tar.gz release
  cd $cwd

  # Create AppImage
  # Assumes appimagetool-x86_64.AppImage is found in $PATH
  # See https://github.com/AppImage/AppImageKit
  cp -r ./build/linux/x64/release/bundle/* ./Diligence.AppDir/
  appimagetool-x86_64.AppImage  Diligence.AppDir/ Diligence-x64-${releaseVersion}.AppImage
fi
