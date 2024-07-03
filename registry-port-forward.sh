#!/usr/bin/env bash

set -ue -o pipefail

run_systemd() {
  unit="k8s-registry-port-forward.service"
  description="Port Forward for Container Registry of k8s dev environment"

  systemctl --user stop "$unit" 2> /dev/null || true

  systemd-run --user \
    --unit="$unit" \
    --description="$description" \
    --same-dir \
    --setenv="KUBECONFIG=$KUBECONFIG" \
    --collect \
    kubectl port-forward -n kube-system svc/docker-registry 30666:5000
}

run_launchd() {
  label="k8s-registry-port-forward"

  launchctl remove "$label" 2> /dev/null || true

  launchctl submit \
    -l "$label" \
    -p "$(command -v kubectl)" \
    -- kubectl --kubeconfig="$PWD/files/kubeconfig.yaml" port-forward -n kube-system svc/docker-registry 30666:5000
}

if command -v systemctl > /dev/null; then
  run_systemd
elif command -v launchctl > /dev/null; then
  run_launchd
else
  echo "No supported init system found"
  exit 1
fi
