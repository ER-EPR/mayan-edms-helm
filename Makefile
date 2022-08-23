#!make
include config.env

help:
	@echo "Usage: make <target>\n"
	@awk 'BEGIN {FS = ":.*##"} /^[0-9a-zA-Z_-]+:.*?## / { printf "  * %-40s -%s\n", $$1, $$2 }' $(MAKEFILE_LIST)|sort

minikube-install: ## Install the Helm chart on the local minikube cluster.
minikube-install: minikube-namespace-create
	helm install minikube mayan-edms --namespace minikube --timeout 15m --values mayan-edms/values-minikube.yaml

minikube-namespace-create:
	kubectl create namespace minikube || true

minikube-namespace-delete:
	kubectl delete namespace minikube || true

minikube-upgrade: ## Upgrade the development release on the local minikube cluster.
minikube-upgrade:
	helm upgrade minikube mayan-edms --namespace minikube --timeout 15m --values mayan-edms/values-minikube.yaml

minikube-uninstall: ## Uninstall the development release from the local minikube cluster.
minikube-uninstall:
	helm uninstall minikube; kubectl delete jobs.batch minikube-initialsetup minikube-performupgrade --namespace minikube || true

helm-package: ## Create a Helm repository package.
helm-package:
	helm package mayan-edms --app-version ${HELM_PACKAGE_VERSION} --destination ./build
	helm repo index build/ --url ${HELM_REPO_URL}
