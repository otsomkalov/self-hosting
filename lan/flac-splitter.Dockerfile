FROM debian:bookworm-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANGUAGE=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        shntool \
        cuetools \
        flac \
        inotify-tools \
        file \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

    RUN ln -s /usr/bin/cuetag.sh /usr/local/bin/cuetag

WORKDIR /app

COPY flac-splitter.sh .

RUN chmod +x flac-splitter.sh

CMD ["./flac-splitter.sh"]