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
  FILEPATH="$HOME/Library/LaunchAgents/com.hetzner.cloud.k8sdev.registry-port-forward.plist"

  cat > "$FILEPATH" <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hetzner.cloud.k8sdev.portforward.plist</string>
    <key>Program</key>
    <string>$(which kubectl)</string>
    <key>ProgramArguments</key>
    <array>
        <string>kubectl</string>
        <string>port-forward</string>
        <string>-n</string>
        <string>kube-system</string>
        <string>svc/docker-registry</string>
        <string>30666:5000</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>KUBECONFIG</key>
        <string>$KUBECONFIG</string>
    </dict>
    <key>WorkingDirectory</key>
    <string>$PWD</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

  launchctl load "$FILEPATH"
}

if which systemctl > /dev/null; then
  run_systemd
elif which launchctl > /dev/null; then
  run_launchd
else
  echo "No supported init system found"
  exit 1
fi
