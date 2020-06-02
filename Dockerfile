FROM debian:latest as build

ARG CMAK_VERSION=3.0.0.4

WORKDIR /opt/build

RUN apt-get update && apt-get install -y wget unzip && wget https://github.com/yahoo/CMAK/releases/download/$CMAK_VERSION/cmak-$CMAK_VERSION.zip && unzip cmak-$CMAK_VERSION.zip && mv /opt/build/cmak-$CMAK_VERSION /opt/cmak

FROM openjdk:11-jdk-slim

WORKDIR /opt/cmak

VOLUME /tmp

COPY --from=build /opt/cmak/ /opt/cmak/

EXPOSE 9000

ENTRYPOINT ["./bin/cmak"]
