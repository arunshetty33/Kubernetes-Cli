FROM golang:1.8-alpine as builder

ENV HELM_HOME=/opt/helm
ENV HELM_PLUGIN=/opt/helm/plugins
ENV TILLER_NAMESPACE=kube-system

ENV CACHE_BUSTER=1

RUN apk --no-cache add \
  bash \
  curl \
  wget \
  git \
  jq \
  ca-certificates \
  make \
  file

# Helm and plugins were eating up a bunch of space on the image that we don't actually need in the end
RUN \
  mkdir -p /tmp/helm && cd /tmp/helm && \
  wget -q https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz -O helm-v2.7.2-linux-amd64.tar.gz && \
  tar -xvzf /tmp/helm/helm-v2.7.2-linux-amd64.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  cd / && rm -rf /tmp/helm

RUN mkdir -p $GOPATH/src/github.com/databus23/helm-diff && \
    cd $GOPATH/src/github.com/databus23/helm-diff && \
    git clone https://github.com/jrnt30/helm-diff . && \
    git checkout new-chart-suppressed && \
    curl https://glide.sh/get | sh && \
    make install && \
    rm -Rf $GOPATH/src/github.com/




############################################################

FROM alpine:latest

ENV HELM_HOME=/opt/helm
ENV HELM_PLUGIN=/opt/helm/plugins
ENV TILLER_NAMESPACE=kube-system
ENV TF_PLUGIN_CACHE_DIR=/opt/terraform/plugins
ENV TERRAGRUNT_SOURCE_UPDATE=true

RUN apk --no-cache add \
  bash \
  curl \
  wget \
  git \
  jq \
  ca-certificates \
  make \
  file

RUN \
  wget -q https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip -O /tmp/terraform.zip && \
  unzip -d /usr/local/bin /tmp/terraform.zip && \
  rm -rf /tmp/terraform.zip

RUN \
  wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.14.0/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod a+x /usr/local/bin/terragrunt

RUN \
  wget -q https://github.com/kubernetes/kops/releases/download/1.8.1/kops-linux-amd64 -O /usr/local/bin/kops && \
  chmod a+x /usr/local/bin/kops

RUN \
  wget -q https://storage.googleapis.com/kubernetes-release/release/v1.8.5/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
  chmod a+x /usr/local/bin/kubectl

RUN \
  wget -q https://github.com/heptio/ark/releases/download/v0.7.1/ark-v0.7.1-linux-amd64.tar.gz -O ark-v0.7.1-linux-amd64.tar.gz && \
  tar -xvzf ark-v0.7.1-linux-amd64.tar.gz && \
  mv ark /usr/local/bin/ark && \
  chmod a+x /usr/local/bin/ark && \
  rm ark-v0.7.1-linux-amd64.tar.gz
<<<<<<< HEAD

RUN \
  wget -q https://github.com/jenkins-x/jx/releases/download/v1.2.69/jx-linux-amd64.tar.gz && \
  tar -xvzf jx-linux-amd64.tar.gz && \
  mv jx /usr/local/bin/jx && \
  chmod a+x /usr/local/bin/jx


=======
  
>>>>>>> 46811a7b4a32695d3c0aac8f151a6604c9898b53
COPY --from=builder /usr/local/bin/helm /usr/local/bin/helm

COPY --from=builder /opt/helm/plugins/helm-diff /opt/helm/plugins/helm-diff

RUN \
  wget -q https://github.com/roboll/helmfile/releases/download/v0.8/helmfile_linux_amd64 -O /usr/local/bin/helmfile && \
  chmod a+x /usr/local/bin/helmfile

RUN helm init -c && \
    helm plugin install https://github.com/technosophos/helm-template && \
    helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

ADD bin /tmp/local-bins/

WORKDIR /root

ADD default.tf /opt/terraform/default.tf
RUN cd /opt/terraform && terraform init
