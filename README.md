# 🚀 GitHub Actions Demo

GitHub Actions를 활용한 CI/CD 파이프라인 실습 프로젝트입니다.

## 🎯 프로젝트 배경 및 목적

### 왜 이 프로젝트를 만들었나요?

현대 소프트웨어 개발에서는 **빠른 배포**와 **안정적인 서비스**가 핵심입니다. 하지만 이를 위해서는:

- 🔄 **자동화된 빌드 및 배포**: 매번 수동으로 빌드하고 배포하는 것은 비효율적
- 🧪 **지속적인 테스트**: 코드 변경 시마다 자동으로 테스트해야 안정성 보장
- 📊 **실시간 모니터링**: 서비스 상태를 실시간으로 파악해야 문제를 빠르게 해결
- 🔒 **보안 및 품질 관리**: 자동화된 보안 스캔과 코드 품질 검사

이 프로젝트는 이러한 현대적인 개발 환경을 **실습을 통해 체험**할 수 있도록 설계되었습니다.

### 이 프로젝트로 무엇을 배울 수 있나요?

1. **CI/CD 파이프라인 구축**: 코드 커밋부터 배포까지의 전체 과정 자동화
2. **Docker 컨테이너화**: 애플리케이션을 컨테이너로 패키징하고 배포
3. **모니터링 시스템**: Prometheus와 Grafana를 활용한 시스템 모니터링
4. **자동화 스크립트**: 반복 작업을 자동화하는 스크립트 작성
5. **클라우드 배포**: 실제 클라우드 환경에 애플리케이션 배포

## 📋 프로젝트 개요

이 프로젝트는 다음 기술들을 학습하고 실습할 수 있도록 구성되었습니다:

- **GitHub Actions**: 자동화된 CI/CD 파이프라인
- **Docker**: 컨테이너화 및 멀티스테이지 빌드
- **Node.js**: Express.js 기반 웹 애플리케이션
- **모니터링**: Prometheus, Grafana를 활용한 시스템 모니터링
- **자동화**: 배포, 테스트, 보안 스캔 자동화

## 🏗️ 프로젝트 구조

```
github-actions-demo/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 파이프라인
│       ├── docker-build.yml    # Docker 빌드 및 푸시
│       └── deploy-vm.yml       # VM 배포
├── monitoring/
│   ├── prometheus.yml          # Prometheus 설정
│   └── alert_rules.yml         # 알림 규칙
├── scripts/
│   ├── setup.sh               # 프로젝트 설정
│   └── deploy.sh              # 배포 스크립트
├── src/
│   └── app.js                 # 메인 애플리케이션
├── Dockerfile                 # 프로덕션용 Dockerfile
├── Dockerfile.dev             # 개발용 Dockerfile
├── Dockerfile.test            # 테스트용 Dockerfile
├── Dockerfile.multistage      # 멀티스테이지 Dockerfile
├── docker-compose.yml         # Docker Compose 설정
├── package.json               # Node.js 의존성
└── README.md                  # 프로젝트 문서
```

## 🚀 빠른 시작

### 1. 환경 변수 설정

```bash
# 환경 변수 대화형 설정
npm run setup:env

# 또는 수동으로 .env 파일 생성
cp config.env.example .env
# .env 파일을 편집하여 필요한 값들 설정
```

### 2. 프로젝트 설정

#### 일반 환경
```bash
# 저장소 클론
git clone https://github.com/your-username/github-actions-demo.git
cd github-actions-demo

# 설정 스크립트 실행
chmod +x scripts/setup.sh
./scripts/setup.sh
```


### 3. 날짜별 실습 실행

#### 📅 Day 1: 클라우드 VM 배포 (Cloud Master)
```bash
# 1일차 실습 범위 확인
npm run day1:scope

# 1일차 전체 실습 실행
npm run day1:all

# 개별 실행
npm run day1:build    # Docker 이미지 빌드
npm run day1:test     # 테스트 실행
npm run day1:deploy   # VM에 서비스 배포
```

#### 📅 Day 2: Kubernetes 클러스터 배포 (Cloud Master)
```bash
# 2일차 실습 범위 확인
npm run day2:scope

# 2일차 전체 실습 실행
npm run day2:all

# 개별 실행
npm run day2:build    # K8s용 이미지 빌드
npm run day2:test     # K8s 통합 테스트 실행
npm run day2:deploy   # K8s 클러스터에 배포
```

