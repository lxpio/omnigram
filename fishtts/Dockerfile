FROM python:3.12-slim-bookworm
ARG TARGETARCH

ARG DEPENDENCIES="  \
    ca-certificates \
    libsox-dev \
    build-essential \
    cmake \
    libasound-dev \
    portaudio19-dev \
    libportaudio2 \
    libportaudiocpp0 \
    ffmpeg"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

COPY fish-speech /opt/fish-speech
COPY docker-entrypoint.sh /opt/fish-speech/docker-entrypoint.sh
    
WORKDIR /opt/fish-speech
    
RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    set -ex \
    && pip install -e .[stable]



EXPOSE 8999

ENV LISTEN_ADDR="0.0.0.0:8999" 
# scan epub dir
VOLUME [ "/opt/fish-speech/checkpoints" ]
VOLUME [ "/speakers" ]

ENTRYPOINT ["/docker-entrypoint.sh"]



