#!/usr/bin/env bash
set -euo pipefail

dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
