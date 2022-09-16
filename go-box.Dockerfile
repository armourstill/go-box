FROM golang:1.18.2-alpine3.15 AS builder

# 给中间镜像打标记
LABEL stage=yz-builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk --no-cache add gcc musl-dev

# For Golang
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go install github.com/swaggo/swag/cmd/swag@v1.8.4
RUN go install github.com/golang/mock/mockgen@v1.6.0
RUN go install github.com/gogo/protobuf/protoc-gen-gofast@v1.3.2
RUN go install github.com/mwitkow/go-proto-validators/protoc-gen-govalidators@v0.3.2
RUN go install github.com/yannh/kubeconform/cmd/kubeconform@v0.4.14
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1
# v1.46.0版本有bug，在golang<1.17时无法编译，因此版本强制为v1.45.2以兼容本地环境为golang-1.17以下的开发者
RUN CGO_ENABLED=0 go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.45.2

# 真实镜像
FROM golang:1.18.2-alpine3.15

ARG KUBECONFORM_CACHE=/kubeconform-cache

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk --no-cache add gcc musl-dev make git protoc bash

RUN go env -w GOPROXY=https://goproxy.cn,direct

COPY --from=builder /go/bin /go/bin
COPY kubeconform-cache ${KUBECONFORM_CACHE}/

WORKDIR /
