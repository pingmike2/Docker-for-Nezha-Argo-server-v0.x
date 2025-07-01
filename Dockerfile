# 使用 Debian slim 基础镜像（更好的兼容性）
FROM debian:bookworm-slim

# 设置工作目录
WORKDIR /dashboard

# 设置环境变量避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的软件包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # 基础工具
        bash \
        curl \
        wget \
        unzip \
        tar \
        ca-certificates \
        # 系统工具
        openssh-server \
        iproute2 \
        tzdata \
        # 进程管理
        supervisor \
        # 定时任务
        cron \
        # 数据库
        sqlite3 \
        # 版本控制
        git \
        # SSL 证书生成
        openssl \
        # 系统监控
        procps \
        # 文本处理工具
        sed \
        gawk \
        grep \
        # 编码工具
        coreutils && \
    # 配置 git（减少内存使用）
    git config --global core.bigFileThreshold 1k && \
    git config --global core.compression 0 && \
    git config --global advice.detachedHead false && \
    git config --global pack.threads 1 && \
    git config --global pack.windowMemory 50m && \
    # 创建必要的目录
    mkdir -p /var/log/supervisor \
             /var/run/sshd \
             /etc/supervisor/conf.d \
             /dashboard/data && \
    # 配置 SSH
    mkdir -p /var/run/sshd && \
    # 清理包管理器缓存
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建入口脚本
RUN printf '#!/usr/bin/env bash\n\nbash <(wget -qO- https://raw.githubusercontent.com/pingmike2/Docker-for-Nezha-Argo-server-v0.x/main/init.sh)\n' > entrypoint.sh && \
    chmod +x entrypoint.sh

# 暴露端口
EXPOSE 80 5555 8080

ENTRYPOINT ["/dashboard/entrypoint.sh"]
