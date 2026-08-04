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

# 基础镜像中已经安装了 torch，因此从 requirements 中排除 torch。
# protobuf 3.19.0 较老，改为兼容性更好的 3.20.3。
RUN sed \
      -e '/^torch==/d' \
      -e 's/^protobuf==3\.19\.0$/protobuf==3.20.3/' \
      /tmp/requirements.txt \
      > /tmp/requirements-docker.txt \
    && echo "===== Docker requirements =====" \
    && cat /tmp/requirements-docker.txt \
    && echo "===============================" \
    && python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install \
         --prefer-binary \
         --no-cache-dir \
         -r /tmp/requirements-docker.txt

COPY . .

RUN chmod +x train_depth.sh train_size.sh eval.sh 2>/dev/null || true \
    && mkdir -p \
       /workspace/huggingface \
       /workspace/data \
       /workspace/checkpoints \
       /workspace/outputs

CMD ["/bin/bash"]
