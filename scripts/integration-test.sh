#!/bin/bash

# 🧪 Day3 통합 테스트 스크립트
# GitHub Actions CI/CD Practice - Day3 Integration Testing

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
PROMETHEUS_URL="http://localhost:9090"
JAEGER_URL="http://localhost:16686"
ELASTICSEARCH_URL="http://localhost:9200"

echo -e "${PURPLE}🧪 Day3 통합 테스트 시작${NC}"
echo "================================================"

# 테스트 결과 저장
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 함수
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "테스트 실행: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log_success "✅ $test_name - 통과"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "❌ $test_name - 실패"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 1. 웹 애플리케이션 테스트
echo -e "${BLUE}📱 웹 애플리케이션 테스트${NC}"
echo "----------------------------------------"

run_test "애플리케이션 실행 확인" "curl -s $APP_URL/health"
run_test "홈페이지 응답 확인" "curl -s $APP_URL/"
run_test "API 상태 확인" "curl -s $APP_URL/api/status"
run_test "메트릭 엔드포인트 확인" "curl -s $APP_URL/metrics"

# 2. 데이터베이스 연결 테스트
echo -e "${BLUE}🗄️ 데이터베이스 연결 테스트${NC}"
echo "----------------------------------------"

run_test "PostgreSQL 연결 확인" "docker exec github-actions-demo-db pg_isready -U postgres"
run_test "Redis 연결 확인" "docker exec github-actions-demo-redis redis-cli ping"

# 3. 모니터링 시스템 테스트
echo -e "${BLUE}📊 모니터링 시스템 테스트${NC}"
echo "----------------------------------------"

run_test "Prometheus 접근 확인" "curl -s $PROMETHEUS_URL/api/v1/query?query=up"
run_test "Jaeger 접근 확인" "curl -s $JAEGER_URL/api/services"
run_test "Elasticsearch 클러스터 상태 확인" "curl -s $ELASTICSEARCH_URL/_cluster/health"

# 4. 컨테이너 상태 테스트
echo -e "${BLUE}🐳 컨테이너 상태 테스트${NC}"
echo "----------------------------------------"

run_test "웹 컨테이너 실행 확인" "docker ps | grep github-actions-demo-web"
run_test "데이터베이스 컨테이너 실행 확인" "docker ps | grep github-actions-demo-db"
run_test "Redis 컨테이너 실행 확인" "docker ps | grep github-actions-demo-redis"
run_test "Prometheus 컨테이너 실행 확인" "docker ps | grep prometheus"
run_test "Jaeger 컨테이너 실행 확인" "docker ps | grep jaeger"

# 5. 네트워크 연결 테스트
echo -e "${BLUE}🌐 네트워크 연결 테스트${NC}"
echo "----------------------------------------"

run_test "포트 3000 연결 확인" "nc -z localhost 3000"
run_test "포트 5432 연결 확인" "nc -z localhost 5432"
run_test "포트 6379 연결 확인" "nc -z localhost 6379"
run_test "포트 9090 연결 확인" "nc -z localhost 9090"
run_test "포트 16686 연결 확인" "nc -z localhost 16686"

# 6. API 기능 테스트
echo -e "${BLUE}🔌 API 기능 테스트${NC}"
echo "----------------------------------------"

# 헬스 체크 상세 테스트
log_info "헬스 체크 상세 테스트"
health_response=$(curl -s $APP_URL/health)
if echo "$health_response" | grep -q "status.*OK"; then
    log_success "✅ 헬스 체크 응답 형식 확인"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    log_error "❌ 헬스 체크 응답 형식 오류"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 메트릭 형식 테스트
log_info "메트릭 형식 테스트"
metrics_response=$(curl -s $APP_URL/metrics)
if echo "$metrics_response" | grep -q "# HELP"; then
    log_success "✅ 메트릭 형식 확인"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    log_error "❌ 메트릭 형식 오류"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 7. 성능 테스트
echo -e "${BLUE}⚡ 성능 테스트${NC}"
echo "----------------------------------------"

# 응답 시간 테스트
log_info "응답 시간 테스트"
response_time=$(curl -w "%{time_total}" -o /dev/null -s $APP_URL/health)
if (( $(echo "$response_time < 1.0" | bc -l) )); then
    log_success "✅ 응답 시간 양호: ${response_time}s"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    log_warning "⚠️ 응답 시간 느림: ${response_time}s"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 8. 로그 테스트
echo -e "${BLUE}📝 로그 테스트${NC}"
echo "----------------------------------------"

# 애플리케이션 로그 확인
log_info "애플리케이션 로그 확인"
if docker logs github-actions-demo-web-2 2>&1 | grep -q "Server started"; then
    log_success "✅ 애플리케이션 시작 로그 확인"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    log_warning "⚠️ 애플리케이션 시작 로그 없음"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 9. 보안 테스트
echo -e "${BLUE}🔒 보안 테스트${NC}"
echo "----------------------------------------"

# 민감한 정보 노출 확인
log_info "민감한 정보 노출 확인"
if curl -s $APP_URL/ | grep -q -i "password\|secret\|key"; then
    log_warning "⚠️ 민감한 정보 노출 가능성"
    FAILED_TESTS=$((FAILED_TESTS + 1))
else
    log_success "✅ 민감한 정보 노출 없음"
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 10. 테스트 결과 요약
echo ""
echo "================================================"
echo -e "${PURPLE}📊 통합 테스트 결과 요약${NC}"
echo "================================================"
echo "총 테스트 수: $TOTAL_TESTS"
echo "통과한 테스트: $PASSED_TESTS"
echo "실패한 테스트: $FAILED_TESTS"

# 성공률 계산
if [ $TOTAL_TESTS -gt 0 ]; then
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "성공률: ${success_rate}%"
    
    if [ $success_rate -ge 90 ]; then
        log_success "🎉 우수한 테스트 결과입니다!"
    elif [ $success_rate -ge 70 ]; then
        log_warning "⚠️ 양호한 테스트 결과입니다. 일부 개선이 필요합니다."
    else
        log_error "❌ 테스트 결과가 좋지 않습니다. 문제를 해결해야 합니다."
    fi
fi

echo ""
echo "테스트 완료 시간: $(date)"

# 11. 권장사항
echo ""
echo -e "${YELLOW}💡 개선 권장사항${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo "- 실패한 테스트를 확인하고 수정하세요"
fi

if [ $success_rate -lt 100 ]; then
    echo "- 모든 테스트가 통과하도록 시스템을 개선하세요"
fi

echo "- 정기적인 통합 테스트를 자동화하세요"
echo "- 테스트 커버리지를 높이세요"
echo "- 성능 모니터링을 지속적으로 수행하세요"

# 종료 코드 설정
if [ $FAILED_TESTS -eq 0 ]; then
    log_success "🎉 모든 테스트가 통과했습니다!"
    exit 0
else
    log_error "❌ 일부 테스트가 실패했습니다."
    exit 1
fi
