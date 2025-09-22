#!/bin/bash
# Day3: GCP Cloud Load Balancing 설정 스크립트
# Day2의 다중 서비스 환경에 GCP 로드밸런서 추가

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 환경 변수 확인
check_env_vars() {
    log_info "환경 변수 확인 중..."
    
    required_vars=(
        "GCP_PROJECT_ID"
        "GCP_ZONE"
        "GCP_REGION"
        "INSTANCE_GROUP_NAME"
        "HEALTH_CHECK_NAME"
        "BACKEND_SERVICE_NAME"
        "URL_MAP_NAME"
        "TARGET_PROXY_NAME"
        "FORWARDING_RULE_NAME"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "필수 환경 변수 $var가 설정되지 않았습니다."
            exit 1
        fi
    done
    
    log_success "모든 환경 변수가 설정되었습니다."
}

# gcloud CLI 설치 확인
check_gcloud_cli() {
    log_info "gcloud CLI 확인 중..."
    
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI가 설치되지 않았습니다."
        log_info "다음 명령어로 설치하세요:"
        log_info "curl https://sdk.cloud.google.com | bash"
        log_info "exec -l $SHELL"
        exit 1
    fi
    
    log_success "gcloud CLI가 설치되어 있습니다."
}

# GCP 프로젝트 설정
set_gcp_project() {
    log_info "GCP 프로젝트 설정 중..."
    
    gcloud config set project $GCP_PROJECT_ID
    
    if [ $? -eq 0 ]; then
        log_success "GCP 프로젝트가 설정되었습니다: $GCP_PROJECT_ID"
    else
        log_error "GCP 프로젝트 설정에 실패했습니다."
        exit 1
    fi
}

# 인스턴스 그룹 생성
create_instance_group() {
    log_info "인스턴스 그룹 생성 중..."
    
    # 인스턴스 그룹 생성
    gcloud compute instance-groups managed create $INSTANCE_GROUP_NAME \
        --size=2 \
        --template=github-actions-demo-template \
        --zone=$GCP_ZONE
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스 그룹이 생성되었습니다: $INSTANCE_GROUP_NAME"
    else
        log_error "인스턴스 그룹 생성에 실패했습니다."
        exit 1
    fi
}

# 헬스체크 생성
create_health_check() {
    log_info "헬스체크 생성 중..."
    
    # HTTP 헬스체크 생성
    gcloud compute health-checks create http $HEALTH_CHECK_NAME \
        --port=3000 \
        --request-path=/health \
        --check-interval=30s \
        --timeout=5s \
        --healthy-threshold=2 \
        --unhealthy-threshold=3
    
    if [ $? -eq 0 ]; then
        log_success "헬스체크가 생성되었습니다: $HEALTH_CHECK_NAME"
    else
        log_error "헬스체크 생성에 실패했습니다."
        exit 1
    fi
}

# 백엔드 서비스 생성
create_backend_service() {
    log_info "백엔드 서비스 생성 중..."
    
    # 백엔드 서비스 생성
    gcloud compute backend-services create $BACKEND_SERVICE_NAME \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=$HEALTH_CHECK_NAME \
        --global
    
    if [ $? -eq 0 ]; then
        log_success "백엔드 서비스가 생성되었습니다: $BACKEND_SERVICE_NAME"
    else
        log_error "백엔드 서비스 생성에 실패했습니다."
        exit 1
    fi
    
    # 인스턴스 그룹을 백엔드 서비스에 추가
    gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
        --instance-group=$INSTANCE_GROUP_NAME \
        --instance-group-zone=$GCP_ZONE \
        --global
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스 그룹이 백엔드 서비스에 추가되었습니다."
    else
        log_error "인스턴스 그룹 추가에 실패했습니다."
        exit 1
    fi
}

# URL Map 생성
create_url_map() {
    log_info "URL Map 생성 중..."
    
    # URL Map 생성
    gcloud compute url-maps create $URL_MAP_NAME \
        --default-service=$BACKEND_SERVICE_NAME
    
    if [ $? -eq 0 ]; then
        log_success "URL Map이 생성되었습니다: $URL_MAP_NAME"
    else
        log_error "URL Map 생성에 실패했습니다."
        exit 1
    fi
}

# Target Proxy 생성
create_target_proxy() {
    log_info "Target Proxy 생성 중..."
    
    # HTTP Target Proxy 생성
    gcloud compute target-http-proxies create $TARGET_PROXY_NAME \
        --url-map=$URL_MAP_NAME
    
    if [ $? -eq 0 ]; then
        log_success "Target Proxy가 생성되었습니다: $TARGET_PROXY_NAME"
    else
        log_error "Target Proxy 생성에 실패했습니다."
        exit 1
    fi
}

# Forwarding Rule 생성
create_forwarding_rule() {
    log_info "Forwarding Rule 생성 중..."
    
    # Forwarding Rule 생성
    gcloud compute forwarding-rules create $FORWARDING_RULE_NAME \
        --global \
        --target-http-proxy=$TARGET_PROXY_NAME \
        --ports=80
    
    if [ $? -eq 0 ]; then
        log_success "Forwarding Rule이 생성되었습니다: $FORWARDING_RULE_NAME"
    else
        log_error "Forwarding Rule 생성에 실패했습니다."
        exit 1
    fi
}

# 로드밸런서 IP 주소 출력
get_lb_ip() {
    log_info "로드밸런서 IP 주소 조회 중..."
    
    LB_IP=$(gcloud compute forwarding-rules describe $FORWARDING_RULE_NAME \
        --global \
        --format="value(IPAddress)")
    
    if [ $? -eq 0 ]; then
        log_success "로드밸런서 IP 주소: $LB_IP"
        echo "LB_IP=$LB_IP" >> .env.gcp
        log_info "애플리케이션에 접속하세요: http://$LB_IP"
    else
        log_error "로드밸런서 IP 주소 조회에 실패했습니다."
        exit 1
    fi
}

# 헬스체크 확인
check_health() {
    log_info "헬스체크 확인 중..."
    
    # 백엔드 서비스 헬스체크 확인
    gcloud compute backend-services get-health $BACKEND_SERVICE_NAME \
        --global \
        --format="table(backend,status.healthStatus[0].instance,status.healthStatus[0].state)"
    
    if [ $? -eq 0 ]; then
        log_success "헬스체크가 정상입니다."
    else
        log_warning "헬스체크에 문제가 있을 수 있습니다."
    fi
}

# 메인 실행
main() {
    log_info "🚀 GCP Cloud Load Balancing 설정을 시작합니다..."
    
    check_env_vars
    check_gcloud_cli
    set_gcp_project
    
    create_instance_group
    create_health_check
    create_backend_service
    create_url_map
    create_target_proxy
    create_forwarding_rule
    get_lb_ip
    check_health
    
    log_success "✅ GCP Cloud Load Balancing 설정이 완료되었습니다!"
    log_info "다음 단계: 모니터링 스택 설정"
}

# 스크립트 실행
main "$@"
