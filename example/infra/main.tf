module "infra" {
  source = "../../modules/infra" # x-releaser-pleaser-version

  name         = "k8s-dev-${replace(var.name, "/[^a-zA-Z0-9-_]/", "-")}"
  hcloud_token = var.hcloud_token

  k3s_channel = var.k3s_channel

  # Share the generated files with the k8s state
  output_dir = abspath("${path.root}/../files")
}
