FROM alpine:latest
ARG KUBE_VERSION="1.11.1"
ARG HELM_VERSION="2.8.1"
ARG CLOUD_SDK_VERSION=247.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH

ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

# Install requirements
RUN apk add -U openssl curl tar git bash gcc gzip bash wget ca-certificates alpine-sdk unzip socat mysql-client sqlite netcat-openbsd

# Install python
RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base
RUN pip install virtualenv requests awscli google-cloud-storage

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \

# Install Helm
RUN apk add --update --no-cache curl ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm   
    

RUN apk --no-cache add \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version
    
CMD ["bash"]
