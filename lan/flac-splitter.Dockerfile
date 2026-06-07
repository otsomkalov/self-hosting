FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        shntool \
        flac \
        inotify-tools \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY flac-splitter.sh .

RUN chmod +x flac-splitter.sh

CMD ["./flac-splitter.sh"]