FROM runpod/pytorch:1.0.3-cu1290-torch291-ubuntu2204
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone ComfyUI
WORKDIR /
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# 3. Install Python dependencies
WORKDIR /ComfyUI
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install jupyterlab

# 4. Install ComfyUI Manager
WORKDIR /ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# 5. Install necessary custom nodes
# RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
#     pip install -r ComfyUI-VideoHelperSuite/requirements.txt

RUN git clone https://github.com/saltchicken/ComfyUI-Video-Utils.git

RUN git clone https://github.com/saltchicken/ComfyUI-StopAndGo.git

RUN git clone https://github.com/Chaoses-Ib/ComfyScript.git && \
    cd ComfyScript && \
    pip install -e ".[default]" && \
    cd ..

# 6. Setup the start script
WORKDIR /
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
