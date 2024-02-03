protos:
	@echo "===更新生成 m4t.proto golang 端代码==="
	@protoc --go_out=./ --go-grpc_out=./ --go_opt=paths=source_relative  --go-grpc_opt=paths=source_relative m4t.proto

clean:
	@echo "clean protos"
	@rm  ./m4t.pb.go ./m4t_grpc.pb.go