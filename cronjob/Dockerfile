FROM frolvlad/alpine-glibc:latest

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
org.label-schema.name="helm-kubectl" \
org.label-schema.url="https://hub.docker.com/r/dtzar/helm-kubectl/" \
org.label-schema.vcs-url="https://github.com/dtzar/helm-kubectl" \
org.label-schema.build-date=$BUILD_DATE

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_LATEST_VERSION="v1.13.0"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.12.0"

RUN apk add --no-cache ca-certificates bash git \
&& wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
&& chmod +x /usr/local/bin/kubectl \
&& wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
&& chmod +x /usr/local/bin/helm

RUN apk add --no-cache curl jq

# specify the version string of the oc release
ENV OC_VERSION "v3.11.0"
ENV OC_RELEASE "openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit"

# install the oc client tools
ADD https://github.com/openshift/origin/releases/download/$OC_VERSION/$OC_RELEASE.tar.gz /opt/oc/release.tar.gz
RUN apk add --no-cache ca-certificates
RUN tar --strip-components=1 -xzvf /opt/oc/release.tar.gz -C /opt/oc/ && \
mv /opt/oc/oc /usr/local/bin/ && \
rm -rf /opt/oc

WORKDIR /config

CMD bash
