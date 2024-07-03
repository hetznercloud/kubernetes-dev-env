variable "registry_service_ip" {
  type    = string
  default = "10.43.0.2"
}

variable "registry_port" {
  type    = number
  default = 30666
}

variable "private_key" {
  type    = string
  default = ""
}

variable "server" {
  type = object({
    id           = number,
    ipv4_address = string,
  })
}

resource "null_resource" "k3sup_worker" {
  triggers = {
    id = var.server.id
  }

  connection {
    host        = var.server.ipv4_address
    private_key = var.private_key != "" ? var.private_key : null
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /etc/rancher/k3s"]
  }
  provisioner "file" {
    content = yamlencode({
      "mirrors" : {
        "localhost:${var.registry_port}" : {
          "endpoint" : ["http://${var.registry_service_ip}:5000"]
        }
      }
    })
    destination = "/etc/rancher/k3s/registries.yaml"
  }
}

output "registry_port" {
  value = var.registry_port
}

output "registry_service_ip" {
  value = var.registry_service_ip
}
