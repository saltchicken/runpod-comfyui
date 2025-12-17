# Updated Base Image: PyTorch 2.4.0 / Python 3.11 / CUDA 12.4.1
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone ComfyUI
WORKDIR /
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# 3. Install Python dependencies
# REMOVED the numpy<2.0 pin. Pip will now naturally install Numpy 2.x
WORKDIR /ComfyUI
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# 4. Install ComfyUI Manager
WORKDIR /ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# 5. Install necessary custom nodes
RUN git clone https://github.com/city96/ComfyUI-GGUF.git && \
    pip install -r ComfyUI-GGUF/requirements.txt

RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    pip install -r ComfyUI-VideoHelperSuite/requirements.txt

RUN git clone https://github.com/DoctorDiffusion/ComfyUI-MediaMixer.git && \
    pip install -r ComfyUI-MediaMixer/requirements.txt

RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git

# 6. Setup the start script
WORKDIR /
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
