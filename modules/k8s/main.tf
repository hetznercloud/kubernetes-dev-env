# Setup the resources inside the k3s cluster
#
# This module is meant to be used in its own state, next to the infra module.
# Keeping the in-cluster resources separate means that recreating the cluster
# never leaves resources behind that can no longer be deleted, and that the
# cluster can be torn down without having to reach it first.

locals {
  output_dir = coalesce(var.output_dir, abspath("${path.root}/files"))
}

resource "kubernetes_secret_v1" "hcloud_token" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }

  data = {
    token   = var.hcloud_token
    network = var.hcloud_network_id
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  chart      = "cilium"
  repository = "https://helm.cilium.io"
  namespace  = "kube-system"
  version    = "1.20.1"
  wait       = true

  set = [
    {
      name  = "operator.replicas"
      value = "1"
    },
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
    {
      name  = "routingMode"
      value = var.use_cloud_routes ? "native" : "tunnel"
    },
    {
      # Only used if routingMode=native
      name  = "ipv4NativeRoutingCIDR"
      value = var.cluster_cidr
    }
  ]
}

resource "helm_release" "hcloud_cloud_controller_manager" {
  count = var.deploy_hccm ? 1 : 0

  depends_on = [kubernetes_secret_v1.hcloud_token]

  name       = "hcloud-cloud-controller-manager"
  chart      = "hcloud-cloud-controller-manager"
  repository = "https://charts.hetzner.cloud"
  namespace  = "kube-system"
  version    = "1.36.0"
  wait       = true

  set = [
    {
      name  = "networking.enabled"
      value = "true"
    },
    {
      name  = "env.HCLOUD_NETWORK_ROUTES_ENABLED.value"
      value = tostring(var.use_cloud_routes)
      type  = "string"
    },
    {
      name  = "env.HCLOUD_ENDPOINT.value"
      value = var.hccm_hcloud_endpoint
    }
  ]
}

resource "helm_release" "hcloud_csi_driver" {
  count = var.deploy_csi_driver ? 1 : 0

  depends_on = [kubernetes_secret_v1.hcloud_token]

  name       = "hcloud-csi"
  chart      = "hcloud-csi"
  repository = "https://charts.hetzner.cloud"
  namespace  = "kube-system"
  version    = "2.22.1"
  wait       = true
}

resource "helm_release" "docker_registry" {
  depends_on = [helm_release.cilium]

  name       = "docker-registry"
  chart      = "docker-registry"
  repository = "https://twuni.github.io/docker-registry.helm"
  namespace  = "kube-system"
  version    = "3.0.0"
  wait       = true

  set = [
    {
      name  = "service.clusterIP"
      value = var.registry_service_ip
    },
    {
      name  = "tolerations[0].key"
      value = "node.cloudprovider.kubernetes.io/uninitialized"
    },
    {
      name  = "tolerations[0].operator"
      value = "Exists"
    }
  ]
}

# Export files

resource "local_file" "registry_port_forward" {
  source          = "${path.module}/registry-port-forward.sh"
  filename        = "${local.output_dir}/registry-port-forward.sh"
  file_permission = "0755"
}
