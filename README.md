# Kubernetes development environment

This repository contains a terraform module used to setup a Kubernetes development environment in Hetzner Cloud.

> [!WARNING]
> This project is not an official Hetzner Cloud Integration and is intended to be used internally. There is no backwards-compatibility promise.

## Usage

To setup a development environment, make sure you installed the following tools:

- [tofu](https://opentofu.org/)
- [k3sup](https://github.com/alexellis/k3sup)

1. Configure a `HCLOUD_TOKEN` in your shell session.

> [!WARNING]
> The development environment runs on Hetzner Cloud servers which will induce costs.

2. Deploy the development cluster:

```sh
make -C dev up
```

3. Load the generated configuration to access the development cluster:

```sh
source files/env.sh
```

4. Check that the development cluster is healthy:

```sh
kubectl get nodes -o wide
```

⚠️ Do not forget to clean up the development cluster once are finished:

```sh
make -C dev down
```
