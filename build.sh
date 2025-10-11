#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname $(readlink -f $0))"
[ ! -d build ] && mkdir build || true

clang -c -o build/MyDelegate.o MyDelegate.m
clang -c -o build/SettingsManager.o SettingsManager.m
clang -c -o build/Keybind.o Keybind.m
clang -c -o build/scratcher.o scratcher.m

clang -o build/scratcher build/*.o -framework AppKit -framework Carbon
