FROM python:3.12.8-slim

# Gói tiện ích tối thiểu
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates bash git tzdata tini && \
    rm -rf /var/lib/apt/lists/*

# Cài neofetch (cách ổn định cho slim): tải script và đặt vào PATH
RUN curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch \
      -o /usr/local/bin/neofetch && \
    chmod +x /usr/local/bin/neofetch

WORKDIR /app

# start.sh: sshx tự reconnect + HTTP health + in neofetch lúc khởi động
RUN echo '#!/usr/bin/env bash
set -euo pipefail

echo "[boot] Python:" $(python --version)
echo "[boot] Neofetch:" $(command -v neofetch || echo "missing")
neofetch || true

# Health & favicon để khỏi 404
mkdir -p health
echo OK > health/index.html
: > favicon.ico

# HTTP server để Render thấy cổng mở
export PORT="${PORT:-8080}"
python -u -m http.server "$PORT" --bind 0.0.0.0 &
echo "[http] listening on 0.0.0.0:${PORT}"

# Vòng lặp giữ sshx luôn sống
while true; do
  echo "[sshx] starting..."
  if curl -fsSL https://sshx.io/get | sh -s run; then
    echo "[sshx] exited normally"
  else
    echo "[sshx] disconnected, retrying in 5s..."
    sleep 5
  fi
done
' > /app/start.sh && chmod +x /app/start.sh

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/app/start.sh"]
