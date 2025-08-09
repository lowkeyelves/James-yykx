# 使用轻量化的 Debian 基础镜像
FROM debian:bullseye-slim

# 安装必要依赖，包括 gettext-base 以提供 envsubst
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下载并解压 v2.7.5-caddy2-naive2
RUN cd /tmp && \
    curl -fsSL --retry 3 --retry-delay 5 -o caddy.tar.xz "https://github.com/klzgrad/forwardproxy/releases/download/v2.7.5-caddy2-naive2/caddy-forwardproxy-naive.tar.xz" \
    || { echo "错误：无法下载 v2.7.5-caddy2-naive2"; exit 1; } && \
    tar -xJf caddy.tar.xz -C /tmp/ \
    || { echo "错误：无法解压 v2.7.5-caddy2-naive2"; exit 1; } && \
    mv /tmp/caddy-forwardproxy-naive/caddy /usr/bin/caddy \
    || { echo "错误：无法移动 caddy 到 /usr/bin/"; exit 1; } && \
    rm -rf /tmp/caddy.tar.xz /tmp/caddy-forwardproxy-naive

# 下载并解压 caddy2-naive-20221007，替换之前的 caddy
RUN cd /tmp && \
    curl -fsSL --retry 3 --retry-delay 5 -o caddy.tar.xz "https://github.com/klzgrad/forwardproxy/releases/download/caddy2-naive-20221007/caddy-forwardproxy-naive.tar.xz" \
    || { echo "错误：无法下载 caddy2-naive-20221007"; exit 1; } && \
    tar -xJf caddy.tar.xz -C /tmp/ \
    || { echo "错误：无法解压 caddy2-naive-20221007"; exit 1; } && \
    mv /tmp/caddy-forwardproxy-naive/caddy /usr/bin/caddy \
    || { echo "错误：无法移动 caddy 到 /usr/bin/"; exit 1; } && \
    chmod +x /usr/bin/caddy && \
    rm -rf /tmp/caddy.tar.xz /tmp/caddy-forwardproxy-naive

# 创建挂载点和配置文件目录
RUN mkdir -p /etc/caddy /data/certs /data/config /data/caddy

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
CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
