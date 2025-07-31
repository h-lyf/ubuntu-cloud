#!/bin/sh

# 传入 ROOT_PASS 环境变量，则修改 root 密码
if [ -n "$PASSWD" ]; then
    echo "root:$PASSWD" | chpasswd
fi

# 生成最终配置文件
mkdir -p /etc/data
if [ ! -f /root/data/xray/config.json ]; then
  envsubst < /etc/xray/config.template > /root/data/xray/config.json
fi
if [ ! -f /root/data/sing-box/config.json ]; then
  envsubst < /etc/sing-box/config.template > /root/data/sing-box/config.json
fi

# 启动 supervisord 管理服务
if [ ! -f /root/data/supervisord.conf ]; then
  cp /etc/supervisord.conf /root/data/supervisord.conf
  exec /usr/bin/supervisord -c /root/data/supervisord.conf
fi

