# Setup the infrastructure and the k3s cluster
#
# This module must not manage any resource inside the cluster (see the k8s
# module), otherwise the Kubernetes and Helm providers would be configured from
# values that are only known once the servers exist. Recreating the cluster
# would then leave the in-cluster resources stranded in this state.

locals {
  labels = merge(var.hcloud_labels, {
    env = var.name
  })

  output_dir      = coalesce(var.output_dir, abspath("${path.root}/files"))
  kubeconfig_path = "${local.output_dir}/kubeconfig.yaml"
  env_path        = "${local.output_dir}/env.sh"

  k3sup_version_flag = var.k3s_version != null ? "--k3s-version='${var.k3s_version}'" : "--k3s-channel='${var.k3s_channel}'"
}

# SSH Key

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${local.output_dir}/id_ed25519"
}

resource "local_sensitive_file" "ssh_public" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${local.output_dir}/id_ed25519.pub"
}

resource "hcloud_ssh_key" "default" {
  name       = var.name
  public_key = trim(tls_private_key.ssh.public_key_openssh, "\n")
  labels     = local.labels
}

# Network

resource "hcloud_network" "cluster" {
  name     = var.name
  ip_range = "10.0.0.0/8"
  labels   = local.labels
}

resource "hcloud_network_subnet" "cluster" {
  network_id   = hcloud_network.cluster.id
  network_zone = "eu-central"
  type         = "cloud"
  ip_range     = "10.0.0.0/24"
}

# Control Plane Node

resource "hcloud_server" "control" {
  name        = "${var.name}-control"
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  image       = var.hcloud_image
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels      = local.labels

  connection {
    host        = self.ipv4_address
    private_key = tls_private_key.ssh.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait || test $? -eq 2"]
  }
}

resource "hcloud_server_network" "control" {
  server_id = hcloud_server.control.id
  subnet_id = hcloud_network_subnet.cluster.id
}

# Worker / Agent Nodes
resource "hcloud_server" "worker" {
  count = var.worker_count

  name        = "${var.name}-worker-${count.index}"
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  image       = var.hcloud_image
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels      = local.labels

  connection {
    host        = self.ipv4_address
    private_key = tls_private_key.ssh.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait || test $? -eq 2"]
  }
}

resource "hcloud_server_network" "worker" {
  count = var.worker_count

  server_id = hcloud_server.worker[count.index].id
  subnet_id = hcloud_network_subnet.cluster.id
}

# Setup the k3s cluster

module "registry_control" {
  source = "./k3s_registry"

  server = {
    id           = hcloud_server.control.id
    ipv4_address = hcloud_server.control.ipv4_address
  }
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
        ${local.k3sup_version_flag} \
        --k3s-extra-args="\
          --kubelet-arg=cloud-provider=external \
          --cluster-cidr='${var.cluster_cidr}' \
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

  server = {
    id           = hcloud_server.worker[count.index].id,
    ipv4_address = hcloud_server.worker[count.index].ipv4_address,
  }
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
        ${local.k3sup_version_flag} \
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

# Export files

resource "local_file" "env" {
  depends_on = [terraform_data.k3sup_control]

  content         = <<-EOT
    #!/usr/bin/env bash

    export ENV_NAME=${var.name}
    export KUBECONFIG=${local.kubeconfig_path}
    export SKAFFOLD_DEFAULT_REPO=localhost:${module.registry_control.registry_port}
  EOT
  filename        = local.env_path
  file_permission = "0644"
}
