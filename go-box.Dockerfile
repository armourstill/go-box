FROM golang:1.18.2-alpine3.15 AS builder

# 给中间镜像打标记
LABEL stage=gb-builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk --no-cache add gcc musl-dev

# For Golang
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -d -b $(go env GOPATH)/bin v1.50.1
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go install github.com/swaggo/swag/cmd/swag@v1.8.10
RUN go install github.com/golang/mock/mockgen@v1.6.0
RUN go install github.com/gogo/protobuf/protoc-gen-gofast@v1.3.2
RUN go install github.com/mwitkow/go-proto-validators/protoc-gen-govalidators@v0.3.2
RUN go install github.com/yannh/kubeconform/cmd/kubeconform@v0.4.14
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1

# 真实镜像
FROM golang:1.18.2-alpine3.15

ARG KUBECONFORM_CACHE=/kubeconform-cache

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk --no-cache add gcc musl-dev make git protoc bash

RUN go env -w GOPROXY=https://goproxy.cn,direct

COPY --from=builder /go/bin /go/bin
COPY kubeconform-cache ${KUBECONFORM_CACHE}/

WORKDIR /
