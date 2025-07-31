FROM ubuntu:latest

# 默认环境变量
ENV SSH_DOMAIN=ssh.me
ENV UUID=c526df83-edbb-4745-9989-6e56c9409188
ENV PASSWD=123456

# 更新包列表，安装必要软件
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates openssh-server bash curl unzip supervisor vim nginx gettext-base && \
    rm -rf /var/lib/apt/lists/*

# 设置 root 密码
RUN echo "root:$PASSWD" | chpasswd

# 生成 SSH host key 和创建运行目录
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# 修改 sshd 配置允许 root 登录和密码登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 创建 supervisord 需要的目录
RUN mkdir -p /var/run/supervisor /var/log && chmod 755 /var/run/supervisor /var/log

# 安装 Xray & sing-box & Openlist
RUN XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/v\1/') && \
    curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip
RUN SING_BOX_VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/v\1/') && \
    curl -L -o /tmp/sing-box.tar.gz https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION#v}-linux-amd64.tar.gz && \
    tar -xvzf /tmp/sing-box.tar.gz -C /usr/local/bin/ && \
    cp /usr/local/bin/sing-box-${SING_BOX_VERSION#v}-linux-amd64/* /usr/local/bin/ && \
    chmod +x /usr/local/bin/sing-box && \
    rm -rf /usr/local/bin/sing-box-${SING_BOX_VERSION#v}-linux-amd64/ /tmp/sing-box.tar.gz
RUN OPENLIST_VERSION=$(curl -s https://api.github.com/repos/OpenListTeam/OpenList/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/v\1/') && \
    curl -L -o /tmp/openlist.tar.gz https://github.com/OpenListTeam/OpenList/releases/download/${OPENLIST_VERSION}/openlist-linux-amd64.tar.gz && \
    tar -xvzf /tmp/openlist.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/openlist && \
    rm /tmp/openlist.tar.gz

# 复制配置模板和启动脚本
COPY xray.json /etc/xray/config.template
COPY sing-box.json /etc/sing-box/config.template
RUN mkdir -p /shell
COPY start.sh /shell/start.sh
RUN chmod +x /shell/start.sh

# 复制 supervisord 配置
COPY supervisord.conf /etc/supervisord.conf

# 暴露端口
EXPOSE 22 443 8443 2053

# 容器启动入口
CMD ["/shell/start.sh"]