#### 📅 Day 3: 프로덕션 환경 및 모니터링 (Cloud Master)
```bash
# 3일차 실습 범위 확인
npm run day3:scope

# 3일차 전체 실습 실행
npm run day3:all

# 개별 실행
npm run day3:build    # 프로덕션 최적화 이미지 빌드
npm run day3:test     # 성능 및 보안 테스트
npm run day3:deploy   # 엔터프라이즈급 모니터링 포함 배포
```

### 3. 로컬 개발 환경 실행

#### 일반 환경
```bash
# Docker Compose로 전체 스택 실행
docker-compose up -d

# 애플리케이션 접속
curl http://localhost:3000/health
```


### 4. 개별 서비스 실행

```bash
# 개발용 컨테이너 실행
docker run -p 3000:3000 github-actions-demo:dev

# 테스트 실행
docker run --rm github-actions-demo:test
```

## 🐳 Docker 이미지

### 이미지 종류

- **`github-actions-demo:latest`**: 프로덕션용 (최적화된 크기)
- **`github-actions-demo:dev`**: 개발용 (핫 리로드 지원)
- **`github-actions-demo:test`**: 테스트용 (테스트 도구 포함)
- **`github-actions-demo:multistage`**: 멀티스테이지 빌드

### 빌드 명령어

```bash
# 기본 이미지 빌드
docker build -f Dockerfile -t github-actions-demo:latest .

# 개발용 이미지 빌드
docker build -f Dockerfile.dev -t github-actions-demo:dev .

# 테스트용 이미지 빌드
docker build -f Dockerfile.test -t github-actions-demo:test .

# 멀티스테이지 이미지 빌드
docker build -f Dockerfile.multistage -t github-actions-demo:multistage .
```

## 🔄 CI/CD 파이프라인

### GitHub Actions 워크플로우

1. **CI Pipeline** (`ci.yml`)
   - 코드 품질 검사 (린팅, 포맷팅)
   - 테스트 실행 (단위, 통합)
   - 보안 스캔 (의존성, 취약점)
   - Docker 이미지 빌드

2. **Docker Build** (`docker-build.yml`)
   - Docker Hub에 이미지 자동 푸시
   - 멀티 아키텍처 빌드
   - 이미지 스캔 및 보안 검사

3. **VM Deploy** (`deploy-vm.yml`)
   - VM에 자동 배포
   - 헬스 체크 및 롤백
   - 알림 전송

### 필요한 GitHub Secrets

```bash
# Docker Hub 인증
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password

# VM 배포 (선택사항)
VM_HOST=your-vm-host
VM_USERNAME=your-vm-username
VM_SSH_KEY=your-ssh-private-key

# 알림 (선택사항)
SLACK_WEBHOOK=your-slack-webhook-url
```

## 📊 모니터링

### Prometheus 메트릭

- **애플리케이션 메트릭**: `http://localhost:3000/metrics`
- **Prometheus UI**: `http://localhost:9090`
- **Grafana 대시보드**: `http://localhost:3001` (admin/admin)

### 주요 모니터링 지표

- CPU 사용률
- 메모리 사용률
- 디스크 공간
- 네트워크 트래픽
- 애플리케이션 응답 시간
- 에러율

## 🧪 테스트

### 테스트 실행

```bash
# 로컬에서 테스트
npm test

# Docker 컨테이너에서 테스트
docker run --rm github-actions-demo:test

# 통합 테스트
npm run test:integration
```

### 테스트 커버리지

```bash
# 커버리지 생성
npm run test:coverage

# 커버리지 리포트 확인
open coverage/lcov-report/index.html
```

## 🎁 프로젝트 산출물

### 배포 완료 후 생성되는 것들

이 프로젝트를 완전히 배포하면 다음과 같은 것들이 생성됩니다:

#### 1. 🐳 Docker 이미지들
```bash
# Docker Hub에 업로드된 이미지들
jungfrau70/github-actions-demo:latest      # 프로덕션용
jungfrau70/github-actions-demo:dev         # 개발용
jungfrau70/github-actions-demo:test        # 테스트용
jungfrau70/github-actions-demo:multistage  # 멀티스테이지
```

