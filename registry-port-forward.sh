#!/usr/bin/env bash

set -ue -o pipefail

service="k8s-registry-port-forward"


run_systemd() {
  description="Port Forward for Container Registry of k8s dev environment"

  cleanup_systemd

  systemd-run --user \
    --unit="$service.service" \
    --description="$description" \
    --same-dir \
    --setenv="KUBECONFIG=$KUBECONFIG" \
    --collect \
    kubectl port-forward -n kube-system svc/docker-registry 30666:5000
}

cleanup_systemd() {
  systemctl --user stop "$service.service" 2> /dev/null || true
}


run_launchd() {
  cleanup_launchd

  launchctl submit \
    -l "$service" \
    -p "$(command -v kubectl)" \
    -- kubectl --kubeconfig="$KUBECONFIG" port-forward -n kube-system svc/docker-registry 30666:5000
}

cleanup_launchd() {
  launchctl remove "$service" 2> /dev/null || true
}


run() {
  if command -v systemctl > /dev/null; then
    run_systemd
  elif command -v launchctl > /dev/null; then
    run_launchd
  else
    echo "No supported init system found"
    exit 1
  fi
}

cleanup() {
  if command -v systemctl > /dev/null; then
    cleanup_systemd
  elif command -v launchctl > /dev/null; then
    cleanup_launchd
  else
    echo "No supported init system found"
    exit 1
  fi
}

help() {
  >&2 cat <<EOF
Usage:
  $0
  $0 cleanup
EOF
  exit 1
}

command="${1:-}"
case $command in
  "")
    run
    ;;
  "cleanup")
    cleanup
    ;;
  *)
    help
    ;;
esac
