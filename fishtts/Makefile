
# docker:


docker:
	git clone --depth 1 https://github.com/fishaudio/fish-speech.git   
	@docker buildx build -t lxpio/fish-speech:0.0.2 ./


clean:
	@docker rmi lxpio/fish-speech:0.0.2
	@rm -rf fish-speech
