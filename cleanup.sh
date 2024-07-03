#!/usr/bin/env bash

set -ue -o pipefail

run_launchd() {
  label="k8s-registry-port-forward"
  launchctl remove "$label" 2> /dev/null || true
}

if command -v launchctl > /dev/null; then
  run_launchd
fi
