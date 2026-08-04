FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace/Learning-to-Draft

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

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    TOKENIZERS_PARALLELISM=false \
    HF_HOME=/workspace/huggingface \
    TRANSFORMERS_CACHE=/workspace/huggingface \
    PYTHONPATH=/workspace/Learning-to-Draft

COPY requirements.txt /tmp/requirements.txt

# 基础镜像已经包含 PyTorch，避免重复安装 torch
# 同时修正老版本 sentencepiece 在新环境中的安装问题
RUN grep -v '^torch==' /tmp/requirements.txt \
      | sed 's/sentencepiece==0\.1\.9/sentencepiece==0.1.99/' \
      > /tmp/requirements-docker.txt \
    && python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install -r /tmp/requirements-docker.txt

COPY . .

RUN chmod +x train_depth.sh train_size.sh eval.sh 2>/dev/null || true \
    && mkdir -p \
       /workspace/huggingface \
       /workspace/data \
       /workspace/checkpoints \
       /workspace/outputs

CMD ["/bin/bash"]
