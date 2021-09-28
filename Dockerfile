ARG UBUNTU_VERSION=20.04
from ubuntu:${UBUNTU_VERSION}

# 设置ubuntu国内源，安装必要的软件包
ADD sources.list /etc/apt/sources.list
RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        git \
        gcc \
        g++ \
        make

# miniconda
WORKDIR /root
ARG MINICONDA_VERSION=py38_4.8.2
ADD .condarc /root/.condarc
RUN wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p $HOME/miniconda && \
    rm miniconda.sh && \
    ./miniconda/bin/conda init bash

# zsh
ENV GIT_SSL_NO_VERIFY=1

RUN apt-get install -y --no-install-recommends zsh autojump && \
    sh -c $(wget --no-check-certificate https://mirror.ghproxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | sed "s/https:\/\/github.com/https:\/\/mirror.ghproxy.com\/https:\/\/github.com/g") "" --unattended && \
    echo ". /usr/share/autojump/autojump.sh" >> .zshrc && \
    git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> .zshrc \
    sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g" && \
    ./miniconda/bin/conda init zsh

# lurnarvim adapt from https://github.com/LunarVim/LunarVim/blob/rolling/utils/docker/Dockerfile
ARG NEOVIM_RELEASE=v0.5.0
ARG LVBRANCH=master

ENV DEBIAN_FRONTEND=noninteractive

# Install apt dependencies
RUN apt -y install sudo curl build-essential git fzf python3-dev python3-pip cargo && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt update && \
    apt -y install nodejs && \
    curl -L -o /tmp/nvim.appimage https://github.com/neovim/neovim/releases/download/${NEOVIM_RELEASE}/nvim.appimage && \
    chmod u+x /tmp/nvim.appimage && \
    /tmp/nvim.appimage --appimage-extract && \
    mv squashfs-root /usr/local/neovim && \
    ln -s /usr/local/neovim/usr/bin/nvim /usr/bin/nvim

ENV PATH="/root/.local/bin:/root/.cargo/bin:/root/.npm-global/bin${PATH}"

RUN LVBRANCH=${LVBRANCH} wget --no-check-certificate https://raw.githubusercontent.com/lunarvim/lunarvim/rolling/utils/installer/install.sh -O - | bash -s -- -y