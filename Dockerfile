FROM ubuntu:24.04

# 필요한 패키지 설치
RUN apt update && apt install -y \
    cmake \
    pkg-config \
    libssl-dev \
    git \
    git-lfs \
    build-essential \
    clang \
    libclang-dev \
    curl \
    protobuf-compiler

# 러스트 설치
RUN curl https://sh.rustup.rs/ -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 러스트 업데이트 (nightly)
RUN rustup update nightly
RUN rustup default nightly

# Git LFS 설치 및 초기화
RUN git lfs install

# 소스코드 클론 및 빌드
WORKDIR /root
RUN git clone https://github.com/gluwa/creditcoin3
WORKDIR /root/creditcoin3
RUN git fetch --all --tags
RUN git checkout 3.32.0-mainnet
RUN cargo build --release

# 시작 스크립트 생성
RUN echo '#!/bin/bash \n\
PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || curl -s https://icanhazip.com) \n\
echo "Using IP address: $PUBLIC_IP" \n\
/root/creditcoin3/target/release/creditcoin3-node \
  --validator \
  --name ${NODE_NAME} \
  --prometheus-external \
  --telemetry-url "wss://telemetry.creditcoin.network/submit/ 0" \
  --no-telemetry \
  --bootnodes "/dns4/cc3-bootnode.creditcoin.network/tcp/30333/p2p/12D3KooWLGyvbdQ3wTGjRAEueFsDnstZnV8fN3iyPTmHeyswSPGy" \
  --public-addr "/dns4/$PUBLIC_IP/tcp/${P2P_PORT}" \
  --chain /root/data/chainspecs/mainnetSpecRaw.json \
  --base-path /root/data \
  --port ${P2P_PORT} \
  --rpc-port ${RPC_PORT} \
  $([ "${PRUNING}" != "0" ] && echo "--pruning=${PRUNING}" || echo "")' > /start.sh

RUN chmod +x /start.sh

# 데이터 디렉토리 생성
RUN mkdir -p /root/data/chainspecs
VOLUME ["/root/data"]

# 시작 명령어
ENTRYPOINT ["/start.sh"]
