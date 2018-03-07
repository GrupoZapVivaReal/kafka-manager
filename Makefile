
KM_VERSION?=1.3.3.17

ORG?=vivareal
PROJECT?=kafka-manager

ENV:=prod

COMMIT_HASH=$(shell git rev-parse --short=7 HEAD)
VERSION?=$(shell git show --format=%cd --date=format:'%y%m%d.%H%M' $(COMMIT_HASH) | head -n 1)-$(COMMIT_HASH)
IMAGE_NAME:=$(ORG)/$(PROJECT):$(VERSION)

K8S_NAMESPACE?=search

build:
	docker build --build-arg KM_VERSION=$(KM_VERSION) -t $(IMAGE_NAME) .

push: build
	docker push $(IMAGE_NAME)

run:
	docker run -it --rm -p 9000:9000 -e ZK_HOSTS=$(ZK_HOSTS) $(IMAGE_NAME)

generate-deployment: zk_hosts
	PROJECT=$(PROJECT) K8S_NAMESPACE=$(K8S_NAMESPACE) ENV=$(ENV) VERSION=$(VERSION) ZK_HOSTS=$(ZK_HOSTS) IMAGE_NAME=$(IMAGE_NAME) envsubst < deploy/k8s.yaml.tmpl > deploy/k8s.yaml

deploy: k8s_token k8s_cluster generate-deployment push
	kubectl -n $(K8S_NAMESPACE) -s $(K8S_CLUSTER) --token=$(K8S_TOKEN) --insecure-skip-tls-verify apply --record -f deploy/k8s.yaml

k8s_token:
	$(if $(value K8S_TOKEN),,$(error "K8S_TOKEN is required for Makefile"))

k8s_cluster:
	$(if $(value K8S_CLUSTER),,$(error "K8S_CLUSTER is required for Makefile"))

zk_hosts:
	$(if $(value ZK_HOSTS),,$(error "ZK_HOSTS is required for Makefile"))
