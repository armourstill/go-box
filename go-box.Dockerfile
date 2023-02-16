FROM golang:1.18.2-alpine3.15 AS gb-base

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk --no-cache add gcc musl-dev

FROM gb-base AS gb-go

# For Golang
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -d -b $(go env GOPATH)/bin v1.50.1
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go install github.com/swaggo/swag/cmd/swag@v1.8.10
RUN go install github.com/golang/mock/mockgen@v1.6.0
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
RUN go install github.com/yannh/kubeconform/cmd/kubeconform@v0.4.14
RUN go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v1.5.1

# The real go-box image
FROM gb-base

ARG KUBECONFORM_CACHE=/kubeconform-cache

RUN apk --no-cache add bash git make protoc protobuf-dev 

COPY --from=gb-go /go/bin /go/bin
COPY kubeconform-cache ${KUBECONFORM_CACHE}/

WORKDIR /
