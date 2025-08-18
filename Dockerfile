FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates python3 bash tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
# start.sh: chạy sshx nền + mở HTTP health server
RUN echo '#!/usr/bin/env bash\n\
set -e\n\
echo "Starting sshx (background)..." \n\
( curl -sSf https://sshx.io/get | sh -s run ) &\n\
echo "Starting HTTP health server on $PORT..." \n\
export PORT=${PORT:-8080}\n\
python3 -m http.server ${PORT} --bind 0.0.0.0\n' > /app/start.sh && \
    chmod +x /app/start.sh

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/app/start.sh"]
