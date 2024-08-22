#Makefile




openapi:
	@echo "openapi build"
	@rm -rf app/openapi
	# @npx --yes @openapitools/openapi-generator-cli generate -g dart2 -i ./omnigram.openapi.spec.yaml -o openapi 
	@openapi-generator generate -g dart -i ./omnigram.openapi.spec.yaml -o app/openapi 
	@rm -rf ./analysis_options.yaml

build_runner:
	@echo "build_runner build"
	@flutter clean
	@dart run build_runner build



release: l10n
	@echo "release build"
	@flutter build appbundle 


apk: l10n
	@flutter build apk --split-per-abi