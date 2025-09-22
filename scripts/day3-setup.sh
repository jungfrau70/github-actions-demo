#!/bin/bash
# Day3 - Production Level Operations Setup Script
# Cloud Master Day3 강의안 기반

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

log_header "🚀 Cloud Master Day3 - Production Level Operations Setup 시작"

# 1. 환경 변수 설정
log_info "📋 환경 변수 설정 중..."
if [ ! -f .env ]; then
    cp .env.example .env
    log_success ".env 파일 생성 완료"
else
    log_info ".env 파일이 이미 존재합니다"
fi

# Day3 프로덕션 환경 변수 추가
cat >> .env << EOF

# Day3 Production Configuration
NODE_ENV=production
DATABASE_URL=postgresql://postgres:postgres@db:5432/github_actions_demo
REDIS_URL=redis://redis:6379
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
JAEGER_ENABLED=true
ELK_ENABLED=true
LOG_LEVEL=info
METRICS_ENABLED=true
TRACING_ENABLED=true
JAEGER_ENDPOINT=http://jaeger:14268/api/traces
EOF

# 2. 의존성 설치
log_info "📦 의존성 설치 중..."
npm install

# 3. 프로덕션 의존성 설치
log_info "🔧 프로덕션 의존성 설치 중..."
npm install pg redis prom-client
npm install @opentelemetry/api @opentelemetry/sdk-trace-node @opentelemetry/resources @opentelemetry/semantic-conventions
npm install @opentelemetry/exporter-jaeger @opentelemetry/instrumentations
npm install @opentelemetry/instrumentation-express @opentelemetry/instrumentation-http
npm install @opentelemetry/instrumentation-pg @opentelemetry/instrumentation-redis

# 4. 보안 스캔 도구 설치
log_info "🔒 보안 스캔 도구 설치 중..."
if ! command -v trivy &> /dev/null; then
    log_info "Trivy 설치 중..."
    # Trivy 설치 로직 (OS별 다름)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install trivy
    else
        log_warning "Trivy 자동 설치를 지원하지 않는 OS입니다. 수동으로 설치해주세요."
    fi
else
    log_info "Trivy가 이미 설치되어 있습니다"
fi

# 5. 성능 테스트 도구 설치
log_info "⚡ 성능 테스트 도구 설치 중..."
if ! command -v artillery &> /dev/null; then
    npm install -g artillery
    log_success "Artillery 설치 완료"
else
    log_info "Artillery가 이미 설치되어 있습니다"
fi

# 6. Docker Compose 프로덕션 스택 빌드
log_info "🐳 Docker Compose 프로덕션 스택 빌드 중..."
docker-compose -f docker-compose.day3.yml build

# 7. 데이터베이스 초기화
log_info "🗄️ 데이터베이스 초기화 중..."
docker-compose -f docker-compose.day3.yml up -d db
sleep 15

# 8. 전체 프로덕션 스택 시작
log_info "🚀 전체 프로덕션 스택 시작 중..."
docker-compose -f docker-compose.day3.yml up -d

# 9. 서비스 상태 확인
log_info "🔍 서비스 상태 확인 중..."
sleep 60
docker-compose -f docker-compose.day3.yml ps

# 10. 헬스 체크
log_info "🔍 헬스 체크 중..."
services=("web" "db" "redis" "nginx" "prometheus" "grafana" "jaeger" "elasticsearch" "logstash" "kibana" "alertmanager" "node-exporter" "cadvisor")
for service in "${services[@]}"; do
    if docker-compose -f docker-compose.day3.yml ps | grep -q "$service.*Up"; then
        log_success "✅ $service 서비스가 정상적으로 실행되고 있습니다"
    else
        log_error "❌ $service 서비스 실행에 실패했습니다"
    fi
done

# 11. 애플리케이션 테스트
log_info "🧪 애플리케이션 테스트 중..."

# 기본 엔드포인트 테스트
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    log_success "✅ 애플리케이션이 정상적으로 실행되고 있습니다"
else
    log_error "❌ 애플리케이션 실행에 실패했습니다"
fi

# API 엔드포인트 테스트
if curl -f http://localhost:3000/api/info > /dev/null 2>&1; then
    log_success "✅ API 엔드포인트가 정상적으로 작동합니다"
