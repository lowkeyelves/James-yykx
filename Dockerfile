# 使用轻量化的 Debian 基础镜像
FROM debian:bullseye-slim

# 安装必要依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下载并解压预编译的 Caddy（带 NaiveProxy 插件）
RUN curl -o /tmp/caddy.tar.xz -L "https://github.com/klzgrad/forwardproxy/releases/download/caddy2-naive-20221007/caddy-forwardproxy-naive.tar.xz" \
    && tar -xJf /tmp/caddy.tar.xz -C /usr/bin/ \
    && chmod +x /usr/bin/caddy \
    && rm /tmp/caddy.tar.xz

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
