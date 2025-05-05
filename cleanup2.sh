#!/bin/bash

echo "!!! 경고 !!!"
echo "이 스크립트는 Creditcoin 2.0 레거시 관련 파일과 컨테이너를 완전히 삭제합니다:"
echo " - 모든 node 컨테이너"
echo " - docker-compose-legacy.yml"
echo " - Dockerfile.legacy"
echo " - 모든 node 디렉토리"
echo " - 모든 관련 빌드 캐시"
echo ""
echo "이 작업은 되돌릴 수 없습니다."
echo ""
read -p "계속 진행하시겠습니까? (y/N) " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "===== Creditcoin 2.0 레거시 노드 정리 시작 ====="

    echo "실행 중인 node 컨테이너 중지 및 삭제..."
    docker ps -a --format "{{.Names}}" | grep '^node[0-9]' | xargs -r docker stop
    docker ps -a --format "{{.Names}}" | grep '^node[0-9]' | xargs -r docker rm
    
    echo "node 이미지 삭제..."
    docker images | grep 'creditcoin2' | awk '{print $3}' | xargs -r docker rmi -f
    
    echo "===== 파일 시스템 정리 시작 ====="

    echo "모든 node 디렉토리 삭제..."
    rm -rf ./node[0-9]*

    echo "Dockerfile.legacy 삭제..."
    rm -f Dockerfile.legacy

    echo "docker-compose-legacy.yml 삭제..."
    rm -f docker-compose-legacy.yml
    
    echo "===== Docker 캐시 정리 시작 ====="
    
    echo "Docker 빌드 캐시 삭제..."
    docker builder prune -f
    
    echo "사용하지 않는 Docker 볼륨 삭제..."
    docker volume prune -f
    
    echo "사용하지 않는 네트워크 삭제..."
    docker network prune -f

    echo "===== 정리 완료 ====="
    echo "모든 Creditcoin 2.0 레거시 관련 컨테이너, 이미지, 캐시 및 파일들이 삭제되었습니다."
else
    echo "작업이 취소되었습니다."
fi
