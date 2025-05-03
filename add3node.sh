#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "사용법: $0 <노드번호> [git_tag]"
  echo ""
  echo "사용 예시:"
  echo "  ./add3node.sh 0          # 기본 버전(3.32.0-mainnet)으로 3node0 생성"
  echo "  ./add3node.sh 0 3.39.0-mainnet  # 최신 버전으로 3node0 생성"
  echo "  ./add3node.sh 1 3.32.0-mainnet  # 안정 버전으로 3node1 생성"
  echo ""
  echo "버전 정보:"
  echo "  3.39.0-mainnet: 최신 메인넷 버전"
  echo "  3.32.0-mainnet: 안정 메인넷 버전"
  echo ""
  exit 1
fi

NODE_NUM=$1
GIT_TAG=${2:-3.32.0-mainnet}

echo "사용할 버전: $GIT_TAG"

SERVER_ID=$(grep SERVER_ID .env 2>/dev/null | cut -d= -f2 || echo "dock01")

# 노드 데이터 디렉토리 생성
mkdir -p ./3node${NODE_NUM}/data

# 버전별 체인스펙 디렉토리 생성
mkdir -p ./data/${GIT_TAG}/chainspecs

# chainspec 파일 다운로드 (없는 경우에만)
if [ ! -f "./data/${GIT_TAG}/chainspecs/mainnetSpecRaw.json" ]; then
  echo "${GIT_TAG} 버전의 체인스펙 파일 다운로드 중..."
  
  # 임시 디렉토리 생성
  TEMP_DIR="/tmp/creditcoin3_${GIT_TAG}_$$"
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR"
  
  # Git 저장소 클론 및 체인스펙 파일 복사
  git clone https://github.com/gluwa/creditcoin3.git
  cd creditcoin3
  git checkout ${GIT_TAG}
  git lfs pull
  
  if [ -f "chainspecs/mainnetSpecRaw.json" ]; then
    cp "chainspecs/mainnetSpecRaw.json" "/home/d01/creditcoin-docker/data/${GIT_TAG}/chainspecs/"
    echo "체인스펙 파일 다운로드 완료"
  else
    echo "오류: 체인스펙 파일을 찾을 수 없습니다"
    exit 1
  fi
  
  # 원래 디렉토리로 복귀 및 정리
  cd /home/d01/creditcoin-docker
  rm -rf "$TEMP_DIR"
else
  echo "체인스펙 파일이 이미 존재합니다"
fi

# .env 파일에 새 노드 설정 추가
P2P_PORT=$((30340 + $NODE_NUM))
RPC_PORT=$((33980 + $NODE_NUM))

# .env 파일 업데이트 또는 생성
if [ ! -f ".env" ]; then
  echo "SERVER_ID=${SERVER_ID}" > .env
  echo "GIT_TAG=${GIT_TAG}" >> .env
fi

# 노드 설정 추가
grep -q "P2P_PORT_3NODE${NODE_NUM}" .env || echo "P2P_PORT_3NODE${NODE_NUM}=${P2P_PORT}" >> .env
grep -q "RPC_PORT_3NODE${NODE_NUM}" .env || echo "RPC_PORT_3NODE${NODE_NUM}=${RPC_PORT}" >> .env

# docker-compose.yml 파일 처음 생성 (파일이 없는 경우)
if [ ! -f "docker-compose.yml" ]; then
  cat > docker-compose.yml << EOSVC
x-node-defaults: &node-defaults
  build: .
  restart: unless-stopped

services:
  # 서비스들이 여기에 추가됩니다

networks:
  creditnet:
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
EOSVC
fi

# Dockerfile 생성 (파일이 없는 경우)
if [ ! -f "Dockerfile" ]; then
  cat > Dockerfile << EODF
FROM ubuntu:24.04

# 필요한 패키지 설치
RUN apt update && apt install -y \\
    cmake \\
    pkg-config \\
    libssl-dev \\
    git \\
    git-lfs \\
    build-essential \\
    clang \\
    libclang-dev \\
    curl \\
    protobuf-compiler

# 러스트 설치
RUN curl https://sh.rustup.rs/ -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:\${PATH}"

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
RUN git checkout \${GIT_TAG}
RUN git lfs pull
RUN cargo build --release

