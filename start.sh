#!/bin/sh

# 传入 ROOT_PASS 环境变量，则修改 root 密码
if [ -n "$PASSWD" ]; then
    echo "root:$PASSWD" | chpasswd
fi

# 生成最终配置文件
envsubst < /etc/xray/config.template > /etc/xray/config.json

# 启动 supervisord 管理服务
exec /usr/bin/supervisord -c /etc/supervisord.conf
