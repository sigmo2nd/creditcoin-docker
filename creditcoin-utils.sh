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
alias jc=journalcall
alias cdsys='cd /etc/systemd/system'
alias sysdr='systemctl daemon-reload'
sysre() { systemctl restart $1; }
sysen() { systemctl enable $1; }
sysst() { systemctl status $1; }
nanocall() { nano /etc/systemd/system/$1.service; }
alias nn=nanocall
