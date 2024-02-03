# Makefile.

PROJECT_PATH=$(shell cd "$(dirname "$0" )" &&pwd)
PROJECT_NAME=omnigram-server
# VERSION=$(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
VERSION=v0.0.1
BUILD_DATE=$(shell date -u '+%Y-%m-%d_%I_%M_%S%p')
BUILD_HASH=$(shell git rev-parse HEAD)
LDFLAGS="-X main.BUILDSTAMP=${BUILD_DATE} -X main.GITHASH=${BUILD_HASH} -X github.com/lxpio/omnigram/server/api/conf.Version=${VERSION} -s -w"
# SHELL := /bin/bash
DESTDIR=${PROJECT_PATH}/build/omnigram-server-${VERSION}


.PHONY: all


all : omnigram-server


service/m4t/m4t_grpc.pb.go service/m4t/m4t.pb.go:
	@$(MAKE) -C api/m4t/ protos

m4t_server/pb/m4t_pb2_grpc.py m4t_server/pb/m4t_pb2.pyi m4t_server/pb/m4t_pb2.py:
	pip install grpcio-tools
	@$(MAKE) -C m4t_server/ protos

protos: service/m4t/m4t_grpc.pb.go service/m4t/m4t.pb.go 
	@$(MAKE) -C api/m4t/ protos
	@$(MAKE) -C m4t_server/ protos


omnigram-server: service/m4t/m4t_grpc.pb.go service/m4t/m4t.pb.go
	@echo "create omnigram-server-${VERSION} "
	@#debian上直接使用mkdir不会创建，需要额外调用 bash-c 
	@bash -c "mkdir -p ${DESTDIR}/{conf,bin,data}"

	@echo "copy default configure file"
	@cp -f ${PROJECT_PATH}/conf/conf.yaml ${DESTDIR}/conf/conf.yaml

	@echo "build github.com/lxpio/omnigram-server"
	@env  go build -ldflags ${LDFLAGS} -o ${DESTDIR}/bin/omni-server github.com/lxpio/omnigram/server/api/cmd/omni-server

docs:
    # you should install apidoc cli first by `npx install -g apidoc`
	@apidoc -i ./  -f ".*\\.go$" -o apidoc


docker:
	@docker buildx build --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_HASH=${BUILD_HASH} --build-arg BUILD_HASH=${VERSION} -t omnigram-server:${VERSION} ./

docker_cn:
	@docker buildx build --build-arg BUILD_COUNTRY="CN" --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_HASH=${BUILD_HASH} --build-arg BUILD_VERSION=${VERSION} -t omnigram-server:${VERSION} ./

clean:
	# rm -rf ${DESTDIR}
	# docker rmi omnigram-server:${VERSION}
	@$(MAKE) -C api/m4t/ clean
	@$(MAKE) -C m4t_server/ clean

run_docker: docker
	docker run --rm -v ${LOCAL_EPUB_DIR}:/epub ${LOCAL_MATA_DIR}:/metadata omnigram-server:${VERSION}






