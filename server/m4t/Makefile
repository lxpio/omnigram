protos:
	@echo "===更新生成 m4t.proto python 端代码==="
	@mkdir -p pb
	@python -m grpc_tools.protoc --proto_path=../api/m4t/ --python_out=./pb --pyi_out=./pb --grpc_python_out=./pb ../api/m4t/m4t.proto
	@sed -i 's/import m4t_pb2 as m4t__pb2/import pb.m4t_pb2 as m4t__pb2/g' ./pb/m4t_pb2_grpc.py
refresh_deps:
	@pipreqs . --force --pypi-server https://pypi.tuna.tsinghua.edu.cn/simple


clean:
	@echo "clean protos"
	@rm -rf pb/* 

# docker:


docker_gpu:
	@docker buildx build --build-arg BUILD_COUNTRY="CN" -t m4t-server:0.0.2 ./

docker_cpu:
	@docker buildx build --build-arg BUILD_COUNTRY="CN" --build-arg DEVICE="cpu" -t m4t-server:0.0.2-cpu ./

