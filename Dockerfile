FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace/Learning-to-Draft

# 编译 sentencepiece、tokenizer 等包时可能需要
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    build-essential \
    cmake \
    ninja-build \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 避免在容器中生成大量缓存文件
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    TOKENIZERS_PARALLELISM=false \
    HF_HOME=/workspace/huggingface \
    TRANSFORMERS_CACHE=/workspace/huggingface \
    WANDB_DIR=/workspace/outputs/wandb

COPY requirements.txt /tmp/requirements.txt

# 基础镜像已有 torch 2.6.0，避免再次安装 torch
RUN grep -v '^torch==' /tmp/requirements.txt > /tmp/requirements-docker.txt \
    && sed -i 's/sentencepiece==0\.1\.9/sentencepiece==0.1.99/' \
       /tmp/requirements-docker.txt \
    && python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install -r /tmp/requirements-docker.txt

COPY . .

RUN chmod +x train_depth.sh train_size.sh eval.sh \
    && mkdir -p \
       /workspace/huggingface \
       /workspace/data \
       /workspace/checkpoints \
       /workspace/outputs

# 确认项目模块能从任意脚本中导入
ENV PYTHONPATH=/workspace/Learning-to-Draft:${PYTHONPATH}

# 默认进入交互式终端，不自动启动训练
CMD ["/bin/bash"]
