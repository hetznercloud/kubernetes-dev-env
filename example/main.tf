module "dev" {
  source = "github.com/hetznercloud/terraform-k8s-dev?ref=0.1.0"

  name         = "k8s-dev-${replace(var.name, "/[^a-zA-Z0-9-_]/", "-")}"
  hcloud_token = var.hcloud_token

  k3s_channel = var.k3s_channel
}