else
    log_error "❌ API 엔드포인트 테스트에 실패했습니다"
fi

# 데이터베이스 연결 테스트
if curl -f http://localhost:3000/api/db/test > /dev/null 2>&1; then
    log_success "✅ 데이터베이스 연결이 정상입니다"
else
    log_error "❌ 데이터베이스 연결 테스트에 실패했습니다"
fi

# Redis 연결 테스트
if curl -f http://localhost:3000/api/redis/test > /dev/null 2>&1; then
    log_success "✅ Redis 연결이 정상입니다"
else
    log_error "❌ Redis 연결 테스트에 실패했습니다"
fi

# 메트릭 엔드포인트 테스트
if curl -f http://localhost:3000/metrics > /dev/null 2>&1; then
    log_success "✅ Prometheus 메트릭이 정상적으로 수집되고 있습니다"
else
    log_error "❌ Prometheus 메트릭 수집에 실패했습니다"
fi

# 12. Nginx 로드밸런서 테스트
log_info "⚖️ Nginx 로드밸런서 테스트 중..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    log_success "✅ Nginx 로드밸런서가 정상적으로 작동합니다"
else
    log_error "❌ Nginx 로드밸런서 테스트에 실패했습니다"
fi

# 13. 보안 스캔 실행
log_info "🔒 보안 스캔 실행 중..."
if command -v trivy &> /dev/null; then
    trivy fs . --format table --severity HIGH,CRITICAL
    log_success "✅ 보안 스캔 완료"
else
    log_warning "⚠️ Trivy가 설치되지 않아 보안 스캔을 건너뜁니다"
fi

# 14. 성능 테스트 실행
log_info "⚡ 성능 테스트 실행 중..."
if command -v artillery &> /dev/null; then
    artillery quick --count 100 --num 10 http://localhost:3000/health
    log_success "✅ 성능 테스트 완료"
else
    log_warning "⚠️ Artillery가 설치되지 않아 성능 테스트를 건너뜁니다"
fi

# 15. 모니터링 대시보드 확인
log_info "📊 모니터링 대시보드 확인 중..."
log_info "📈 Prometheus: http://localhost:9090"
log_info "📊 Grafana: http://localhost:3001 (admin/admin)"
log_info "🔍 Jaeger: http://localhost:16686"
log_info "📋 Kibana: http://localhost:5601"
log_info "🚨 Alertmanager: http://localhost:9093"

# 16. 로그 확인
log_info "📋 서비스 로그 확인 중..."
docker-compose -f docker-compose.day3.yml logs --tail=10

# 17. 리소스 사용량 확인
log_info "📊 리소스 사용량 확인 중..."
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

log_success "🎉 Day3 프로덕션 레벨 운영 설정 완료!"
log_info "📋 다음 단계:"
log_info "1. GitHub 저장소에 코드 푸시"
log_info "2. GitHub Actions 프로덕션 워크플로우 실행 확인"
log_info "3. AWS ECS / GCP Cloud Run 배포"
log_info "4. 로드밸런서 및 오토스케일링 설정"
log_info "5. 모니터링 및 알림 설정"
log_info "6. 보안 스캔 및 컴플라이언스 확인"
log_info "7. 비용 최적화 분석"
log_info "8. 카오스 엔지니어링 테스트"

log_info "🔗 접속 정보:"
log_info "• 애플리케이션: http://localhost:3000"
log_info "• Nginx: http://localhost"
log_info "• Prometheus: http://localhost:9090"
log_info "• Grafana: http://localhost:3001"
log_info "• Jaeger: http://localhost:16686"
log_info "• Kibana: http://localhost:5601"
log_info "• Alertmanager: http://localhost:9093"

log_info "📊 모니터링 지표:"
log_info "• CPU 사용률: node_cpu_seconds_total"
log_info "• 메모리 사용률: node_memory_MemAvailable_bytes"
log_info "• HTTP 요청 수: http_requests_total"
log_info "• 응답 시간: http_request_duration_seconds"
log_info "• 에러율: errors_total"
log_info "• 비즈니스 메트릭: business_operations_total"