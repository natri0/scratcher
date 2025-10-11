#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname $(readlink -f $0))"

clang -c -o build/MyDelegate.o MyDelegate.m
clang -c -o build/SettingsManager.o SettingsManager.m
clang -c -o build/Keybind.o Keybind.m
clang -c -o build/paster.o paster.m

clang -o build/paster build/*.o -framework AppKit
