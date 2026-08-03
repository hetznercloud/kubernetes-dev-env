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

if command -v systemctl > /dev/null; then
  run="run_systemd"
  cleanup="cleanup_systemd"
elif   command -v launchctl > /dev/null; then
  run="run_launchd"
  cleanup="cleanup_launchd"
else
  echo "No supported init system found"
  exit 1
fi

help() {
  cat << EOF >&2
Usage:
  $0 up
  $0 down
EOF
  exit 1
}

case "${1:-}" in
  "up")
    $run
    ;;
  "down")
    $cleanup
    ;;
  *)
    help
    ;;
esac
