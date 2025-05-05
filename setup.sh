#!/bin/bash
# setup.sh - Creditcoin Docker 유틸리티 설정 스크립트

# 설정 디렉토리 및 파일 경로
CONFIG_DIR="$HOME/.config/creditcoin-docker"
CONFIG_FILE="$CONFIG_DIR/config"

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 설정 초기화 함수
setup_config() {
  # 스크립트 실행 위치 감지
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
  # 설정 디렉토리 생성
  mkdir -p "$CONFIG_DIR"
  
  # 설정 파일에 경로 저장
  echo "CREDITCOIN_DIR=\"$SCRIPT_DIR\"" > "$CONFIG_FILE"
  
  echo -e "${GREEN}설정이 초기화되었습니다: $CONFIG_FILE${NC}"
  echo -e "${GREEN}Creditcoin Docker 디렉토리: $SCRIPT_DIR${NC}"
}

# .bashrc 파일에 추가
add_to_bashrc() {
  local bashrc="$HOME/.bashrc"
  local marker="# === Creditcoin Docker Utils ==="
  
  # 이미 추가되었는지 확인
  if grep -q "$marker" "$bashrc"; then
    echo -e "${YELLOW}이미 .bashrc에 추가되어 있습니다.${NC}"
    return 0
  fi
  
  # bashrc에 추가
  cat >> "$bashrc" << 'EOBASHRC'

# === Creditcoin Docker Utils ===
if [ -f "$HOME/.config/creditcoin-docker/config" ]; then
    source "$HOME/.config/creditcoin-docker/config"
    
    # Creditcoin Docker 디렉토리로 이동
    cdcd() { cd "$CREDITCOIN_DIR"; }
    
    # Docker 기본 명령어
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dstats='docker stats'
    
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
    
    # 세션 키 교체 - 3.0 노드 (컨테이너 내부에서 실행)
    rotatekey() { 
      local node=$1
      if [[ $node == 3node* ]]; then
        local num=$(echo $node | sed 's/3node//g')
        local port=$((33980 + $num))
        echo "Rotating session keys for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33980 + $node))
        echo "Rotating session keys for 3node$node..."
        docker exec 3node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use '3nodeX' format or just the node number."
      fi
    }
    
    # 세션 키 교체 - 2.0 노드 (컨테이너 내부에서 실행)
    rotatekeyLegacy() { 
      local node=$1
      if [[ $node == node* ]]; then
        local num=$(echo $node | sed 's/node//g')
        local port=$((33970 + $num))
        echo "Rotating session keys for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33970 + $node))
        echo "Rotating session keys for node$node..."
        docker exec node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use 'nodeX' format or just the node number."
      fi
    }
    
    # 노드 건강 상태 확인 - 3.0 노드
    checkHealth() {
      local node=$1
      if [[ $node == 3node* ]]; then
        local num=$(echo $node | sed 's/3node//g')
        local port=$((33980 + $num))
        echo "Checking health status for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33980 + $node))
        echo "Checking health status for 3node$node..."
        docker exec 3node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use '3nodeX' format or just the node number."
      fi
    }
    
    # 노드 건강 상태 확인 - 2.0 노드
    checkHealthLegacy() {
      local node=$1
      if [[ $node == node* ]]; then
        local num=$(echo $node | sed 's/node//g')
        local port=$((33970 + $num))
        echo "Checking health status for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33970 + $node))
        echo "Checking health status for node$node..."
        docker exec node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use 'nodeX' format or just the node number."
      fi
    }
    
    # 노드 이름 확인 - 3.0 노드
    checkName() {
      local node=$1
      if [[ $node == 3node* ]]; then
        local num=$(echo $node | sed 's/3node//g')
        local port=$((33980 + $num))
        echo "Checking node name for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33980 + $node))
        echo "Checking node name for 3node$node..."
        docker exec 3node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use '3nodeX' format or just the node number."
      fi
    }
    
    # 노드 이름 확인 - 2.0 노드
    checkNameLegacy() {
      local node=$1
      if [[ $node == node* ]]; then
        local num=$(echo $node | sed 's/node//g')
        local port=$((33970 + $num))
        echo "Checking node name for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33970 + $node))
        echo "Checking node name for node$node..."
        docker exec node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_name", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use 'nodeX' format or just the node number."
      fi
    }
    
    # 노드 버전 확인 - 3.0 노드
    checkVersion() {
      local node=$1
      if [[ $node == 3node* ]]; then
        local num=$(echo $node | sed 's/3node//g')
        local port=$((33980 + $num))
        echo "Checking node version for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33980 + $node))
        echo "Checking node version for 3node$node..."
        docker exec 3node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use '3nodeX' format or just the node number."
      fi
    }
    
    # 노드 버전 확인 - 2.0 노드
    checkVersionLegacy() {
      local node=$1
      if [[ $node == node* ]]; then
        local num=$(echo $node | sed 's/node//g')
        local port=$((33970 + $num))
        echo "Checking node version for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33970 + $node))
        echo "Checking node version for node$node..."
        docker exec node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "system_version", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use 'nodeX' format or just the node number."
      fi
    }
    
    # 최신 블록 정보 확인 - 3.0 노드
    getLatestBlock() {
      local node=$1
      if [[ $node == 3node* ]]; then
        local num=$(echo $node | sed 's/3node//g')
        local port=$((33980 + $num))
        echo "Getting latest block info for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33980 + $node))
        echo "Getting latest block info for 3node$node..."
        docker exec 3node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use '3nodeX' format or just the node number."
      fi
    }
    
    # 최신 블록 정보 확인 - 2.0 노드
    getLatestBlockLegacy() {
      local node=$1
      if [[ $node == node* ]]; then
        local num=$(echo $node | sed 's/node//g')
        local port=$((33970 + $num))
        echo "Getting latest block info for $node..."
        docker exec $node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
      elif [[ $node =~ ^[0-9]+$ ]]; then
        local port=$((33970 + $node))
        echo "Getting latest block info for node$node..."
        docker exec node$node bash -c 'curl -s -H "Content-Type: application/json" -d '"'"'{"id":1, "jsonrpc":"2.0", "method": "chain_getBlock", "params":[]}'"'"' http://localhost:'$port'/' | jq
      else
        echo "Invalid input. Use 'nodeX' format or just the node number."
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
    
    # SIEG custom alias
    journalcall() { journalctl -u $1.service -n 50 -f; }
    alias jc=journalcall
    alias cdsys='cd /etc/systemd/system'
    alias sysdr='systemctl daemon-reload'
    sysre() { systemctl restart $1; }
    sysen() { systemctl enable $1; }
    sysst() { systemctl status $1; }
    alias updateb='source ~/.bashrc'
    alias editb='nano ~/.bashrc'
    nanocall() { nano /etc/systemd/system/$1.service; }
    alias nn=nanocall
fi
EOBASHRC
  
  echo -e "${GREEN}.bashrc에 유틸리티가 추가되었습니다.${NC}"
}

# 초기화 및 실행
echo -e "${BLUE}=== Creditcoin Docker 유틸리티 설정 ===${NC}"

# 클린 모드 확인
if [ "$1" == "--clean" ]; then
  echo -e "${YELLOW}클린 설치가 요청되었습니다. 기존 설정을 제거합니다...${NC}"
  rm -f "$CONFIG_FILE"
fi

# 설정 초기화
setup_config

# .bashrc에 추가
add_to_bashrc

# 한 번만 표시하는 최종 메시지
echo -e "${GREEN}설치가 완료되었습니다!${NC}"
echo -e "${YELLOW}변경 사항을 적용하려면 터미널을 다시 시작하거나 'source ~/.bashrc'를 실행하세요.${NC}"
