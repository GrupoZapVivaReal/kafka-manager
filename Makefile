
KM_VERSION?=1.3.3.16

ORG?=vivareal
PROJECT?=kafka-manager

ENV:=prod

COMMIT_HASH=$(shell git rev-parse --short=7 HEAD)
VERSION?=$(shell git show --format=%cd --date=format:'%y%m%d.%H%M' $(COMMIT_HASH) | head -n 1)-$(COMMIT_HASH)
IMAGE_NAME:=$(ORG)/$(PROJECT):$(VERSION)

ZK_HOSTS_PROD="zk0.blue.kafka.platform.prod.us-east-1.vivareal.io:2181,zk1.blue.kafka.platform.prod.us-east-1.vivareal.io:2181,zk2.blue.kafka.platform.prod.us-east-1.vivareal.io:2181,zk3.blue.kafka.platform.prod.us-east-1.vivareal.io:2181,zk4.blue.kafka.platform.prod.us-east-1.vivareal.io:2181"
ZK_HOSTS_QA="zk1.blue.kafka.platform.qa.us-east-1.vivareal.io:2181,zk2.blue.kafka.platform.qa.us-east-1.vivareal.io:2181,zk3.blue.kafka.platform.qa.us-east-1.vivareal.io:2181"
ZK_HOSTS?=$(if $(filter prod,$(ENV)),$(ZK_HOSTS_PROD),$(ZK_HOSTS_QA))

K8S_NAMESPACE?=search

K8S_CLUSTER_NAME_PROD=https://api.k8s.prod.vivareal.io
K8S_CLUSTER_NAME_QA=https://api.k8s.qa.vivareal.io
K8S_CLUSTER_NAME?=$(if $(filter prod,$(ENV)),$(K8S_CLUSTER_NAME_PROD),$(K8S_CLUSTER_NAME_QA))

K8S_CMD:=kubectl -n $(K8S_NAMESPACE) -s $(K8S_CLUSTER_NAME) --token=$(K8S_TOKEN) --insecure-skip-tls-verify

build:
	docker build --build-arg KM_VERSION=$(KM_VERSION) -t $(IMAGE_NAME) .

push: build
	docker push $(IMAGE_NAME)

run:
	docker run -it --rm -p 9000:9000 -e ZK_HOSTS=$(ZK_HOSTS) $(IMAGE_NAME)

generate-deployment:
	PROJECT=$(PROJECT) K8S_NAMESPACE=$(K8S_NAMESPACE) ENV=$(ENV) VERSION=$(VERSION) ZK_HOSTS=$(ZK_HOSTS) IMAGE_NAME=$(IMAGE_NAME) envsubst < deploy/k8s.yaml.tmpl > deploy/k8s.yaml

deploy: generate-deployment push
	$(K8S_CMD) apply --record -f deploy/k8s.yaml
