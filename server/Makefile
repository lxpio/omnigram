# Makefile.


api/m4t/m4t_grpc.pb.go api/m4t/m4t.pb.go:
	@$(MAKE) -C api/m4t/ protos

m4t_server/pb/m4t_pb2_grpc.py m4t_server/pb/m4t_pb2.pyi m4t_server/pb/m4t_pb2.py:
	pip install grpcio-tools
	@$(MAKE) -C m4t_server/ protos

protos: api/m4t/m4t_grpc.pb.go api/m4t/m4t.pb.go 
	@$(MAKE) -C api/m4t/ protos
	@$(MAKE) -C m4t_server/ protos


omnigram-server: api/m4t/m4t_grpc.pb.go api/m4t/m4t.pb.go
	@echo "create omnigram-server-${VERSION} "
	@#debian上直接使用mkdir不会创建，需要额外调用 bash-c 
	@bash -c "mkdir -p ${DESTDIR}/{conf,bin,data}"

	@echo "copy default configure file"
	@cp -f ${PROJECT_PATH}/conf/conf.yaml ${DESTDIR}/conf/conf.yaml

	@echo "build github.com/lxpio/omnigram-server"
	@env  go build -ldflags ${LDFLAGS} -o ${DESTDIR}/bin/omni-server github.com/lxpio/omnigram-server/cmd/omni-server

docs:
    # you should install apidoc cli first by `npx install -g apidoc`
	@apidoc -i ./  -f ".*\\.go$" -o apidoc


hub_docker:
	@docker buildx build --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_HASH=${BUILD_HASH} --build-arg BUILD_HASH=${VERSION} -t lxpio/omnigram-server:${VERSION} ./
	@docker tag lxpio/omnigram-server:${VERSION} lxpio/omnigram-server:latest
	@docker push lxpio/omnigram-server:latest
	@docker push lxpio/omnigram-server:${VERSION}

docker_cn:
	@docker buildx build --build-arg BUILD_COUNTRY="CN" --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_HASH=${BUILD_HASH} --build-arg BUILD_VERSION=${VERSION} -t omnigram-server:${VERSION} ./

clean:
	# rm -rf ${DESTDIR}
	# docker rmi omnigram-server:${VERSION}
	@$(MAKE) -C api/m4t/ clean
	@$(MAKE) -C m4t_server/ clean

run_docker: docker
	docker run --rm -v ${LOCAL_EPUB_DIR}:/epub ${LOCAL_MATA_DIR}:/metadata omnigram-server:${VERSION}






