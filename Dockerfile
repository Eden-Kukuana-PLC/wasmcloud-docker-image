FROM --platform=$BUILDPLATFORM alpine:3.19 as build

ENV NATS_SERVER 2.10.12
ENV WADM_VERSION 0.10.0
ENV WASMCLOUD_VERSION 0.82.0

RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		aarch64) natsArch='arm64'; sha256='df353b32cc8813cc84b9a5fe131d702136bfbbcd3394d83cefe2dd59ecf9078c' ;; \
		armhf) natsArch='arm6'; sha256='665cd325e302b6536a846a0c4565f7c2fa2b83bed271ecda4255d508172920de' ;; \
		armv7) natsArch='arm7'; sha256='d5ff696d94dc0adc5a2d9863b42c139369b12c2b00e9768bc136d4f7dc50cbc2' ;; \
		x86_64) natsArch='amd64'; sha256='462584768f2e734d6be3cb5f24d817abef5191f3575091612e849e4718aac5dd' ;; \
		x86) natsArch='386'; sha256='bb991c52017b1b54568fb69420f7c6a127eb6a8f84c18dfe2e47a0ff29db42e4' ;; \
		s390x) natsArch='s390x'; sha256='84654e1d959e36c1549f47f36d7cb8f8a1395691ebf7c30ccc3ef8a0966f65fe' ;; \
		ppc64le) natsArch='ppc64le'; sha256='0c390ad5de7828c727428731c4ccc8f67ae7db7a4b68b7d3c07db0c8e595ecd6' ;; \
		*) echo >&2 "error: $apkArch is not supported!"; exit 1 ;; \
	esac; \
	\
	wget -O nats-server.tar.gz "https://github.com/nats-io/nats-server/releases/download/v${NATS_SERVER}/nats-server-v${NATS_SERVER}-linux-${natsArch}.tar.gz"; \
	echo "${sha256} *nats-server.tar.gz" | sha256sum -c -; \
	\
	apk add --no-cache ca-certificates tzdata bash curl; \
	\
	tar -xf nats-server.tar.gz; \
	rm nats-server.tar.gz; \
	mv "nats-server-v${NATS_SERVER}-linux-${natsArch}/nats-server" /usr/local/bin; \
	rm -rf "nats-server-v${NATS_SERVER}-linux-${natsArch}";

# This should download the wadm binary and move it to /usr/local/bin
# But it errors `wadm not found`
# So I am just using the wadm image
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    curl -fLO  "https://github.com/wasmCloud/wadm/releases/download/v${WADM_VERSION}/wadm-v${WADM_VERSION}-linux-${apkArch}.tar.gz"; \
    tar -xvf wadm-v${WADM_VERSION}-linux-${apkArch}.tar.gz; \
    chmod +x "wadm-v${WADM_VERSION}-linux-${apkArch}/wadm";


# DOwload wasmcloud binary and move it to /usr/local/bin
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    curl -fLO "https://github.com/wasmCloud/wasmCloud/releases/download/v${WASMCLOUD_VERSION}/wasmcloud-aarch64-unknown-linux-musl"; \
    chmod +x "wasmcloud-aarch64-unknown-linux-musl"; \
    mv "wasmcloud-aarch64-unknown-linux-musl" /usr/local/bin/wasmcloud;



FROM ghcr.io/wasmcloud/wadm:latest AS runner

COPY nats.conf /app/nats.conf
COPY --chmod="+x" startup.sh /app/startup.sh
COPY --from=build /usr/local/bin/nats-server /usr/local/bin/nats-server
COPY --from=build /usr/local/bin/wasmcloud /usr/local/bin/wasmcloud

WORKDIR /app

USER root

EXPOSE 4222 8080 6222 4001

ENTRYPOINT ["./startup.sh"]