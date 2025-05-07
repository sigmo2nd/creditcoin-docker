#!/bin/bash
# Creditcoin Docker 유틸리티 함수

# Creditcoin Docker 디렉토리로 이동
cdcd() { cd "$CREDITCOIN_DIR"; }

# 기본 별칭들
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dstats='docker stats'
alias updateb='source ~/.bashrc'
alias editb='nano ~/.bashrc'

# Docker 컨테이너 관리
drestart() { docker restart $1; }
dstop() { docker stop $1; }
dstart() { docker start $1; }

# Docker 로그 확인
dlog() { docker logs -f $1; }

# Creditcoin CLI 키 생성
genkey() {
  local node=$1
  if [[ $node == 3node* ]]; then
    echo "Generating keys for Creditcoin 3.0 node: $node"
    docker exec -it $node /root/creditcoin3/target/release/creditcoin3-node key generate --scheme Sr25519
  elif [[ $node == node* ]]; then
    echo "Generating keys for Creditcoin 2.0 node: $node"
    docker exec -it $node /root/creditcoin/target/release/creditcoin-node key generate --scheme Sr25519
  else
    echo "Invalid node format. Use '3nodeX' or 'nodeX'"
  fi
}

# 세션 키 교체 (컨테이너 내부에서 실행)
rotatekey() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: rotatekey <노드명>"
    echo "예시: rotatekey 3node0, rotatekey node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "Rotating session keys for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "Rotating session keys for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# 노드 건강 상태 확인
checkHealth() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: checkHealth <노드명>"
    echo "예시: checkHealth 3node0, checkHealth node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "Checking health status for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "Checking health status for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# 노드 이름 확인
checkName() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: checkName <노드명>"
    echo "예시: checkName 3node0, checkName node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "Checking node name for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "Checking node name for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# 노드 버전 확인
checkVersion() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: checkVersion <노드명>"
    echo "예시: checkVersion 3node0, checkVersion node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "Checking node version for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "Checking node version for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# 최신 블록 정보 확인
getLatestBlock() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: getLatestBlock <노드명>"
    echo "예시: getLatestBlock 3node0, getLatestBlock node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "Getting latest block info for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "Getting latest block info for $node..."
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# 단일 노드에 대한 페이아웃 실행
payout() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: payout <노드명>"
    echo "예시: payout 3node0, payout node1"
    return 1
  fi

  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "노드 $node 페이아웃 실행 중..."
    echo "RPC 포트: $port (내부)"
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "staking_payoutStakers","params":["ACCOUNT_ADDRESS", ERA_NUMBER]}'"'"' http://localhost:'$port'/' | jq
  elif [[ $node == node* ]]; then
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "노드 $node 페이아웃 실행 중..."
    echo "RPC 포트: $port (내부)"
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "staking_payoutStakers","params":["ACCOUNT_ADDRESS", ERA_NUMBER]}'"'"' http://localhost:'$port'/' | jq
  else
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
  fi
}

# Creditcoin 3.0 노드만 대상으로 페이아웃 실행 (컨테이너 내부에서 실행)
payoutAll() {
  echo "모든 Creditcoin 3.0 노드에 대해 페이아웃을 순차적으로 실행합니다..."

  # 실행 중인 3.0 노드 찾기
  local nodes3=$(docker ps --format "{{.Names}}" | grep "^3node[0-9]")

  # 노드가 없으면 종료
  if [ -z "$nodes3" ]; then
    echo "실행 중인 Creditcoin 3.0 노드가 없습니다."
    return 1
  fi

  # 3.0 노드 페이아웃
  for node in $nodes3; do
    echo "노드 $node 페이아웃 실행 중..."
    # 노드 번호 추출
    local num=$(echo $node | sed 's/3node//g')
    local port=$((33980 + $num))
    echo "RPC 포트: $port (내부)"
    # 페이아웃 명령 실행 (컨테이너 내부에서)
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "staking_payoutStakers","params":["ACCOUNT_ADDRESS", ERA_NUMBER]}'"'"' http://localhost:'$port'/' | jq
    echo ""
    sleep 2
  done

  echo "모든 Creditcoin 3.0 노드의 페이아웃이 완료되었습니다."
}

