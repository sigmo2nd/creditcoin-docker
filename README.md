# Creditcoin Docker

이 프로젝트는 **아사히 리눅스(Asahi Linux)** ARM 기반 환경에서 Docker를 사용하여 Creditcoin 노드를 쉽게 설정하고 관리할 수 있는 스크립트 모음입니다.

## 중요! 시스템 요구사항

- **아사히 리눅스(Asahi Linux)** ARM 기반 Ubuntu
- Apple Silicon 맥 하드웨어(M1/M2)에 최적화됨
- Docker 및 Docker Compose
- 최소 16GB RAM (Creditcoin 노드 권장 사양: 32GB)
- 충분한 저장 공간

## 주요 기능

- Creditcoin 3.0 노드 설정 및 관리 (`add3node.sh`)
- Creditcoin 2.0 레거시 노드 설정 및 관리 (`add2node.sh`)
- 노드 정리 및 삭제 (`cleanup2.sh`, `cleanup3.sh`)
- 다양한 옵션 지원: 텔레메트리 활성화/비활성화, 커스텀 노드 이름, 프루닝 설정 등

## 설치 방법

```bash
# 저장소 클론
git clone https://github.com/sigmo2nd/creditcoin-docker.git
cd creditcoin-docker
```

## 사용 방법

### Creditcoin 3.0 노드 생성

```bash
./add3node.sh <노드번호> [옵션]

# 옵션:
#   -v, --version      노드 버전 (기본값: 3.32.0-mainnet)
#   -t, --telemetry    텔레메트리 활성화 (기본값: 비활성화)
#   -n, --name         노드 이름 (기본값: 3Node<번호>)
#   -p, --pruning      프루닝 값 설정 (기본값: 0, 0일 경우 옵션 추가 안함)

# 사용 예시:
./add3node.sh 0                      # 기본 설정으로 노드 생성
./add3node.sh 1 -v 3.39.0-mainnet    # 최신 버전으로 노드 생성
./add3node.sh 2 -t                   # 텔레메트리 활성화한 노드 생성
./add3node.sh 3 -n ValidatorA        # 지정한 이름으로 노드 생성
./add3node.sh 4 -p 1000              # 프루닝 값 1000으로 설정
```

### Creditcoin 2.0 레거시 노드 생성

```bash
./add2node.sh <노드번호> [옵션]

# 옵션:
#   -v, --version      노드 버전 (기본값: 2.230.2-mainnet)
#   -t, --telemetry    텔레메트리 활성화 (기본값: 비활성화)
#   -n, --name         노드 이름 (기본값: 3Node<번호>)

# 사용 예시:
./add2node.sh 0                        # 기본 설정으로 노드 생성
./add2node.sh 1 -t -n ValidatorLegacy  # 텔레메트리 활성화 및 이름 지정
```

### 노드 정리

```bash
# Creditcoin 2.0 레거시 노드 정리
./cleanup2.sh

# Creditcoin 3.0 노드 정리
./cleanup3.sh
```

## 아사히 리눅스 관련 주의사항

이 프로젝트는 특별히 Apple Silicon(M1/M2) 맥에 설치된 아사히 리눅스에 최적화되어 있습니다. 아사히 리눅스는 ARM 아키텍처를 네이티브로 활용하므로 x86 에뮬레이션 없이 최고의 성능을 발휘합니다.

현재 아사히 리눅스는 일부 I/O 장치(특히 GPU)에 대한 지원이 제한적일 수 있으나, Creditcoin 노드 운영에는 영향이 없습니다.

## 일반 주의사항

- 정리 스크립트는 모든 관련 컨테이너, 이미지, 볼륨, 디렉토리를 삭제합니다. 사용 전 데이터 백업을 권장합니다.
- 노드 운영을 위해 충분한 시스템 리소스가 필요합니다.
- 텔레메트리 활성화 시 노드 정보가 Creditcoin 네트워크에 공개됩니다.

## 라이센스

이 프로젝트는 모든 권리를 보유한 폐쇄적 소프트웨어입니다. 무단 복제, 배포, 수정이 금지되어 있습니다. 사용 권한은 작성자에게 문의하시기 바랍니다.

© 2025 sigmo2nd. All Rights Reserved.

## 기여 방법

기여를 원하시는 경우 다음과 같은 방법으로 참여하실 수 있습니다:

1. **이슈 보고**: 버그를 발견하셨거나 개선 제안이 있으시면 GitHub 이슈를 통해 알려주세요.
2. **문서화**: 설명서 개선이나 사용 예시 추가를 통해 기여하실 수 있습니다.
3. **테스트**: 다양한 환경에서 테스트하고 결과를 공유해주세요.
4. **최적화**: 스크립트 최적화 및 성능 개선 제안을 환영합니다.

모든 기여는 관리자의 검토 및 승인 후 적용됩니다. 기여하기 전에 반드시 관리자에게 문의하시기 바랍니다.# ctc-node-setup
