ARG GO_VERSION=1.22.10

FROM golang:$GO_VERSION-bookworm AS golang
ARG GO_VERSION
RUN go install go.uber.org/mock/mockgen@v0.5.1
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1

FROM ubuntu:noble
ARG GO_VERSION
COPY ubuntu.sources /etc/apt/sources.list.d/
RUN dpkg --add-architecture arm64 && apt update -y && apt install -y curl git make wget protobuf-compiler gcc gcc-aarch64-linux-gnu \
    libpcap-dev libpcap-dev:arm64 libsystemd-dev libsystemd-dev:arm64 \
    libibverbs-dev libibverbs-dev:arm64 libcap-dev libcap-dev:arm64 libnl-3-dev libnl-3-dev:arm64 && \
    apt-get clean
RUN wget -O- -nv https://golang.google.cn/dl/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV GOLANG_VERSION=$GO_VERSION
ENV GOTOOLCHAIN=local
ENV GOPATH=/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY --from=golang $GOPATH/bin $GOPATH/bin
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.0.2
RUN wget https://github.com/hairyhenderson/gomplate/releases/download/v3.11.5/gomplate_linux-$(go env GOARCH) -O $(go env GOPATH)/bin/gomplate
RUN mkdir -p $GOPATH/src $GOPATH/bin && chmod -R 1777 $GOPATH
