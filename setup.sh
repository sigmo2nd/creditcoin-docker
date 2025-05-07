#!/bin/bash
# setup.sh - Creditcoin Docker 유틸리티 설정 스크립트

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 시스템 환경 확인
check_environment() {
  echo -e "${BLUE}=== 시스템 환경 확인 중 ===${NC}"
  
  # 아키텍처 확인
  ARCH=$(uname -m)
  
  if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    echo -e "${GREEN}감지된 아키텍처: $ARCH (Apple Silicon 호환)${NC}"
    DOCKER_ARCH="arm64"
  else
    echo -e "${YELLOW}감지된 아키텍처: $ARCH (Apple Silicon이 아닙니다)${NC}"
    echo -e "${RED}경고: 이 스크립트는 Apple Silicon(ARM64) 하드웨어에서 Asahi Linux Ubuntu 환경용으로 설계되었습니다.${NC}"
    echo -e "${RED}다른 환경에서는 제대로 작동하지 않을 수 있습니다.${NC}"
    read -p "계속 진행하시겠습니까? (y/N) " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo -e "${RED}설치가 취소되었습니다.${NC}"
      exit 1
    fi
    
    # x86_64 아키텍처 확인
    if [[ "$ARCH" == "x86_64" ]]; then
      DOCKER_ARCH="amd64"
    else
      echo -e "${RED}지원되지 않는 아키텍처입니다. 설치를 중단합니다.${NC}"
      exit 1
    fi
  fi
  
  # OS 확인
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    echo -e "${GREEN}감지된 운영체제: $OS_NAME $OS_VERSION${NC}"
    
    # Asahi Linux Ubuntu인지 확인
    if [[ ! "$OS_NAME" =~ "Ubuntu" ]]; then
      echo -e "${RED}경고: 이 스크립트는 Asahi Linux Ubuntu 환경용으로 설계되었습니다.${NC}"
      echo -e "${RED}현재 운영체제($OS_NAME)에서는 제대로 작동하지 않을 수 있습니다.${NC}"
      read -p "계속 진행하시겠습니까? (y/N) " response
      if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${RED}설치가 취소되었습니다.${NC}"
        exit 1
      fi
    fi
  else
    echo -e "${RED}운영체제를 확인할 수 없습니다. 설치를 중단합니다.${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}환경 확인이 완료되었습니다.${NC}"
}

# 의존성 확인 및 설치
install_dependencies() {
  echo -e "${BLUE}=== 필요한 의존성 확인 및 설치 ===${NC}"
  
  # Docker 설치 확인
  if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker가 설치되어 있지 않습니다. 설치를 시작합니다...${NC}"
    
    # 필요한 패키지 설치
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
    
    # Docker 저장소 키 추가
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # 아키텍처에 맞는 Docker 저장소 추가
    echo "deb [arch=${DOCKER_ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Docker 설치
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Docker 서비스 시작 및 자동 시작 활성화
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # 현재 사용자를 docker 그룹에 추가 (sudo 없이 docker 명령어 사용 가능)
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}Docker가 성공적으로 설치되었습니다.${NC}"
  else
    echo -e "${GREEN}Docker가 이미 설치되어 있습니다.${NC}"
  fi
  
  # Docker Compose v2 설치 확인
  if ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}Docker Compose v2가 설치되어 있지 않습니다. 설치를 시작합니다...${NC}"
    
    # Docker Compose 플러그인 디렉토리 생성
    mkdir -p ~/.docker/cli-plugins
    
    # 아키텍처에 맞는 Docker Compose v2 다운로드 및 설치
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    
    if [[ "$DOCKER_ARCH" == "arm64" ]]; then
      COMPOSE_ARCH="linux-aarch64"
    else
      COMPOSE_ARCH="linux-x86_64"
    fi
    
    curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-${COMPOSE_ARCH}" -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    
    echo -e "${GREEN}Docker Compose v2가 성공적으로 설치되었습니다.${NC}"
  else
    echo -e "${GREEN}Docker Compose v2가 이미 설치되어 있습니다.${NC}"
  fi
  
  # git-lfs 설치 확인
  if ! command -v git-lfs &> /dev/null; then
    echo -e "${YELLOW}git-lfs가 설치되어 있지 않습니다. 설치를 시작합니다...${NC}"
    
    sudo apt update
    sudo apt install -y git-lfs
    git lfs install
    
    echo -e "${GREEN}git-lfs가 성공적으로 설치되었습니다.${NC}"
  else
    echo -e "${GREEN}git-lfs가 이미 설치되어 있습니다.${NC}"
  fi
  
  echo -e "${GREEN}모든 필요한 의존성이 설치되었습니다.${NC}"
  echo -e "${YELLOW}Docker 그룹 변경사항을 적용하려면 로그아웃 후 다시 로그인하거나 시스템을 재부팅하세요.${NC}"
}

# .bashrc 파일에 추가
add_to_bashrc() {
  local bashrc="$HOME/.bashrc"
  local marker="# === Creditcoin Docker Utils ==="
  local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
  # 이미 추가되었는지 확인
  if grep -q "$marker" "$bashrc"; then
    echo -e "${YELLOW}이미 .bashrc에 추가되어 있습니다.${NC}"
    return 0
  fi
  
  # bashrc에 추가
  cat >> "$bashrc" << EOF

# === Creditcoin Docker Utils ===
# Creditcoin Docker 설치 경로
CREDITCOIN_DIR="$script_dir"
CREDITCOIN_UTILS="\$CREDITCOIN_DIR/creditcoin-utils.sh"

# 유틸리티 함수 로드
if [ -f "\$CREDITCOIN_UTILS" ]; then
    source "\$CREDITCOIN_UTILS"
fi

# Creditcoin Docker 디렉토리로 이동
cdcd() { cd "\$CREDITCOIN_DIR"; }

# 기본 별칭들 (짧은 것들만 여기에 유지)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dstats='docker stats'
alias updateb='source ~/.bashrc'
alias editb='nano ~/.bashrc'
EOF

  echo -e "${GREEN}.bashrc에 유틸리티가 추가되었습니다.${NC}"
}

# 초기화 및 실행
echo -e "${BLUE}=== Creditcoin Docker 유틸리티 설정 ===${NC}"

# 클린 모드 확인
if [ "$1" == "--clean" ]; then
  echo -e "${YELLOW}클린 설치가 요청되었습니다. 기존 설정을 제거합니다...${NC}"
fi

# 환경 확인
check_environment

# 의존성 설치
install_dependencies

# 현재 디렉토리 감지
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "${GREEN}Creditcoin Docker 디렉토리: $SCRIPT_DIR${NC}"

# .bashrc에 추가
add_to_bashrc

# 한 번만 표시하는 최종 메시지
echo -e "${GREEN}설치가 완료되었습니다!${NC}"
echo -e "${YELLOW}변경 사항을 적용하려면 터미널을 다시 시작하거나 'source ~/.bashrc'를 실행하세요.${NC}"
