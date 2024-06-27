SHELL = bash

.terraform:
	tofu init -backend=false

fmt: .terraform
	tofu fmt -recursive

validate: .terraform
	tofu validate
