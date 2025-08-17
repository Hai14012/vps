# Dùng Alpine nhỏ gọn
FROM alpine:3.19

# Cài curl, bash và OpenSSH client (sshx cần ssh client để hoạt động)
RUN apk add --no-cache curl bash openssh-client

# Chạy lệnh sshx khi container start
CMD curl -sSf https://sshx.io/get | sh -s run
