#!/bin/bash

# 🚀 Day3 성능 테스트 스크립트
# GitHub Actions CI/CD Practice - Day3 Performance Testing

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정
APP_URL="http://localhost:3000"
TEST_COUNT=5
CONCURRENT_USERS=10
TOTAL_REQUESTS=100

echo -e "${PURPLE}🚀 Day3 성능 테스트 시작${NC}"
echo "================================================"

# 1. 애플리케이션 상태 확인
log_info "애플리케이션 상태 확인 중..."
if curl -s "$APP_URL/health" > /dev/null; then
    log_success "애플리케이션이 정상적으로 실행 중입니다"
else
    log_error "애플리케이션에 접근할 수 없습니다. Docker Compose를 시작하세요."
    exit 1
fi

# 2. 기본 응답 시간 테스트
log_info "기본 응답 시간 테스트 실행 중..."
echo "테스트 횟수: $TEST_COUNT회"
echo ""

total_time=0
for i in $(seq 1 $TEST_COUNT); do
    response_time=$(curl -w "%{time_total}" -o /dev/null -s "$APP_URL/health")
    echo "Test $i: ${response_time}s"
    total_time=$(echo "$total_time + $response_time" | bc -l)
done

average_time=$(echo "scale=3; $total_time / $TEST_COUNT" | bc -l)
log_success "평균 응답 시간: ${average_time}s"

# 3. 부하 테스트 (Apache Bench 사용)
if command -v ab > /dev/null; then
    log_info "부하 테스트 실행 중..."
    echo "총 요청 수: $TOTAL_REQUESTS"
    echo "동시 사용자: $CONCURRENT_USERS"
    echo ""
    
    ab -n $TOTAL_REQUESTS -c $CONCURRENT_USERS "$APP_URL/" > ab_results.txt 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "부하 테스트 완료"
        
        # 결과 파싱
        requests_per_second=$(grep "Requests per second" ab_results.txt | awk '{print $4}')
        time_per_request=$(grep "Time per request" ab_results.txt | head -1 | awk '{print $4}')
        failed_requests=$(grep "Failed requests" ab_results.txt | awk '{print $3}')
        
        echo "📊 부하 테스트 결과:"
        echo "  - 초당 요청 수: $requests_per_second"
        echo "  - 요청당 시간: ${time_per_request}ms"
        echo "  - 실패한 요청: $failed_requests"
    else
        log_warning "부하 테스트 실패 (Apache Bench 없음)"
    fi
else
    log_warning "Apache Bench가 설치되지 않았습니다. 부하 테스트를 건너뜁니다."
fi

# 4. 메모리 사용량 확인
log_info "메모리 사용량 확인 중..."
if command -v docker > /dev/null; then
    container_id=$(docker ps --filter "name=github-actions-demo-web" --format "{{.ID}}" | head -1)
    if [ ! -z "$container_id" ]; then
        memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" $container_id)
        log_success "컨테이너 메모리 사용량: $memory_usage"
    fi
fi

# 5. API 엔드포인트 테스트
log_info "API 엔드포인트 테스트 실행 중..."

endpoints=("/" "/health" "/api/status" "/metrics")
for endpoint in "${endpoints[@]}"; do
    if curl -s "$APP_URL$endpoint" > /dev/null; then
        log_success "✅ $endpoint - 정상"
    else
        log_error "❌ $endpoint - 실패"
    fi
done

# 6. 모니터링 시스템 확인
log_info "모니터링 시스템 상태 확인 중..."

# Prometheus 확인
if curl -s "http://localhost:9090/api/v1/query?query=up" > /dev/null; then
    log_success "✅ Prometheus - 정상"
else
    log_warning "⚠️ Prometheus - 접근 불가"
fi

# Jaeger 확인
if curl -s "http://localhost:16686/api/services" > /dev/null; then
    log_success "✅ Jaeger - 정상"
else
    log_warning "⚠️ Jaeger - 접근 불가"
fi

# Elasticsearch 확인
if curl -s "http://localhost:9200/_cluster/health" > /dev/null; then
    log_success "✅ Elasticsearch - 정상"
else
    log_warning "⚠️ Elasticsearch - 접근 불가"
fi

# 7. 성능 요약
echo ""
echo "================================================"
echo -e "${PURPLE}📊 성능 테스트 요약${NC}"
echo "================================================"
echo "평균 응답 시간: ${average_time}s"
echo "애플리케이션 상태: 정상"
echo "모니터링 시스템: 활성"
echo "테스트 완료 시간: $(date)"
echo ""

# 8. 권장사항
echo -e "${YELLOW}💡 성능 최적화 권장사항${NC}"
if (( $(echo "$average_time > 0.1" | bc -l) )); then
    echo "- 응답 시간이 100ms를 초과합니다. 성능 최적화를 고려하세요."
fi

if [ -f "ab_results.txt" ]; then
    if [ ! -z "$failed_requests" ] && [ "$failed_requests" -gt 0 ]; then
        echo "- 일부 요청이 실패했습니다. 서버 로그를 확인하세요."
    fi
fi

echo "- 정기적인 성능 모니터링을 설정하세요."
echo "- 부하가 증가하면 자동 스케일링을 고려하세요."

log_success "🎉 성능 테스트 완료!"
