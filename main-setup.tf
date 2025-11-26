# Setup the k3s cluster

locals {
  # The CIDR range for the Pods, must be included in the range of the
  # network (10.0.0.0/8) but must not overlap with the Subnet (10.0.0.0/24)
  cluster_cidr = "10.244.0.0/16"

  kubeconfig_path = abspath("${path.root}/files/kubeconfig.yaml")
  env_path        = abspath("${path.root}/files/env.sh")
}

module "registry_control" {
  source = "./k3s_registry"

  server      = hcloud_server.control
  private_key = tls_private_key.ssh.private_key_openssh
}

resource "terraform_data" "k3sup_control" {
  depends_on = [module.registry_control]

  triggers_replace = {
    id = hcloud_server.control.id
    ip = hcloud_server_network.control.ip
  }

  connection {
    host        = hcloud_server.control.ipv4_address
    private_key = tls_private_key.ssh.private_key_openssh
  }

  provisioner "local-exec" {
    command = <<-EOT
      k3sup install \
        --ssh-key='${local_sensitive_file.ssh_private.filename}' \
        --ip='${hcloud_server.control.ipv4_address}' \
        --k3s-channel='${var.k3s_channel}' \
        --k3s-extra-args="\
          --kubelet-arg=cloud-provider=external \
          --cluster-cidr='${local.cluster_cidr}' \
          --disable-cloud-controller \
          --disable-network-policy \
          --disable=local-storage \
          --disable=servicelb \
          --disable=traefik \
          --flannel-backend=none \
          %{~if var.use_cloud_routes~}
          --node-external-ip='${hcloud_server.control.ipv4_address}' \
          --node-ip='${hcloud_server_network.control.ip}'" \
          %{~else~}
          --node-ip='${hcloud_server.control.ipv4_address}'" \
          %{~endif~}
        --local-path='${local.kubeconfig_path}'
    EOT
  }
}

module "registry_worker" {
  source = "./k3s_registry"

  count = var.worker_count

  server      = hcloud_server.worker[count.index]
  private_key = tls_private_key.ssh.private_key_openssh
}

resource "terraform_data" "k3sup_worker" {
  count = var.worker_count

  depends_on = [module.registry_worker]

  triggers_replace = {
    id = hcloud_server.worker[count.index].id
    ip = hcloud_server_network.worker[count.index].ip

    # Wait the control-plane to be initialized, and re-join the new cluster if the
    # control-plane server changed.
    control_id = terraform_data.k3sup_control.id
  }

  connection {
    host        = hcloud_server.worker[count.index].ipv4_address
    private_key = tls_private_key.ssh.private_key_openssh
  }

  provisioner "local-exec" {
    command = <<-EOT
      k3sup join \
        --ssh-key='${local_sensitive_file.ssh_private.filename}' \
        --ip='${hcloud_server.worker[count.index].ipv4_address}' \
        --server-ip='${hcloud_server.control.ipv4_address}' \
        --k3s-channel='${var.k3s_channel}' \
        --k3s-extra-args="\
          --kubelet-arg='cloud-provider=external' \
          %{~if var.use_cloud_routes~}
          --node-external-ip='${hcloud_server.worker[count.index].ipv4_address}' \
          --node-ip='${hcloud_server_network.worker[count.index].ip}'"
          %{~else~}
          --node-ip='${hcloud_server.worker[count.index].ipv4_address}'"
          %{~endif~}
      EOT
  }
}

# Configure kubernetes

data "local_sensitive_file" "kubeconfig" {
  depends_on = [terraform_data.k3sup_control]
  filename   = local.kubeconfig_path
}

provider "kubernetes" {
  config_path = data.local_sensitive_file.kubeconfig.filename
}

resource "kubernetes_secret_v1" "hcloud_token" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }

  data = {
    token   = var.hcloud_token
    network = hcloud_network.cluster.id
  }
}

provider "helm" {
  kubernetes = {
    config_path = data.local_sensitive_file.kubeconfig.filename
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  chart      = "cilium"
  repository = "https://helm.cilium.io"
  namespace  = "kube-system"
  version    = "1.18.4"
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
      value = local.cluster_cidr
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
  version    = "1.28.0"
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
  version    = "2.18.2"
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
      value = module.registry_control.registry_service_ip
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
  filename        = "${path.root}/files/registry-port-forward.sh"
  file_permission = "0755"
}

resource "local_file" "env" {
  content         = <<-EOT
    #!/usr/bin/env bash

    export ENV_NAME=${var.name}
    export KUBECONFIG=${data.local_sensitive_file.kubeconfig.filename}
    export SKAFFOLD_DEFAULT_REPO=localhost:${module.registry_control.registry_port}
  EOT
  filename        = local.env_path
  file_permission = "0644"
}