#### 2. 🌐 실행 중인 서비스들
- **웹 애플리케이션**: `http://localhost:3000`
- **Prometheus 모니터링**: `http://localhost:9090`
- **Grafana 대시보드**: `http://localhost:3001`
- **PostgreSQL 데이터베이스**: `localhost:5432`
- **Redis 캐시**: `localhost:6379`

#### 3. 📊 모니터링 대시보드
- **시스템 메트릭**: CPU, 메모리, 디스크 사용률
- **애플리케이션 메트릭**: 응답 시간, 요청 수, 에러율
- **컨테이너 메트릭**: Docker 컨테이너 상태 및 리소스 사용량

#### 4. 🔄 자동화된 워크플로우
- **CI 파이프라인**: 코드 품질 검사, 테스트, 보안 스캔
- **CD 파이프라인**: 자동 빌드, 배포, 알림
- **모니터링 알림**: 시스템 이상 시 자동 알림

## 🚀 배포 환경 및 대상

### 📍 배포 가능한 환경들

이 프로젝트는 다양한 환경에 배포할 수 있도록 설계되었습니다:

#### 1. 🏠 **로컬 환경 (Local)**
```bash
# 로컬 머신에서 Docker Compose로 실행
./scripts/deploy.sh local

# 배포 위치: localhost
# - 웹 애플리케이션: http://localhost:3000
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3001
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
```

#### 2. ☁️ **클라우드 VM (Virtual Machine)**
```bash
# AWS EC2, GCP Compute Engine, Azure VM 등에 배포
./scripts/deploy.sh production

# 배포 위치: 클라우드 VM의 공인 IP
# - 웹 애플리케이션: http://YOUR_VM_IP:3000
# - 모니터링: http://YOUR_VM_IP:9090, http://YOUR_VM_IP:3001
```

#### 3. 🐳 **Docker Hub (컨테이너 레지스트리)**
```bash
# Docker 이미지만 빌드하여 Docker Hub에 푸시
npm run docker:build
docker push jungfrau70/github-actions-demo:latest

# 배포 위치: Docker Hub
# - 이미지: jungfrau70/github-actions-demo:latest
# - 다른 환경에서 이 이미지를 pull하여 실행 가능
```

#### 4. 🌐 **GitHub Pages (정적 사이트)**
```bash
# GitHub Actions를 통해 자동 배포
git push origin main

# 배포 위치: GitHub Pages
# - URL: https://your-username.github.io/github-actions-demo
# - 정적 파일만 배포 (Node.js 서버는 실행되지 않음)
```

### 🎯 **실습별 배포 환경 (Cloud Master 과정)**

#### Day 1: 클라우드 VM 배포
- **목적**: 기본 CI/CD 파이프라인 구축 및 VM 배포
- **배포 대상**: AWS EC2, GCP Compute Engine, Azure VM
- **기술 스택**: Docker, Docker Compose, VM 인스턴스
- **확인 방법**: `http://YOUR_VM_IP:3000`

#### Day 2: Kubernetes 클러스터 배포
- **목적**: 고급 CI/CD 파이프라인 및 K8s 오케스트레이션
- **배포 대상**: AWS EKS, GCP GKE, Azure AKS 또는 로컬 K8s
- **기술 스택**: Kubernetes, Helm, Ingress, Service Mesh
- **확인 방법**: `http://YOUR_K8S_INGRESS_IP:3000`

#### Day 3: 프로덕션 환경 및 모니터링
- **목적**: 엔터프라이즈급 모니터링 및 최적화
- **배포 대상**: 멀티 클러스터, 고가용성 환경
- **기술 스택**: Prometheus, Grafana, ELK Stack, Istio
- **확인 방법**: 도메인 또는 공인 IP

### 🔧 **배포 환경 설정 (Cloud Master 과정)**

#### Day 1: 클라우드 VM 설정
```bash
# 환경 변수 설정
npm run setup:env

# VM 접속 정보 설정
export VM_HOST="your-vm-ip"
export VM_USERNAME="ubuntu"
export VM_SSH_KEY="~/.ssh/id_rsa"

# VM 배포
npm run day1:deploy
```

#### Day 2: Kubernetes 클러스터 설정
```bash
# K8s 클러스터 정보 설정
export K8S_CLUSTER_NAME="your-cluster-name"
export K8S_NAMESPACE="github-actions-demo"
export K8S_INGRESS_HOST="your-ingress-host"

# K8s 배포
npm run day2:deploy
```

