# Kubernetes development environment

This repository contains terraform modules used to setup a Kubernetes development environment in Hetzner Cloud.

> [!WARNING]
> This project is not an official Hetzner Cloud Integration and is intended to be used internally. There is no backwards-compatibility promise.

## Modules

The environment is split in two modules that **must be used in two separate states**:

| Module          | Manages                                                                                  |
| --------------- | ---------------------------------------------------------------------------------------- |
| `modules/infra` | Hetzner Cloud resources (SSH key, network, servers) and the k3s cluster running on them. |
| `modules/k8s`   | Resources inside the cluster (hcloud Secret, Cilium, hccm, csi-driver, Docker registry). |

The `kubernetes` and `helm` providers of the `k8s` module are configured from an input variable, and never from an attribute of a resource in the same state. Terraform can therefore always plan and destroy the in-cluster resources, even while the cluster is being replaced or is already gone. Recreating the cluster (e.g. when changing the k3s version) simply recreates the in-cluster resources on the next apply, instead of stranding them in a state that points at a cluster that no longer exists.

The `infra` state must be applied before the `k8s` state, and destroyed after it. See [`example/`](./example) for the wiring between both states, done with a `terraform_remote_state` data source.

## Usage

To setup a development environment, make sure you installed the following tools:

- [tofu](https://opentofu.org/)
- [k3sup](https://github.com/alexellis/k3sup)

1. Configure a `HCLOUD_TOKEN` in your shell session.

> [!WARNING]
> The development environment runs on Hetzner Cloud servers which will induce costs.

2. Deploy the development cluster:

```sh
make -C example up
```

3. Load the generated configuration to access the development cluster:

```sh
source example/files/env.sh
```

4. Check that the development cluster is healthy:

```sh
kubectl get nodes -o wide
```

⚠️ Do not forget to clean up the development cluster once are finished:

```sh
make -C example down
```
