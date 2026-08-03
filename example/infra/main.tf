module "infra" {
  source = "github.com/hetznercloud/kubernetes-dev-env//modules/infra?ref=v0.10.2" # x-releaser-pleaser-version

  name         = "k8s-dev-${replace(var.name, "/[^a-zA-Z0-9-_]/", "-")}"
  hcloud_token = var.hcloud_token

  k3s_channel = var.k3s_channel

  # Share the generated files with the k8s state
  output_dir = abspath("${path.root}/../files")
}