# 시작 스크립트 생성
RUN echo '#!/bin/bash \\n\\
PUBLIC_IP=\$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || curl -s https://icanhazip.com) \\n\\
echo "Using IP address: \$PUBLIC_IP" \\n\\
/root/creditcoin3/target/release/creditcoin3-node \\
  --validator \\
  --name \${NODE_NAME} \\
  --prometheus-external \\
  --telemetry-url "wss://telemetry.creditcoin.network/submit/ 0" \\
  --no-telemetry \\
  --bootnodes "/dns4/cc3-bootnode.creditcoin.network/tcp/30333/p2p/12D3KooWLGyvbdQ3wTGjRAEueFsDnstZnV8fN3iyPTmHeyswSPGy" \\
  --public-addr "/dns4/\$PUBLIC_IP/tcp/\${P2P_PORT}" \\
  --chain /root/data/chainspecs/mainnetSpecRaw.json \\
  --base-path /root/data \\
  --port \${P2P_PORT} \\
  --rpc-port \${RPC_PORT} \\
  \$([ "\${PRUNING}" != "0" ] && echo "--pruning=\${PRUNING}" || echo "")' > /start.sh

RUN chmod +x /start.sh

# 데이터 디렉토리 생성
RUN mkdir -p /root/data/chainspecs
VOLUME ["/root/data"]

# 시작 명령어
ENTRYPOINT ["/start.sh"]
EODF
fi

# docker-compose.yml 파일에 새 노드 추가
if grep -q "3node${NODE_NUM}:" docker-compose.yml; then
  echo "3node${NODE_NUM}은 이미 docker-compose.yml에 존재합니다."
else
  # docker-compose.yml에 노드 추가
  if grep -q "# 서비스들이 여기에 추가됩니다" docker-compose.yml; then
    sed -i "s/# 서비스들이 여기에 추가됩니다/3node${NODE_NUM}:\n    <<: *node-defaults\n    container_name: \${SERVER_ID:-dock}-3node${NODE_NUM}\n    volumes:\n      - ./data\/${GIT_TAG}\/chainspecs:\/root\/data\/chainspecs\n      - ./3node${NODE_NUM}\/data:\/root\/data\n    ports:\n      - \"\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}:\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}\"\n      - \"\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}:\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}\"\n    environment:\n      - SERVER_ID=\${SERVER_ID:-dock}\n      - NODE_ID=${NODE_NUM}\n      - NODE_NAME=\${SERVER_ID:-dock}-3Node${NODE_NUM}\n      - P2P_PORT=\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}\n      - RPC_PORT=\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}\n      - PRUNING=0\n      - GIT_TAG=${GIT_TAG}\n    networks:\n      creditnet:\n        ipv4_address: 172.20.0.$((2 + $NODE_NUM))/" docker-compose.yml
  else
    # 이미 다른 노드가 있는 경우
    sed -i "/services:/a \ \ 3node${NODE_NUM}:\n    <<: *node-defaults\n    container_name: \${SERVER_ID:-dock}-3node${NODE_NUM}\n    volumes:\n      - ./data\/${GIT_TAG}\/chainspecs:\/root\/data\/chainspecs\n      - ./3node${NODE_NUM}\/data:\/root\/data\n    ports:\n      - \"\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}:\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}\"\n      - \"\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}:\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}\"\n    environment:\n      - SERVER_ID=\${SERVER_ID:-dock}\n      - NODE_ID=${NODE_NUM}\n      - NODE_NAME=\${SERVER_ID:-dock}-3Node${NODE_NUM}\n      - P2P_PORT=\${P2P_PORT_3NODE${NODE_NUM}:-${P2P_PORT}}\n      - RPC_PORT=\${RPC_PORT_3NODE${NODE_NUM}:-${RPC_PORT}}\n      - PRUNING=0\n      - GIT_TAG=${GIT_TAG}\n    networks:\n      creditnet:\n        ipv4_address: 172.20.0.$((2 + $NODE_NUM))" docker-compose.yml
  fi
fi

echo "----------------------------------------------------"
echo "버전 ${GIT_TAG}으로 3node${NODE_NUM}이 설정되었습니다."
echo "----------------------------------------------------"
echo ""
echo "사용 가능한 버전:"
echo "  - 3.39.0-mainnet (최신 버전) - 보다 많은 기능, 업데이트 포함"
echo "  - 3.32.0-mainnet (안정 버전) - 안정성 중시, 메모리 사용 최적화"
echo ""
echo "노드를 시작하려면 다음 명령어를 실행하세요:"
echo "docker compose build --no-cache 3node${NODE_NUM} && docker compose up -d 3node${NODE_NUM}"
echo ""
echo "실행 중인 노드 확인: docker ps"
echo "로그 확인: docker logs -f dock-3node${NODE_NUM}"
echo "----------------------------------------------------"
