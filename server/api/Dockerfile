# stage 2: build golang backend
FROM --platform=$BUILDPLATFORM golang:1.21.3-alpine3.18 as gobuilder

ARG TARGETOS
ARG TARGETARCH
ARG BUILD_COUNTRY=""
ARG BUILD_VERSION=""
ARG BUILD_DATE=""
ARG BUILD_HASH=""


COPY / /omnigram-server

WORKDIR /omnigram-server

# 中国境内修改源，加速下载
RUN if [ "x$BUILD_COUNTRY" = "xCN" ]; then \
    echo "using repo mirrors for ${BUILD_COUNTRY}"; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories; \
    go env -w GOPROXY=https://goproxy.cn,direct; \
    go env -w GO111MODULE=on;  \
    fi

RUN apk add build-base && \
    chmod +x /omnigram-server/docker-entrypoint.sh && \
    mkdir -p /build/data && mkdir /build/conf && mkdir /build/bin && \
    cp /omnigram-server/conf/conf.yaml /build/conf/conf.yaml && \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-X main.BUILDSTAMP=${BUILD_DATE} -X main.GITHASH=${BUILD_HASH} -X github.com/lxpio/omnigram/server/api/conf.Version=${BUILD_VERSION} -s -w" \
    -o /build/bin/omni-server github.com/lxpio/omnigram/server/api/cmd/omni-server



FROM --platform=$TARGETPLATFORM alpine:3.18.4

LABEL author="exppii" \
    description="omnigram-server"
# 注意使用 .dockerignore 忽略其他文件

COPY --from=gobuilder /build/ ./
COPY --from=gobuilder /omnigram-server/docker-entrypoint.sh ./

ENV CONFIG_FILE=/conf/conf.yaml \
  OMNI_PASSWORD="123456" \
  OMNI_USER="admin"


EXPOSE 80
# scan docs dir
VOLUME [ "/docs" ]
# save default metadata
VOLUME [ "/metadata" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["omni-server"]
