# Changelog

## [v0.9.2](https://github.com/hetznercloud/kubernetes-dev-env/releases/tag/v0.9.2)

### Bug Fixes

- helm provider API changes (#149)

## [v0.9.1](https://github.com/hetznercloud/kubernetes-dev-env/releases/tag/v0.9.1)

### Bug Fixes

- k3sup breaking changes (#117)

## [v0.9.0](https://github.com/hetznercloud/kubernetes-dev-env/releases/tag/v0.9.0)

### Features

- support Kubernetes v1.33

## [0.8.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.7.0...v0.8.0) (2025-02-06)


### Features

* allow setting HCLOUD_ENDPOINT env for hccm ([#83](https://github.com/hetznercloud/kubernetes-dev-env/issues/83)) ([06375c4](https://github.com/hetznercloud/kubernetes-dev-env/commit/06375c49abfbacb7b432477751b7a589d3528f83))

## [0.7.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.6.0...v0.7.0) (2025-01-10)


### Features

* arbitrary additional labels on Hetzner resources ([#55](https://github.com/hetznercloud/kubernetes-dev-env/issues/55)) ([b3f4b39](https://github.com/hetznercloud/kubernetes-dev-env/commit/b3f4b39f35af1e3afb157d13113fdabb5a6d6fe5))

## [0.6.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.5.2...v0.6.0) (2024-10-23)


### Features

* optional csi-driver deployment ([#51](https://github.com/hetznercloud/kubernetes-dev-env/issues/51)) ([331c11b](https://github.com/hetznercloud/kubernetes-dev-env/commit/331c11b92607a2a6851adcc02bda4c9f3d958c30)), closes [#50](https://github.com/hetznercloud/kubernetes-dev-env/issues/50)


### Bug Fixes

* Move infrastructure to Helsinki ([#57](https://github.com/hetznercloud/kubernetes-dev-env/issues/57)) ([08dfcfd](https://github.com/hetznercloud/kubernetes-dev-env/commit/08dfcfd83721cbc94bbecda43d6963815a42ab07))

## [0.5.2](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.5.1...v0.5.2) (2024-08-09)


### Bug Fixes

* do not pin module dependencies ([#42](https://github.com/hetznercloud/kubernetes-dev-env/issues/42)) ([4cb58cc](https://github.com/hetznercloud/kubernetes-dev-env/commit/4cb58ccb71fefc6a85d21563b5165c580a3509d4))
* ignore temporary state files ([#34](https://github.com/hetznercloud/kubernetes-dev-env/issues/34)) ([5eb6bef](https://github.com/hetznercloud/kubernetes-dev-env/commit/5eb6bef5c53b5ea53f94f00b82f080b1278792ec))
* make registry-port-forward down idempotent ([#38](https://github.com/hetznercloud/kubernetes-dev-env/issues/38)) ([bedb933](https://github.com/hetznercloud/kubernetes-dev-env/commit/bedb933cae34cb87187b09c821d3fb512e8c38f0))

## [0.5.1](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.5.0...v0.5.1) (2024-07-08)


### Bug Fixes

* broken cluster if resources are installed in wrong order ([#25](https://github.com/hetznercloud/kubernetes-dev-env/issues/25)) ([28e1878](https://github.com/hetznercloud/kubernetes-dev-env/commit/28e1878afb389e33d474d8596935f522334e3c70))

## [0.5.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.4.0...v0.5.0) (2024-07-05)


### Features

* add support for macOS ([#19](https://github.com/hetznercloud/kubernetes-dev-env/issues/19)) ([4b6513e](https://github.com/hetznercloud/kubernetes-dev-env/commit/4b6513e76cb0d9757e96a24bff73ec04edde2c63))

## [0.4.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.3.0...v0.4.0) (2024-07-05)


### Features

* output for the kubeconfig filename ([#22](https://github.com/hetznercloud/kubernetes-dev-env/issues/22)) ([8411724](https://github.com/hetznercloud/kubernetes-dev-env/commit/841172497191c1613393fad1ca2c21849f6ec1df))

## [0.3.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.2.0...v0.3.0) (2024-07-04)


### Features

* change workers_count default to 1 ([#16](https://github.com/hetznercloud/kubernetes-dev-env/issues/16)) ([df359ff](https://github.com/hetznercloud/kubernetes-dev-env/commit/df359ff7ba3a0190e5e7507eae0ccf10efab3122))
* necessary features for hcloud-cloud-controller-manager ([#14](https://github.com/hetznercloud/kubernetes-dev-env/issues/14)) ([d51ba12](https://github.com/hetznercloud/kubernetes-dev-env/commit/d51ba126d917bb752d6e446ee8039f6404a8f3a7))
* write public key to local file  ([#17](https://github.com/hetznercloud/kubernetes-dev-env/issues/17)) ([88395fd](https://github.com/hetznercloud/kubernetes-dev-env/commit/88395fdd559bc7185a8594fb3c8fbce265472c6c))

## [0.2.0](https://github.com/hetznercloud/kubernetes-dev-env/compare/v0.1.0...v0.2.0) (2024-06-27)


### Features

* setup initial module ([#3](https://github.com/hetznercloud/kubernetes-dev-env/issues/3)) ([90b350d](https://github.com/hetznercloud/kubernetes-dev-env/commit/90b350d748048ecb99b28fe43af618c9f847ceb1))
