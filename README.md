# Kafka manager

Tool (https://github.com/yahoo/kafka-manager) to monitor and manager kafka brokers, topics, consumers etc.

The Dockerfile was inspired by https://github.com/sheepkiller/kafka-manager-docker. The entrypoint was stole from it :)

# Setup

## How to run

```
make run
```

You can override the zookeeper host (used to store clusters configurations) by defining the `ZK_HOSTS` environment variable:

```
make ZK_HOSTS=myzk:2181 run
```

## How to deploy

This will deploy to the production k8s:

```
make deploy
```

To deploy to QA environment, simply do:

```
make ENV=qa deploy
```

Its possible to override the namespace and the k8s cluster like this:

```
make K8S_NAMESPACE=mynamespace K8S_CLUSTER=my-k8s.myorg.com deploy
```
