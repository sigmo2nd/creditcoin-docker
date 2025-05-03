#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <node_number> [node_name]"
  echo "Example: $0 0 Taco"
  exit 1
fi

NODE_NUM=$1
NODE_NAME=${2:-Taco$NODE_NUM}
SERVER_ID=$(grep SERVER_ID .env 2>/dev/null | cut -d= -f2 || echo "d01")

# 도커파일이 없으면 생성 (최초 한 번만)
if [ ! -f "Dockerfile.creditcoin" ]; then
  cat > Dockerfile.creditcoin << 'EOD'
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

# 소스코드 클론 및 빌드 (creditcoin 2.0)
WORKDIR /root
RUN git clone https://github.com/gluwa/creditcoin
WORKDIR /root/creditcoin
RUN git fetch --all --tags
RUN git checkout mainnet
RUN cargo build --release

# 시작 스크립트 생성
RUN echo '#!/bin/bash \n\
# 외부 IP 가져오기 (여러 방법으로 시도) \n\
PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || curl -s https://icanhazip.com) \n\
echo "Using IP address: $PUBLIC_IP" \n\
/root/creditcoin/target/release/creditcoin-node \
  --validator \
  --name ${NODE_NAME} \
  --prometheus-external \
  --telemetry-url "wss://telemetry.creditcoin.network/submit/ 0" \
  --no-telemetry \
  --bootnodes "/dns4/bootnode.creditcoin.network/tcp/30333/p2p/12D3KooWAEgDL126EUFxFfdQKiUhmx3BJPdszQHu9PsYsLCuavhb" "/dns4/bootnode2.creditcoin.network/tcp/30333/p2p/12D3KooWSQye3uN3bZQRRC4oZbpiAZXkP2o5UZh6S8pqyh24bF3k" "/dns4/bootnode3.creditcoin.network/tcp/30333/p2p/12D3KooWFrsEZ2aSfiigAxs6ir2kU6en4BewotyCXPhrJ7T1AzjN" \
  --public-addr "/dns4/$PUBLIC_IP/tcp/${P2P_PORT}" \
  --chain mainnet \
  --base-path /root/data \
  --port ${P2P_PORT} \
  --ws-port ${WS_PORT}' > /start.sh

RUN chmod +x /start.sh

# 데이터 디렉토리 생성
RUN mkdir -p /root/data
VOLUME ["/root/data"]

# 시작 명령어
ENTRYPOINT ["/start.sh"]
EOD
fi

# 새 노드를 위한 디렉토리 생성
mkdir -p ./node${NODE_NUM}/data

# 포트 설정
BASE_P2P_PORT=30333
BASE_WS_PORT=33970
P2P_PORT=$((BASE_P2P_PORT + $NODE_NUM))
WS_PORT=$((BASE_WS_PORT + $NODE_NUM))

# 노드 설정 추가
if ! grep -q "P2P_PORT_NODE${NODE_NUM}" .env 2>/dev/null; then
  echo "" >> .env
  echo "# 노드 ${NODE_NUM} 설정 (creditcoin 2.0)" >> .env
  echo "P2P_PORT_NODE${NODE_NUM}=${P2P_PORT}" >> .env
  echo "WS_PORT_NODE${NODE_NUM}=${WS_PORT}" >> .env
  echo "NODE_NAME_${NODE_NUM}=${NODE_NAME}" >> .env
fi

# docker-compose.yml 파일에 새 노드 추가
if grep -q "node${NODE_NUM}:" docker-compose.yml; then
  echo "node${NODE_NUM}은 이미 docker-compose.yml에 존재합니다."
else
  cat >> docker-compose.yml << EOSVC

  # Creditcoin 2.0 Node${NODE_NUM}
  node${NODE_NUM}:
    build:
      context: .
      dockerfile: Dockerfile.creditcoin
    container_name: \${SERVER_ID:-d01}-node${NODE_NUM}
    volumes:
      - ./node${NODE_NUM}/data:/root/data
    ports:
      - "\${P2P_PORT_NODE${NODE_NUM}:-${P2P_PORT}}:\${P2P_PORT_NODE${NODE_NUM}:-${P2P_PORT}}"
      - "\${WS_PORT_NODE${NODE_NUM}:-${WS_PORT}}:\${WS_PORT_NODE${NODE_NUM}:-${WS_PORT}}"
    environment:
      - SERVER_ID=\${SERVER_ID:-d01}
      - NODE_NAME=\${NODE_NAME_${NODE_NUM}:-${NODE_NAME}}
      - P2P_PORT=\${P2P_PORT_NODE${NODE_NUM}:-${P2P_PORT}}
      - WS_PORT=\${WS_PORT_NODE${NODE_NUM}:-${WS_PORT}}
    restart: unless-stopped
    networks:
      creditnet:
        ipv4_address: 172.20.0.$((10 + $NODE_NUM))
EOSVC
fi

echo "node${NODE_NUM}이 '${NODE_NAME}' 이름으로 설정되었습니다."
echo "다음 명령어로 노드를 시작하세요:"
echo "docker compose build node${NODE_NUM} && docker compose up -d node${NODE_NUM}"
