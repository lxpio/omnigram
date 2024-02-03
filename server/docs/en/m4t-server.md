# m4t server

当前 `m4t server`` 提供xTTS对外的grpc服务。

```protobuf
service TextToAudio {
  rpc ConvertTextToAudio(TextRequest) returns (AudioResponse);
  rpc TTSStream(TextRequest) returns (stream AudioResponse);

  //...

}
```


### 1. 部署方式

#### 1.1 下载模型

当前TTS基于 https://github.com/coqui-ai/TTS 实现，默认模型使用的是 [Hugging Face Hub](https://huggingface.co/coqui/XTTS-v2)，
运行前前往下载。

#### 1.2 docker 方式

```bash
# 这里假定你下载的目录为 /opt/MY_TTS/XTTS-v2
# git clone https://huggingface.co/coqui/XTTS-v2 /opt/MY_TTS/XTTS-v2
# 直接启动 `nvidia-container-toolkit` 参考文件最后 安装方法
docker run --rm -v --gpus all /opt/MY_TTS/XTTS-v2:/models/XTTS -v /opt/speakers:/speakers lxpio/m4t-server:latest

#gpu 版本需要

#如果不支持cuda则使用 lxpio/m4t-server:v0.1.5-cpu
docker run --rm -v  /opt/MY_TTS/XTTS-v2:/models/XTTS -v /opt/speakers:/speakers lxpio/m4t-server:v0.1.5-cpu

```


#### 1.3 linux 方式

1. 安装 python 环境（略）

2. 前台启动服务

```bash
# conda create -n m4t python=3.10
cd ${PROJECT_DIR}/m4t_server
pip install -r ./requirements.txt

python serve.py
python serve.py --model-path ~/HHD1/XTTS-v2/ --speakers-path ./samples/
```

3. systemd 服务

将如下两个变量 `MY_PYTHON_PATH`, `MY_MODEL_PATH` 替换为自己实际的目录：

```bash
cd ${PROJECT_DIR}/m4t_server
sudo MY_PYTHON_PATH='/opt/anaconda3/envs/m4t/bin/python' MY_MODEL_PATH='./model/xtts_v1' ./install.sh

```


### 2. 开发选项

```
conda create -n m4t python=3.10
pip install pipreqs
python3 -m  pipreqs.pipreqs . --force
```


### GPU 支持

参考 [Installing the NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) 如果需要让docker支持cuda，需要提前安装 `nvidia-container-toolkit`

```
#Configure the production repository:
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install the NVIDIA Container Toolkit packages:
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

```


FAQ:

if you run docker with `--gpus all` then meet this error message:

> docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]. 

then you should install `nvidia-container-toolkit`



```
# docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]].
```