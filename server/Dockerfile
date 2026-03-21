# stage 1: build web frontend
FROM node:20-alpine AS webbuilder
COPY web/ /web/
WORKDIR /web
RUN npm ci && npm run build

# stage 2: build golang backend
FROM --platform=$BUILDPLATFORM golang:1.23.1-alpine3.20 as gobuilder

ARG TARGETOS
ARG TARGETARCH
ARG BUILD_COUNTRY=""
ARG BUILD_VERSION=""
ARG BUILD_DATE=""
ARG BUILD_HASH=""


COPY / /omnigram-server
COPY --from=webbuilder /web/dist /omnigram-server/web/dist

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
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-X main.BUILDSTAMP=${BUILD_DATE} -X main.GITHASH=${BUILD_HASH} -X github.com/lxpio/omnigram/server/conf.Version=${BUILD_VERSION} -s -w" \
    -o /build/bin/omni-server github.com/lxpio/omnigram/server/cmd/omni-server



FROM --platform=$TARGETPLATFORM alpine:3.20.3

LABEL author="exppii" \
    description="omnigram-server"

COPY --from=gobuilder /build/ ./
COPY --from=gobuilder /omnigram-server/docker-entrypoint.sh ./

# 非 root 用户运行
RUN addgroup -g 1000 omnigram && adduser -u 1000 -G omnigram -s /bin/sh -D omnigram && \
    chown -R omnigram:omnigram /data /conf /bin

ENV CONFIG_FILE=/conf/conf.yaml

EXPOSE 8080
# scan docs dir
VOLUME [ "/docs" ]
# save default metadata
VOLUME [ "/metadata" ]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -q --spider http://localhost:8080/healthz || exit 1

USER omnigram

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["omni-server"]
