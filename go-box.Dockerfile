FROM golang:1.20.5-buster AS base

RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -d -b $(go env GOPATH)/bin v1.54.2
RUN wget https://github.com/hairyhenderson/gomplate/releases/download/v3.11.5/gomplate_linux-$(go env GOARCH) -O $(go env GOPATH)/bin/gomplate && \
    chmod 755 $(go env GOPATH)/bin/gomplate

FROM base AS go-install

RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go install github.com/swaggo/swag/cmd/swag@v1.16.2
RUN go install github.com/golang/mock/mockgen@v1.6.0
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0
RUN go install github.com/yannh/kubeconform/cmd/kubeconform@v0.6.1
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1

# The real go-box image
FROM golang:1.20.5-buster
# FROM golang:1.21.1-bookworm

ARG KUBECONFORM_CACHE=/kubeconform-cache

RUN dpkg --add-architecture arm64
## For bookworm
# RUN sed -i '/^Signed-By/a\Architectures: amd64 arm64' /etc/apt/sources.list.d/debian.sources
## For buster
RUN sed -i 's/^deb http/deb [arch=amd64,arm64] http/g' /etc/apt/sources.list
RUN apt update -y && apt install -y \
    protobuf-compiler gcc-aarch64-linux-gnu libpcap-dev libpcap-dev:arm64

COPY --from=go-install /go/bin /go/bin
COPY kubeconform-cache ${KUBECONFORM_CACHE}/

WORKDIR /
