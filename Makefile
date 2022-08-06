#!make
include config.env

help:
	@echo "Usage: make <target>\n"
	@awk 'BEGIN {FS = ":.*##"} /^[0-9a-zA-Z_-]+:.*?## / { printf "  * %-40s -%s\n", $$1, $$2 }' $(MAKEFILE_LIST)|sort

minikube-install: ## Install the Helm chart on the local minikube cluster.
minikube-install:
	helm install development mayan-edms --timeout 15m --values mayan-edms/values.yaml

minikube-upgrade: ## Upgrade the development release on the local minikube cluster.
minikube-upgrade:
	helm upgrade development mayan-edms --timeout 15m --values mayan-edms/values.yaml

minikube-uninstall: ## Uninstall the development release from the local minikube cluster.
minikube-uninstall:
	helm uninstall development


helm-package: ## Create a Helm repository package.
helm-package:
	helm package mayan-edms --app-version ${HELM_PACKAGE_VERSION} --destination ./build
	helm repo index build/ --url ${HELM_REPO_URL}

kubectl-namespace-create:
	kubectl create namespace mayan-edms-testing || true

testing-elasticsearch-install: ## Install testing ElasticSearch
testing-elasticsearch-install: kubectl-namespace-create
	helm install elasticsearch bitnami/elasticsearch --namespace mayan-edms-testing --set security.elasticPassword=mayanespassword,master.masterOnly=false,master.replicas=1,master.replicaCount=1,data.replicaCount=1,data.replicas=1,coordinating.replicaCount=1,coordinating.replicas=1,ingest.replicaCount=1,ingest.replicas=1,extraEnvVars[0].name=discovery.type,extraEnvVars[0].value=single-node,extraEnvVars[1].name=ES_JAVA_OPTS,extraEnvVars[1].value="-Xms256m -Xmx256m" --version 17.9.29

testing-elasticsearch-uninstall: ## Uninstall testing ElasticSearch
testing-elasticsearch-uninstall:
	helm uninstall elasticsearch --namespace mayan-edms-testing


testing-mayan-install: ## Install testing PostgreSQL
testing-mayan-install: kubectl-namespace-create
	helm install mayan mayan-edms --namespace mayan-edms-testing --set \
	secrets.MAYAN_DATABASES="\{\"default\":\{\"ENGINE\":\"django.db.backends.postgresql\"\,\"NAME\":\"mayan\"\,\"PASSWORD\":\"mayandbpass\"\,\"USER\":\"mayan\"\,\"HOST\":\"postgresql.mayan-edms-testing.svc.cluster.local\"\,\"PORT\":5432\,\"CONN_MAX_AGE\":60\}\}",\
	secrets.MAYAN_CELERY_BROKER_URL=amqp://mayan:mayanrabbitpass@rabbitmq.mayan-edms-testing.svc.cluster.local:5672,\
	secrets.MAYAN_CELERY_RESULT_BACKEND="redis://:mayanredispass@redis-master.mayan-edms-testing.svc.cluster.local:6379/1",\
	secrets.MAYAN_LOCK_MANAGER_BACKEND_ARGUMENTS="\{\"redis_url\":\"redis://:mayanredispass@redis-master.mayan-edms-testing.svc.cluster.local:6379/2\"\}",\
	secrets.MAYAN_SEARCH_BACKEND_ARGUMENTS="\{\"client_host\":\"http://elasticsearch-coordinating-only.mayan-edms-testing.svc.cluster.local\"\,\"client_port\":9200\,\"client_http_auth\":[\"elastic\"\,\"mayanespassword\"]\,\"client_sniff_on_start\":False\,\"client_sniff_on_connection_fail\":False\,\"client_sniffer_timeout\":0}",\
	configuration.MAYAN_SEARCH_BACKEND=mayan.apps.dynamic_search.backends.elasticsearch.ElasticSearchBackend,\
	configuration.MAYAN_VIEWS_PAGINATE_BY=12 \
	--timeout 15m


testing-mayan-uninstall: ## Uninstall testing PostgreSQL
testing-mayan-uninstall:
	helm uninstall mayan --namespace mayan-edms-testing; \
	kubectl delete jobs.batch mayan-initialsetup


testing-postgresql-install: ## Install testing PostgreSQL
testing-postgresql-install: kubectl-namespace-create
	helm install postgresql bitnami/postgresql --namespace mayan-edms-testing --set auth.database=mayan,auth.username=mayan,auth.password=mayandbpass --version 11.6.16


testing-postgresql-uninstall: ## Uninstall testing PostgreSQL
testing-postgresql-uninstall:
	helm uninstall postgresql --namespace mayan-edms-testing


testing-rabbitmq-install: ## Install testing RabbitMQ
testing-rabbitmq-install: kubectl-namespace-create
	helm install rabbitmq bitnami/rabbitmq --namespace mayan-edms-testing --set auth.username=mayan,auth.password=mayanrabbitpass --version 10.1.12

testing-rabbitmq-uninstall: ## Uninstall testing RabbitMQ
testing-rabbitmq-uninstall:
	helm uninstall rabbitmq --namespace mayan-edms-testing


testing-redis-install: ## Install testing Redis
testing-redis-install: kubectl-namespace-create
	helm install redis bitnami/redis --namespace mayan-edms-testing --set auth.password=mayanredispass --version 16.13.2

testing-redis-uninstall: ## Uninstall testing Redis
testing-redis-uninstall:
	helm uninstall redis --namespace mayan-edms-testing
