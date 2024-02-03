ARG BASE=nvidia/cuda:12.2.2-base-ubuntu22.04
FROM ${BASE}

ARG DEVICE="cu121"
ARG BUILD_COUNTRY=""

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

COPY ./ /m4t_server

WORKDIR /m4t_server
# 中国境内修改源，加速下载
RUN if [ "x$BUILD_COUNTRY" = "xCN" ]; then \
    mkdir -p /root/.config/pip && \
    echo "No valid webserver specified" &&  \
    echo "[global]" > /root/.config/pip/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /root/.config/pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple/" >> /root/.config/pip/pip.conf; \
    fi
    # && \
    # echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    # echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >>/etc/apt/sources.list && \
    # echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse"  >>/etc/apt/sources.list && \
    # echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list && \
    # echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list &&
# RUN apt-get update -y &&  apt-get install -y python3 python3-pip && \
#   pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cpu -r ./requirements.txt && \
#   rm -rf /var/lib/apt/lists/*

RUN apt-get update -y && \
if [ "$DEVICE" = "cpu" ]; then \
pip install --no-cache-dir --extra-index-url "https://download.pytorch.org/whl/cpu" -r ./requirements.txt; \
else \
apt-get install -y python3 python3-pip && \
pip install --no-cache-dir --extra-index-url "https://download.pytorch.org/whl/cu121" -r ./requirements.txt; \
fi && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /root/.cache/pip


EXPOSE 50051

ENV SERVER_PORT=50051 \
  MODEL_PATH="/models"


# scan epub dir
VOLUME [ "/models" ]
VOLUME [ "/speakers" ]


ENTRYPOINT ["/m4t_server/docker-entrypoint.sh"]
CMD ["./serve.py"]