# Creditcoin 2.0 (레거시) 노드만 대상으로 페이아웃 실행 (컨테이너 내부에서 실행)
payoutAllLegacy() {
  echo "모든 Creditcoin 2.0 레거시 노드에 대해 페이아웃을 순차적으로 실행합니다..."

  # 실행 중인 2.0 노드 찾기
  local nodes2=$(docker ps --format "{{.Names}}" | grep "^node[0-9]")

  # 노드가 없으면 종료
  if [ -z "$nodes2" ]; then
    echo "실행 중인 Creditcoin 2.0 레거시 노드가 없습니다."
    return 1
  fi

  # 2.0 노드 페이아웃
  for node in $nodes2; do
    echo "노드 $node 페이아웃 실행 중..."
    # 노드 번호 추출
    local num=$(echo $node | sed 's/node//g')
    local port=$((33970 + $num))
    echo "RPC 포트: $port (내부)"
    # 페이아웃 명령 실행 (컨테이너 내부에서)
    docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "staking_payoutStakers","params":["ACCOUNT_ADDRESS", ERA_NUMBER]}'"'"' http://localhost:'$port'/' | jq
    echo ""
    sleep 2
  done

  echo "모든 Creditcoin 2.0 레거시 노드의 페이아웃이 완료되었습니다."
}

# 노드 완전히 삭제하는 함수
dkill() {
  local node=$1

  if [ -z "$node" ]; then
    echo "사용법: dkill <노드명>"
    echo "예시: dkill 3node1 또는 dkill node0"
    return 1
  fi

  # 유효성 검사
  if [[ ! $node == 3node* ]] && [[ ! $node == node* ]]; then
    echo "지원되지 않는 노드 형식입니다: $node"
    echo "형식은 '3nodeX' 또는 'nodeX'여야 합니다."
    return 1
  fi

  # 확인 메시지 표시
  echo "!!! 경고 !!!"
  echo "노드 '$node'를 완전히 삭제하려고 합니다."
  echo "이 작업은 다음을 포함합니다:"
  echo " - 노드 컨테이너 중지 및 삭제"
  echo " - 노드 데이터 디렉토리 삭제"
  echo " - 설정 파일에서 노드 항목 제거"
  echo ""
  echo "이 작업은 되돌릴 수 없습니다."
  echo ""
  read -p "정말로 '$node'를 완전히 삭제하시겠습니까? (y/N) " response

  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "작업이 취소되었습니다."
    return 0
  fi

  echo "노드 $node 완전히 삭제 중..."

  # 1. 노드 중지
  echo "1. 노드 중지 중..."
  docker stop $node

  # 2. 노드 컨테이너 삭제
  echo "2. 컨테이너 삭제 중..."
  docker rm $node

  # 3. 관련 데이터 디렉토리 삭제
  echo "3. 데이터 디렉토리 삭제 중..."
  # 노드 타입 확인
  if [[ $node == 3node* ]]; then
    rm -rf ./$node
    # .env 파일에서 해당 노드 설정 삭제
    local num=$(echo $node | sed 's/3node//g')
    sed -i "/P2P_PORT_3NODE${num}/d" .env
    sed -i "/RPC_PORT_3NODE${num}/d" .env
    sed -i "/NODE_NAME_3NODE${num}/d" .env
    sed -i "/TELEMETRY_3NODE${num}/d" .env
    sed -i "/PRUNING_3NODE${num}/d" .env

    # docker-compose.yml에서 노드 설정 삭제
    if [ -f "docker-compose.yml" ]; then
      # 백업 파일 생성
      cp docker-compose.yml docker-compose.yml.bak

      # 임시 파일 생성
      grep -v "  ${node}:" docker-compose.yml > docker-compose.yml.tmp
      # 노드 설정 블록 제거
      sed -i "/  ${node}:/,/    networks:/d" docker-compose.yml.tmp
      # 원래 파일 대체
      mv docker-compose.yml.tmp docker-compose.yml

      echo "docker-compose.yml 파일이 수정되었습니다. 백업: docker-compose.yml.bak"
    fi

  elif [[ $node == node* ]]; then
    rm -rf ./$node
    # .env 파일에서 해당 노드 설정 삭제
    local num=$(echo $node | sed 's/node//g')
    sed -i "/P2P_PORT_NODE${num}/d" .env
    sed -i "/WS_PORT_NODE${num}/d" .env
    sed -i "/NODE_NAME_${num}/d" .env
    sed -i "/TELEMETRY_ENABLED_${num}/d" .env

    # docker-compose-legacy.yml에서 노드 설정 삭제
    if [ -f "docker-compose-legacy.yml" ]; then
      # 백업 파일 생성
      cp docker-compose-legacy.yml docker-compose-legacy.yml.bak

      # 임시 파일 생성
      grep -v "  ${node}:" docker-compose-legacy.yml > docker-compose-legacy.yml.tmp
      # 노드 설정 블록 제거
      sed -i "/  ${node}:/,/    networks:/d" docker-compose-legacy.yml.tmp
      # 원래 파일 대체
      mv docker-compose-legacy.yml.tmp docker-compose-legacy.yml

      echo "docker-compose-legacy.yml 파일이 수정되었습니다. 백업: docker-compose-legacy.yml.bak"
    fi
  fi

  # 4. Docker 캐시 정리 (선택 사항)
  echo "4. Docker 캐시 정리 중..."
  docker container prune -f

  echo "노드 $node가 완전히 삭제되었습니다."
}

