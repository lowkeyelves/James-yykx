#!/bin/bash

# 调试：打印环境变量
echo "环境变量："
env

# 调试：检查挂载盘和文件
ls -l /data /data/certs /data/config || echo "无法列出挂载盘内容"

# 确保挂载盘存在
if [ ! -d "/data" ]; then
    echo "错误：未找到 /data 挂载点！"
    exit 1
fi

# 确保 Caddy 数据目录可写（用于存储 Let's Encrypt 证书）
mkdir -p /data/caddy
chown -R 1000:1000 /data/caddy

# 设置 Caddy 数据目录环境变量
export CADDY_DATA_DIR=/data/caddy

# 默认 Caddyfile 路径
CADDYFILE="/etc/caddy/Caddyfile"

# 如果挂载盘中存在 Caddyfile，则使用它；否则根据环境变量生成
if [ -f "/data/config/Caddyfile" ]; then
    echo "使用 /data/config/Caddyfile 中的现有 Caddyfile"
    cp /data/config/Caddyfile $CADDYFILE
else
    echo "根据模板和环境变量生成 Caddyfile"
    envsubst < /etc/caddy/Caddyfile.template > $CADDYFILE
fi

# 调试：打印生成的 Caddyfile
echo "生成的 Caddyfile 内容："
cat $CADDYFILE

# 启动 Caddy
exec /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
