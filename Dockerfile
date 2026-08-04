FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace/Learning-to-Draft

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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
    PYTHONPATH=/workspace/Learning-to-Draft

COPY requirements.txt /tmp/requirements.txt

# PyTorch 已经包含在基础镜像中，不重复安装。
# protobuf 3.19.0 更新为对新 Python 环境更友好的 3.20.3。
RUN sed \
      -e '/^torch==/d' \
      -e 's/^protobuf==3\.19\.0$/protobuf==3.20.3/' \
      /tmp/requirements.txt \
      > /tmp/requirements-docker.txt \
    && echo "===== Installing the following packages =====" \
    && cat /tmp/requirements-docker.txt \
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

# 在构建阶段做基础导入测试
RUN python -c "\
import torch; \
import transformers; \
import gymnasium; \
import stable_baselines3; \
print('torch:', torch.__version__); \
print('transformers:', transformers.__version__); \
print('gymnasium:', gymnasium.__version__); \
print('stable_baselines3:', stable_baselines3.__version__)"

CMD ["/bin/bash"]
