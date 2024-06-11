FROM golang:1.22.4-bookworm AS golang

RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -d -b $(go env GOPATH)/bin v1.54.2
RUN wget https://github.com/hairyhenderson/gomplate/releases/download/v3.11.5/gomplate_linux-$(go env GOARCH) -O $(go env GOPATH)/bin/gomplate && \
    chmod 755 $(go env GOPATH)/bin/gomplate

RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go install github.com/swaggo/swag/cmd/swag@v1.16.2
RUN go install github.com/golang/mock/mockgen@v1.6.0
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1

FROM ubuntu:noble

WORKDIR /
COPY ubuntu.sources /etc/apt/sources.list.d/
RUN dpkg --add-architecture arm64 && apt update -y && apt install git make wget -y

RUN wget -O- -nv https://golang.google.cn/dl/go1.22.4.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV GOLANG_VERSION=1.22.4
ENV GOTOOLCHAIN=local
ENV GOPATH=/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
COPY --from=golang $GOPATH/bin $GOPATH/bin

RUN apt install -y protobuf-compiler gcc gcc-aarch64-linux-gnu \
    libpcap-dev libpcap-dev:arm64 libsystemd-dev libsystemd-dev:arm64 \
    libibverbs-dev libibverbs-dev:arm64 libcap-dev libcap-dev:arm64 libnl-3-dev libnl-3-dev:arm64 && \
    apt-get clean