#### Day 3: 프로덕션 환경 설정
```bash
# 프로덕션 환경 변수 설정
export NODE_ENV="production"
export APP_HOST="your-domain.com"
export APP_PORT="80"
export MONITORING_ENABLED="true"

# 프로덕션 배포
npm run day3:deploy
```

### 📊 **배포 후 확인 방법 (Cloud Master 과정)**

#### Day 1: 클라우드 VM 확인
```bash
# VM 접속
ssh -i ~/.ssh/id_rsa ubuntu@YOUR_VM_IP

# Docker 서비스 상태 확인
docker-compose ps

# 웹 애플리케이션 접속
curl http://YOUR_VM_IP:3000/health

# VM 리소스 확인
htop
df -h
```

#### Day 2: Kubernetes 클러스터 확인
```bash
# K8s 클러스터 접속
kubectl config use-context your-cluster-context

# Pod 상태 확인
kubectl get pods -n github-actions-demo

# 서비스 확인
kubectl get svc -n github-actions-demo

# Ingress 확인
kubectl get ingress -n github-actions-demo

# 웹 애플리케이션 접속
curl http://YOUR_K8S_INGRESS_IP:3000/health

# 클러스터 리소스 확인
kubectl top nodes
kubectl top pods -n github-actions-demo
```

#### Day 3: 프로덕션 환경 확인
```bash
# 도메인 접속
curl https://your-domain.com/health

# 모니터링 대시보드 접속
# - Prometheus: https://your-domain.com:9090
# - Grafana: https://your-domain.com:3001
# - Kibana: https://your-domain.com:5601

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces

# 서비스 메시 확인 (Istio)
kubectl get virtualservices
kubectl get destinationrules
```

### 🚨 **배포 환경별 주의사항 (Cloud Master 과정)**

#### Day 1: 클라우드 VM
- **보안 그룹**: 3000, 9090, 3001 포트가 열려있는지 확인
- **SSH 키**: VM 접속을 위한 SSH 키 설정
- **리소스**: VM의 CPU, 메모리, 디스크 용량 확인 (최소 2GB RAM, 20GB 디스크)
- **네트워크**: VPC, 서브넷, 라우팅 테이블 설정 확인

#### Day 2: Kubernetes 클러스터
- **클러스터 접근**: kubectl 설정 및 권한 확인
- **네임스페이스**: 적절한 네임스페이스 생성 및 권한 설정
- **Ingress**: LoadBalancer 또는 Ingress Controller 설정
- **리소스 제한**: Pod 리소스 요청 및 제한 설정
- **스토리지**: PersistentVolume 및 PersistentVolumeClaim 설정

#### Day 3: 프로덕션 환경
- **고가용성**: 멀티 존, 멀티 리전 배포
- **도메인**: 실제 도메인 또는 공인 IP 설정
- **SSL 인증서**: Let's Encrypt 또는 상용 인증서 설정
- **모니터링**: 24/7 모니터링을 위한 알림 설정
- **백업**: 데이터 백업 및 복구 계획 수립
- **보안**: RBAC, Network Policy, Pod Security Policy 설정

### 🔄 **자동 배포**

#### GitHub Actions를 통한 자동 배포
```bash
# main 브랜치에 푸시하면 자동 배포
git push origin main

# 배포 과정:
# 1. 코드 품질 검사 (ESLint, Prettier)
# 2. 테스트 실행 (Jest)
# 3. Docker 이미지 빌드
# 4. Docker Hub에 이미지 푸시
# 5. VM에 자동 배포 (선택사항)
# 6. 배포 상태 알림 (Slack, Discord)
```

#### 수동 배포
```bash
# 로컬 배포
./scripts/deploy.sh local

# 스테이징 배포
./scripts/deploy.sh staging

# 프로덕션 배포
./scripts/deploy.sh production
```

## ✅ 배포 후 확인 방법

### 1. 서비스 상태 확인

```bash
# 모든 서비스 상태 확인
docker-compose ps

# 애플리케이션 헬스 체크
curl http://localhost:3000/health

# 메트릭 엔드포인트 확인
curl http://localhost:3000/metrics
```

### 2. 모니터링 대시보드 접속

