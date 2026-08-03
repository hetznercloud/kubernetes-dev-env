SHELL = bash

MODULES = modules/infra modules/k8s

fmt:
	tofu fmt -recursive

validate:
	for module in $(MODULES); do \
		tofu -chdir=$$module init -backend=false || exit 1; \
		tofu -chdir=$$module validate || exit 1; \
	done
