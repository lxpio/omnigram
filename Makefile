#Makefile




openapi:
	@echo "openapi build"
	@rm -rf app/openapi
	@openapi-generator-cli generate -g dart-dio -i ./omnigram.openapi.spec.yaml -o app/openapi 
	#@openapi-generator generate -g dart -i ./omnigram.openapi.spec.yaml -o app/openapi 
	@cd app/openapi && dart run build_runner build
	@patch -p1 < patch/tts_stream.patch

build_runner:
	@echo "build_runner build"
	@flutter clean
	@dart run build_runner build



release: l10n
	@echo "release build"
	@flutter build appbundle 


apk: l10n
	@flutter build apk --split-per-abi