#### Prometheus (메트릭 수집)
```bash
# 브라우저에서 접속
http://localhost:9090

# 확인할 수 있는 것들:
# - 시스템 리소스 사용률
# - 애플리케이션 성능 지표
# - 에러율 및 응답 시간
```

#### Grafana (시각화 대시보드)
```bash
# 브라우저에서 접속
http://localhost:3001

# 로그인 정보:
# - 사용자명: admin
# - 비밀번호: admin

# 확인할 수 있는 것들:
# - 실시간 시스템 모니터링 차트
# - 애플리케이션 성능 그래프
# - 알림 및 경고 설정
```

### 3. 로그 확인

```bash
# 애플리케이션 로그
docker-compose logs -f app

# 모든 서비스 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### 4. 데이터베이스 확인

```bash
# PostgreSQL 연결
docker-compose exec postgres psql -U postgres -d github_actions_demo

# Redis 연결
docker-compose exec redis redis-cli
```

### 5. GitHub Actions 확인

```bash
# GitHub 저장소의 Actions 탭에서 확인
# https://github.com/your-username/github-actions-demo/actions

# 확인할 수 있는 것들:
# - CI 파이프라인 실행 상태
# - Docker 이미지 빌드 로그
# - 배포 과정 및 결과
```

### 6. 성능 테스트

```bash
# 부하 테스트 (Apache Bench 사용)
ab -n 1000 -c 10 http://localhost:3000/

# 응답 시간 측정
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/health
```

### 7. 보안 스캔 결과

```bash
# Docker 이미지 보안 스캔
docker scan github-actions-demo:latest

# 의존성 취약점 검사
npm audit
```

## 🎯 실습 완료 체크리스트

### Day 1 완료 후 확인사항
- [ ] GitHub 저장소 생성 및 연결
- [ ] Docker 이미지 수동 빌드 및 테스트
- [ ] 기본 CI 워크플로우 실행
- [ ] Docker Hub에 이미지 푸시

### Day 2 완료 후 확인사항
- [ ] 멀티스테이지 Dockerfile 빌드
- [ ] Docker Compose로 전체 스택 실행
- [ ] Prometheus 메트릭 수집 확인
- [ ] Grafana 대시보드 설정

### Day 3 완료 후 확인사항
- [ ] 고급 모니터링 설정
- [ ] 알림 시스템 구성
- [ ] 성능 최적화 적용
- [ ] 보안 스캔 통합

## 🚨 문제 해결 가이드

### 자동 문제 해결
```bash
# 모든 문제를 자동으로 해결
npm run fix:issues
```

### 일반적인 문제들

#### 1. 환경 변수 문제
```bash
# .env 파일의 Windows 줄바꿈 문자 제거
sed -i 's/\r$//' .env

# 환경 변수 재설정
npm run setup:env
```

#### 2. Docker Compose 오류
```bash
# 기존 컨테이너 정리
docker-compose down --remove-orphans
docker system prune -f

# 이미지 재빌드
docker-compose build --no-cache
docker-compose up -d
```

#### 3. 테스트 실패
```bash
# 의존성 재설치
rm -rf node_modules package-lock.json
npm install

# 테스트 실행
npm run test:unit
npm run test:integration
```

#### 4. 서비스가 시작되지 않는 경우
```bash
# 로그 확인
docker-compose logs

# 포트 충돌 확인
netstat -tulpn | grep :3000

# 컨테이너 재시작
docker-compose restart
```

#### 5. 모니터링이 작동하지 않는 경우
```bash
# Prometheus 설정 확인
docker-compose exec prometheus cat /etc/prometheus/prometheus.yml

# Grafana 데이터소스 확인
# http://localhost:3001/datasources
```

#### 6. GitHub Actions가 실패하는 경우
```bash
# Secrets 설정 확인
# GitHub 저장소 > Settings > Secrets and variables > Actions

