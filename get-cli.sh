#!/bin/bash

option="${1:-all}"
cli_version=${2:-latest}

case ${option} in
linux)
  echo "Downloading linux binary version: ${cli_version}"
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-linux -o instant
  chmod +x ./instant
  exit 0
  ;;
macos)
  echo "Downloading macos binary version: ${cli_version}"
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-macos -o instant-macos
  chmod +x ./instant-macos
  exit 0
  ;;
windows)
  echo "Downloading windows binary version: ${cli_version}"
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-win.exe -o instant.exe
  chmod +x ./instant.exe
  exit 0
  ;;
all)
  echo "Downloading all binaries, version: ${cli_version}"
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-linux -o instant
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-macos -o instant-macos
  curl -L https://github.com/openhie/instant-v2/releases/download/"$cli_version"/instant-win.exe -o instant.exe
  chmod +x ./instant
  chmod +x ./instant-macos
  chmod +x ./instant.exe
  exit 0
  ;;
--help)
  echo "Usage: get-cli.sh [linux|macos|windows|all] {cli_version}"
  exit 0
  ;;
esac
