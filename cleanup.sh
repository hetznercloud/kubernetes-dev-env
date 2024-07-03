#!/usr/bin/env bash

set -ue -o pipefail

run_launchd() {
  FILEPATH="$HOME/Library/LaunchAgents/com.hetzner.cloud.k8sdev.registry-port-forward.plist"
  launchctl unload "$FILEPATH" 2> /dev/null || true
  rm -f "$FILEPATH"
}

if which launchctl > /dev/null; then
  run_launchd
fi