# 워크플로우 파일 문법 검사
# .github/workflows/ 디렉토리의 YAML 파일들 확인
```

## 🔧 개발 가이드

### 코드 스타일

- **ESLint**: JavaScript 코드 품질 검사
- **Prettier**: 코드 포맷팅
- **Husky**: Git 훅을 통한 자동 검사

### 브랜치 전략

- **`main`**: 프로덕션 배포용
- **`develop`**: 개발 통합용
- **`feature/*`**: 기능 개발용
- **`hotfix/*`**: 긴급 수정용

### 커밋 메시지 규칙

```
type(scope): subject

body

footer
```

**타입**:
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅
- `refactor`: 코드 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 빌드, 설정 등

## 🛠️ 문제 해결

### 자주 발생하는 문제

1. **Docker 빌드 실패**
   ```bash
   # BuildKit 비활성화
   export DOCKER_BUILDKIT=0
   docker build -t github-actions-demo:latest .
   ```

2. **npm 설치 실패**
   ```bash
   # 캐시 정리
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **GitHub Actions 실패**
   - GitHub Secrets 설정 확인
   - 워크플로우 파일 문법 검사
   - 권한 설정 확인

## 🎓 학습 효과 및 실무 적용

### 이 프로젝트를 통해 얻을 수 있는 실무 역량

#### 1. DevOps 문화 이해
- **개발과 운영의 통합**: 개발자가 직접 배포하고 모니터링하는 환경 구축
- **자동화 마인드셋**: 반복 작업을 자동화하여 효율성 극대화
- **지속적 개선**: 모니터링 데이터를 바탕으로 한 지속적인 시스템 개선

#### 2. 현대적인 개발 워크플로우
- **Git 기반 협업**: 브랜치 전략과 코드 리뷰 프로세스
- **CI/CD 파이프라인**: 코드 품질 관리부터 배포까지의 자동화
- **인프라 코드화**: Docker와 Docker Compose를 통한 환경 관리

#### 3. 모니터링 및 관찰 가능성
- **메트릭 기반 의사결정**: 데이터를 바탕으로 한 시스템 최적화
- **장애 대응 능력**: 실시간 모니터링을 통한 빠른 문제 해결
- **성능 최적화**: 지속적인 성능 측정과 개선

### 실무에서 바로 적용 가능한 기술들

#### 🏢 스타트업 환경
- **빠른 프로토타이핑**: Docker를 활용한 빠른 개발 환경 구축
- **비용 효율적 모니터링**: Prometheus + Grafana로 저비용 모니터링 시스템 구축
- **자동화된 배포**: GitHub Actions로 소규모 팀의 배포 자동화

#### 🏭 대기업 환경
- **표준화된 개발 프로세스**: 일관된 CI/CD 파이프라인으로 개발 표준화
- **확장 가능한 아키텍처**: 마이크로서비스 환경에서의 컨테이너 활용
- **엔터프라이즈 모니터링**: 대규모 시스템의 모니터링 및 알림 체계

#### ☁️ 클라우드 환경
- **클라우드 네이티브 개발**: 컨테이너 기반의 클라우드 애플리케이션 개발
- **인프라 자동화**: Terraform, Ansible과 연계한 인프라 관리
- **멀티 클라우드 전략**: 다양한 클라우드 환경에서의 일관된 배포

### 학습 후 다음 단계

#### 🔄 고급 CI/CD
- **Blue-Green 배포**: 무중단 배포 전략
- **Canary 배포**: 점진적 배포로 위험 최소화
- **GitOps**: Git을 중심으로 한 운영 방식

#### 📊 고급 모니터링
- **ELK 스택**: 로그 수집, 분석, 시각화
- **APM (Application Performance Monitoring)**: 애플리케이션 성능 모니터링
- **분산 추적**: 마이크로서비스 환경에서의 요청 추적

#### 🏗️ 인프라 자동화
- **Kubernetes**: 컨테이너 오케스트레이션
- **Terraform**: 인프라 코드화
- **Ansible**: 설정 관리 자동화

## 📚 학습 자료

### 공식 문서
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker 공식 문서](https://docs.docker.com/)
- [Node.js 공식 문서](https://nodejs.org/docs/)
- [Prometheus 공식 문서](https://prometheus.io/docs/)

### 추가 학습 자료
- [Docker Deep Dive](https://www.docker.com/products/docker-desktop/)
- [Kubernetes 공식 튜토리얼](https://kubernetes.io/docs/tutorials/)
- [Terraform 공식 가이드](https://learn.hashicorp.com/terraform)
- [DevOps Roadmap](https://roadmap.sh/devops)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.


## 📞 지원

문제가 발생하거나 질문이 있으시면 다음을 통해 연락해주세요:

- **Issues**: [GitHub Issues](https://github.com/your-username/github-actions-demo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/github-actions-demo/discussions)

---

**Happy Coding! 🎉**
