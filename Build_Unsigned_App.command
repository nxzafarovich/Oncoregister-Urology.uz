#!/bin/bash
set -e
cd "$(dirname "$0")"
rm -rf build
xcodebuild -project "OncoRegister.xcodeproj" -target "Onco Register" -configuration Release CODE_SIGNING_ALLOWED=NO CONFIGURATION_BUILD_DIR="$PWD/build" build
echo
echo "Built app:"
echo "$PWD/build/Onco Register.app"
echo
echo "Move the entire app into the shared network folder."
echo "On first launch, the app will create:"
echo "  Onco Register Data/onco_register.sqlite"
echo "  Onco Register Exports/"
echo "  Onco Register Backups/"
open "$PWD/build"
