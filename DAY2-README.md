# 🚀 Day2: 고급 CI/CD & VM 기반 컨테이너 배포 완성

## 📋 Day2 학습 목표 달성 현황

### ✅ 완료된 기능
- [x] **Docker Compose**: 다중 서비스 관리 (App, DB, Redis, Nginx)
- [x] **고급 GitHub Actions**: 멀티 환경 배포, 매트릭스 빌드
- [x] **데이터베이스 연동**: PostgreSQL 데이터베이스 통합
- [x] **캐시 시스템**: Redis 캐시 서비스 추가
- [x] **로드밸런싱**: Nginx를 활용한 트래픽 분산
- [x] **고가용성**: 헬스체크, 자동 재시작, 롤링 업데이트

### 🎯 Day2 핵심 성과
- **Day1 기반 발전**: 기본 배포를 고급 다중 서비스 환경으로 발전
- **실제 운영 환경**: 프로덕션 수준의 아키텍처 구축
- **자동화 강화**: 멀티 환경 배포 파이프라인 구축

## 📁 Day2 프로젝트 구조

```
github-actions-demo/
├── .github/workflows/
│   ├── ci.yml                    # Day1: 기본 CI
│   ├── docker-build.yml          # Day1: Docker 빌드
│   ├── deploy-vm.yml             # Day1: VM 배포
│   └── advanced-cicd.yml         # Day2: 고급 CI/CD (NEW!)
├── database/
│   └── init.sql                  # Day2: 데이터베이스 초기화 (NEW!)
├── nginx/
│   └── nginx.conf                # Day2: 로드밸런서 설정 (NEW!)
├── src/
│   └── app.js                    # Day1: Node.js 애플리케이션
├── docker-compose.yml            # Day1: 기본 개발 환경
├── docker-compose.prod.yml       # Day2: 프로덕션 환경 (NEW!)
├── Dockerfile                    # Day1: 멀티스테이지 빌드
├── package.json                  # Day1: Node.js 의존성
├── env.prod.example              # Day2: 프로덕션 환경 변수 (NEW!)
└── README.md                     # 프로젝트 설명
```

## 🔧 Day2 핵심 기능

### 1. Docker Compose 다중 서비스 관리
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    build: .
    ports: ["3000:3000"]
    depends_on: [postgres, redis]
    restart: unless-stopped
    
  postgres:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=myapp_user
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:6-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    
  nginx:
    image: nginx:alpine
    ports: ["80:80"]
    depends_on: [app]
```

### 2. 고급 GitHub Actions CI/CD
```yaml
# .github/workflows/advanced-cicd.yml
name: Advanced CI/CD Pipeline
on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main, develop ]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
    - name: 코드 품질 검사
      run: npm run lint
      
  test:
    strategy:
      matrix:
        node-version: [16, 18, 20]
        environment: [staging, production]
        
  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
  deploy-production:
    if: github.ref == 'refs/heads/main'
    environment: production
```

### 3. 데이터베이스 연동
```sql
-- database/init.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. Nginx 로드밸런싱
```nginx
# nginx/nginx.conf
upstream app_servers {
    server app:3000;
}

server {
    listen 80;
    location / {
        proxy_pass http://app_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🎉 Day2 성공 지표

- ✅ **서비스 통합**: 4개 서비스 (App, DB, Redis, Nginx) 성공적 통합
- ✅ **자동화 강화**: 멀티 환경 배포 파이프라인 구축
- ✅ **고가용성**: 헬스체크, 자동 재시작, 롤링 업데이트
- ✅ **성능 향상**: 로드밸런싱, 캐싱, 데이터베이스 최적화

## 🔄 Day3로의 발전 방향

Day2에서 구축한 다중 서비스 환경을 바탕으로 Day3에서는:
- 모니터링 스택 구축 (Prometheus, Grafana)
- 로드밸런싱 고도화 (AWS ELB, GCP Cloud Load Balancing)
- 오토스케일링 설정
- 비용 최적화 전략

## 🚀 Day2 실행 방법

### 1. 환경 변수 설정
```bash
# 프로덕션 환경 변수 복사
cp env.prod.example .env.prod

# 환경 변수 편집
nano .env.prod
```

### 2. 프로덕션 환경 실행
```bash
# 프로덕션 환경 배포
docker-compose -f docker-compose.prod.yml up -d

# 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f
```

### 3. 헬스체크 확인
```bash
# 애플리케이션 헬스체크
curl http://localhost/health

# 데이터베이스 헬스체크
curl http://localhost/api/health/db

# Redis 헬스체크
curl http://localhost/api/health/redis
```

---

**Day2 완성일**: 2024년 9월 23일  
**다음 단계**: Day3 - 로드밸런싱 & 모니터링 & 비용 최적화
