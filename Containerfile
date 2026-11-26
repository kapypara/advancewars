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

ARG ZIG_VERSION=0.17.1
ARG ZIG_SHA256=3581863e3cbcfd0fce0efc682ce7e9e93da96668a977791d356a26d2a7e9b17a
RUN curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz" -o /tmp/zig.tar.xz \
    && echo "${ZIG_SHA256}  /tmp/zig.tar.xz" | sha256sum -c - \
    && mkdir -p /opt/zig \
    && tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1 \
    && rm -f /tmp/zig.tar.xz \
    && ln -sf /opt/zig/zig /usr/local/bin/zig

WORKDIR /workspace