# 시스템 유틸리티 함수
journalcall() { journalctl -u $1.service -n 50 -f; }
alias jc="journalcall"
alias cdsys="cd /etc/systemd/system"
alias sysdr="systemctl daemon-reload"
sysre() { systemctl restart $1; }
sysen() { systemctl enable $1; }
sysst() { systemctl status $1; }
nanocall() { nano /etc/systemd/system/$1.service; }
alias nn=nanocall

# 세션키 백업 함수
backupkeys() {
  # 색상 정의
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color

  # 사용법 표시
  if [ -z "$1" ]; then
    echo -e "${YELLOW}사용법: backupkeys <노드명>${NC}"
    echo -e "예시: backupkeys 3node0"
    return 1
  fi

  NODE_NAME=$1
  BACKUP_DATE=$(date +%Y%m%d-%H%M)
  BACKUP_FILE="./${NODE_NAME}-keys-${BACKUP_DATE}.tar.gz"

  # 노드 디렉토리 확인
  if [ ! -d "./${NODE_NAME}" ]; then
    echo -e "${RED}오류: ${NODE_NAME} 디렉토리가 현재 위치에 존재하지 않습니다.${NC}"
    return 1
  fi

  # 노드 실행 중인지 확인
  if docker ps | grep -q "${NODE_NAME}"; then
    echo -e "${YELLOW}세션키를 복사하기 위해 서버를 중지합니다. (y/N)${NC}"
    read -p "" STOP_CONFIRM
    if [[ ! "$STOP_CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo -e "${RED}작업이 취소되었습니다.${NC}"
      return 1
    fi

    echo -e "${BLUE}노드 중지 중...${NC}"
    docker stop ${NODE_NAME}
    echo -e "${GREEN}노드가 중지되었습니다.${NC}"

    # 노드 중지 상태 저장 (나중에 재시작하기 위해)
    NODE_WAS_RUNNING=true
  else
    NODE_WAS_RUNNING=false
  fi

  # 노드 타입 확인
  if [[ "${NODE_NAME}" == 3node* ]]; then
    CHAIN_DIR="creditcoin3"
    echo -e "${BLUE}Creditcoin 3.0 노드로 감지되었습니다.${NC}"
  elif [[ "${NODE_NAME}" == node* ]]; then
    CHAIN_DIR="creditcoin"
    echo -e "${BLUE}Creditcoin 2.0 노드로 감지되었습니다.${NC}"
  else
    echo -e "${RED}지원되지 않는 노드 형식입니다: ${NODE_NAME}${NC}"
    echo -e "${YELLOW}노드 이름은 '3node*' 또는 'node*' 형식이어야 합니다.${NC}"

    # 노드 재시작 (필요한 경우)
    if [ "$NODE_WAS_RUNNING" = true ]; then
      echo -e "${BLUE}노드를 다시 시작합니다...${NC}"
      docker start ${NODE_NAME}
      echo -e "${GREEN}노드가 재시작되었습니다.${NC}"
    fi

    return 1
  fi

  # 세션키 디렉토리 경로
  KEYSTORE_DIR="./${NODE_NAME}/data/chains/${CHAIN_DIR}/keystore"
  NETWORK_DIR="./${NODE_NAME}/data/chains/${CHAIN_DIR}/network"

  # 키스토어 또는 네트워크 디렉토리가 존재하는지 확인
  if [ ! -d "$KEYSTORE_DIR" ] && [ ! -d "$NETWORK_DIR" ]; then
    echo -e "${RED}오류: 키스토어 및 네트워크 디렉토리가 모두 존재하지 않습니다.${NC}"

    # 노드 재시작 (필요한 경우)
    if [ "$NODE_WAS_RUNNING" = true ]; then
      echo -e "${BLUE}노드를 다시 시작합니다...${NC}"
      docker start ${NODE_NAME}
      echo -e "${GREEN}노드가 재시작되었습니다.${NC}"
    fi

    return 1
  fi

  # 임시 디렉토리 생성
  TEMP_DIR=$(mktemp -d)
  echo -e "${BLUE}임시 디렉토리 생성: ${TEMP_DIR}${NC}"

  # 백업 구조 생성
  mkdir -p "${TEMP_DIR}/keystore"
  mkdir -p "${TEMP_DIR}/network"

  # 세션키 디렉토리 복사
  if [ -d "$KEYSTORE_DIR" ]; then
    echo -e "${BLUE}키스토어 디렉토리 복사 중...${NC}"
    cp -r "${KEYSTORE_DIR}"/* "${TEMP_DIR}/keystore/" 2>/dev/null
  fi

  if [ -d "$NETWORK_DIR" ]; then
    echo -e "${BLUE}네트워크 디렉토리 복사 중...${NC}"
    cp -r "${NETWORK_DIR}"/* "${TEMP_DIR}/network/" 2>/dev/null
  fi

  # 메타데이터 파일 생성
  echo "노드명: ${NODE_NAME}" > "${TEMP_DIR}/metadata.txt"
  echo "백업날짜: $(date)" >> "${TEMP_DIR}/metadata.txt"
  echo "체인: ${CHAIN_DIR}" >> "${TEMP_DIR}/metadata.txt"

  # 아카이브 생성
  echo -e "${BLUE}세션키 아카이브 생성 중...${NC}"
  tar -czf "${BACKUP_FILE}" -C "${TEMP_DIR}" .

  # 임시 디렉토리 삭제
  rm -rf "${TEMP_DIR}"

  # 백업 파일 권한 설정
  chmod 600 "${BACKUP_FILE}"

  echo -e "${GREEN}백업이 완료되었습니다: ${BACKUP_FILE}${NC}"
  echo -e "${YELLOW}중요: 이 파일은 보안을 위해 안전한 곳에 보관하세요.${NC}"

  # 노드 재시작 (필요한 경우)
  if [ "$NODE_WAS_RUNNING" = true ]; then
    echo -e "${BLUE}노드를 다시 시작합니다...${NC}"
    docker start ${NODE_NAME}
    echo -e "${GREEN}노드가 재시작되었습니다.${NC}"
  fi
}

# 세션키 복원 함수
restorekeys() {
  # 색상 정의
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color

  # 사용법 표시
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}사용법: restorekeys <백업파일> <대상노드명>${NC}"
    echo -e "예시: restorekeys ./3node0-keys-20250507-1234.tar.gz 3node1"
    return 1
  fi

  BACKUP_FILE=$1
  TARGET_NODE=$2

  # 백업 파일 존재 확인
  if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}오류: 백업 파일 '${BACKUP_FILE}'이 존재하지 않습니다.${NC}"
    return 1
  fi

  # 대상 노드 디렉토리 존재 확인
  if [ ! -d "./${TARGET_NODE}" ]; then
    echo -e "${RED}오류: 대상 노드 디렉토리 './${TARGET_NODE}'가 존재하지 않습니다.${NC}"
    return 1
  fi

  # 노드 실행 중인지 확인
  if docker ps | grep -q "${TARGET_NODE}"; then
    echo -e "${YELLOW}세션키를 복원하기 위해 서버를 중지합니다. 이 작업은 복구할 수 없습니다. (y/N)${NC}"
    read -p "" STOP_CONFIRM
    if [[ ! "$STOP_CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo -e "${RED}작업이 취소되었습니다.${NC}"
      return 1
    fi

    echo -e "${BLUE}노드 중지 중...${NC}"
    docker stop ${TARGET_NODE}
    echo -e "${GREEN}노드가 중지되었습니다.${NC}"

    # 노드 중지 상태 저장 (나중에 재시작하기 위해)
    NODE_WAS_RUNNING=true
  else
    NODE_WAS_RUNNING=false
  fi

  # 임시 디렉토리 생성
  TEMP_DIR=$(mktemp -d)
  echo -e "${BLUE}임시 디렉토리 생성: ${TEMP_DIR}${NC}"

  # 백업 파일 압축 해제
  echo -e "${BLUE}백업 파일 압축 해제 중...${NC}"
  tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

  # 메타데이터 파일 확인
  if [ -f "${TEMP_DIR}/metadata.txt" ]; then
    echo -e "${BLUE}백업 메타데이터:${NC}"
    cat "${TEMP_DIR}/metadata.txt"

    # 메타데이터에서 체인 정보 추출
    CHAIN_DIR=$(grep "체인:" "${TEMP_DIR}/metadata.txt" | cut -d' ' -f2)
    if [ -z "$CHAIN_DIR" ]; then
      echo -e "${YELLOW}경고: 메타데이터에서 체인 정보를 찾을 수 없습니다. 대상 노드의 디렉토리 구조를 검사합니다...${NC}"
      CHAIN_DIR=""
    fi
  else
    echo -e "${YELLOW}경고: 메타데이터 파일이 없습니다. 대상 노드의 디렉토리 구조를 검사합니다...${NC}"
    CHAIN_DIR=""
  fi

  # 체인 디렉토리 확인
  if [ -z "$CHAIN_DIR" ]; then
    if [[ "${TARGET_NODE}" == 3node* ]]; then
      CHAIN_DIR="creditcoin3"
      echo -e "${BLUE}대상 노드는 Creditcoin 3.0으로 감지되었습니다.${NC}"
    elif [[ "${TARGET_NODE}" == node* ]]; then
      CHAIN_DIR="creditcoin"
      echo -e "${BLUE}대상 노드는 Creditcoin 2.0으로 감지되었습니다.${NC}"
    else
      echo -e "${RED}오류: 노드 이름 형식을 인식할 수 없습니다: ${TARGET_NODE}${NC}"
      echo -e "${YELLOW}노드 이름은 '3node*' 또는 'node*' 형식이어야 합니다.${NC}"
      rm -rf "$TEMP_DIR"

      # 노드 재시작 (필요한 경우)
      if [ "$NODE_WAS_RUNNING" = true ]; then
        echo -e "${BLUE}노드를 다시 시작합니다...${NC}"
        docker start ${TARGET_NODE}
        echo -e "${GREEN}노드가 재시작되었습니다.${NC}"
      fi

      return 1
    fi
  fi

  # 키스토어 및 네트워크 디렉토리 경로
  TARGET_KEYSTORE_DIR="./${TARGET_NODE}/data/chains/${CHAIN_DIR}/keystore"
  TARGET_NETWORK_DIR="./${TARGET_NODE}/data/chains/${CHAIN_DIR}/network"

  # 백업에 키 파일이 있는지 확인
  if [ ! -d "${TEMP_DIR}/keystore" ] && [ ! -d "${TEMP_DIR}/network" ]; then
    echo -e "${RED}오류: 백업 파일에 키스토어 또는 네트워크 디렉토리가 포함되어 있지 않습니다.${NC}"
    rm -rf "$TEMP_DIR"

    # 노드 재시작 (필요한 경우)
    if [ "$NODE_WAS_RUNNING" = true ]; then
      echo -e "${BLUE}노드를 다시 시작합니다...${NC}"
      docker start ${TARGET_NODE}
      echo -e "${GREEN}노드가 재시작되었습니다.${NC}"
    fi

    return 1
  fi

  # 대상 디렉토리 백업
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  if [ -d "$TARGET_KEYSTORE_DIR" ]; then
    echo -e "${YELLOW}기존 키스토어 디렉토리 백업 중...${NC}"
    mv "${TARGET_KEYSTORE_DIR}" "${TARGET_KEYSTORE_DIR}.backup-${TIMESTAMP}"
  fi

  if [ -d "$TARGET_NETWORK_DIR" ]; then
    echo -e "${YELLOW}기존 네트워크 디렉토리 백업 중...${NC}"
    mv "${TARGET_NETWORK_DIR}" "${TARGET_NETWORK_DIR}.backup-${TIMESTAMP}"
  fi

  # 대상 디렉토리 생성
  mkdir -p "$TARGET_KEYSTORE_DIR"
  mkdir -p "$TARGET_NETWORK_DIR"

  # 키 파일 복원
  if [ -d "${TEMP_DIR}/keystore" ]; then
    echo -e "${BLUE}키스토어 파일 복원 중...${NC}"
    cp -r "${TEMP_DIR}/keystore/"* "${TARGET_KEYSTORE_DIR}/" 2>/dev/null
  fi

  if [ -d "${TEMP_DIR}/network" ]; then
    echo -e "${BLUE}네트워크 파일 복원 중...${NC}"
    cp -r "${TEMP_DIR}/network/"* "${TARGET_NETWORK_DIR}/" 2>/dev/null
  fi

  # 파일 권한 설정
  echo -e "${BLUE}파일 권한 설정 중...${NC}"
  chmod 700 "$TARGET_KEYSTORE_DIR" "$TARGET_NETWORK_DIR"
  find "$TARGET_KEYSTORE_DIR" -type f -exec chmod 600 {} \; 2>/dev/null
  find "$TARGET_NETWORK_DIR" -type f -exec chmod 600 {} \; 2>/dev/null

  # 임시 디렉토리 삭제
  rm -rf "$TEMP_DIR"

  echo -e "${GREEN}세션키가 '${TARGET_NODE}' 노드에 성공적으로 복원되었습니다.${NC}"
  echo -e "${YELLOW}주의: 동일한 세션키를 가진 두 노드를 동시에 실행하면 슬래싱(처벌)이 발생할 수 있습니다.${NC}"

  # 노드 재시작
  echo -e "${BLUE}노드를 다시 시작하시겠습니까? (y/N)${NC}"
  read -p "" RESTART_CONFIRM
  if [[ "$RESTART_CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}노드 시작 중...${NC}"
    docker start ${TARGET_NODE}
    echo -e "${GREEN}노드가 시작되었습니다.${NC}"
  else
    echo -e "${YELLOW}노드는 중지된 상태로 유지됩니다.${NC}"
  fi
}
