FROM docker.io/library/debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    clang \
    cmake \
    curl \
    ffmpeg \
    g++ \
    gcc \
    git \
    libsdl2-dev \
    lld \
    ninja-build \
    pkg-config \
    python3 \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
