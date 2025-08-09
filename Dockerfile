# 阶段 1：构建 Caddy 和 NaiveProxy
FROM golang:1.19 AS build

WORKDIR /go

# 安装 xcaddy 并构建 Caddy，包含 NaiveProxy 插件
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && /go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

# 阶段 2：创建最终镜像
FROM debian:bullseye-slim AS final

# 安装必要依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制 Caddy 二进制文件
COPY --from=build /go/caddy /usr/bin/caddy

# 创建挂载点和配置文件目录
RUN mkdir -p /etc/caddy /data/certs /data/config

# 复制 Caddyfile 模板和入口脚本
COPY Caddyfile.template /etc/caddy/Caddyfile.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 设置工作目录
WORKDIR /etc/caddy

# 暴露端口
EXPOSE 80 443

# 设置挂载点
VOLUME ["/data"]

# 使用入口脚本启动
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile"]
