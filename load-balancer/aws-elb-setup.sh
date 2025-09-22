#!/bin/bash
# Day3: AWS ELB 설정 스크립트
# Day2의 다중 서비스 환경에 AWS 로드밸런서 추가

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
        "AWS_REGION"
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
        "VPC_ID"
        "SUBNET_IDS"
        "SECURITY_GROUP_ID"
        "TARGET_INSTANCE_IDS"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "필수 환경 변수 $var가 설정되지 않았습니다."
            exit 1
        fi
    done
    
    log_success "모든 환경 변수가 설정되었습니다."
}

# AWS CLI 설치 확인
check_aws_cli() {
    log_info "AWS CLI 확인 중..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        log_info "다음 명령어로 설치하세요:"
        log_info "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
        log_info "unzip awscliv2.zip && sudo ./aws/install"
        exit 1
    fi
    
    log_success "AWS CLI가 설치되어 있습니다."
}

# AWS 자격 증명 확인
check_aws_credentials() {
    log_info "AWS 자격 증명 확인 중..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        log_info "다음 명령어로 설정하세요:"
        log_info "aws configure"
        exit 1
    fi
    
    log_success "AWS 자격 증명이 설정되었습니다."
}

# Application Load Balancer 생성
create_alb() {
    log_info "Application Load Balancer 생성 중..."
    
    # ALB 생성
    ALB_ARN=$(aws elbv2 create-load-balancer \
        --name github-actions-demo-alb \
        --subnets $SUBNET_IDS \
        --security-groups $SECURITY_GROUP_ID \
        --scheme internet-facing \
        --type application \
        --ip-address-type ipv4 \
        --query 'LoadBalancers[0].LoadBalancerArn' \
        --output text)
    
    if [ $? -eq 0 ]; then
        log_success "ALB가 생성되었습니다: $ALB_ARN"
        echo "ALB_ARN=$ALB_ARN" >> .env.aws
    else
        log_error "ALB 생성에 실패했습니다."
        exit 1
    fi
}

# Target Group 생성
create_target_group() {
    log_info "Target Group 생성 중..."
    
    # Target Group 생성
    TG_ARN=$(aws elbv2 create-target-group \
        --name github-actions-demo-tg \
        --protocol HTTP \
        --port 3000 \
        --vpc-id $VPC_ID \
        --target-type instance \
        --health-check-protocol HTTP \
        --health-check-path /health \
        --health-check-interval-seconds 30 \
        --health-check-timeout-seconds 5 \
        --healthy-threshold-count 2 \
        --unhealthy-threshold-count 3 \
        --query 'TargetGroups[0].TargetGroupArn' \
        --output text)
    
    if [ $? -eq 0 ]; then
        log_success "Target Group이 생성되었습니다: $TG_ARN"
        echo "TG_ARN=$TG_ARN" >> .env.aws
    else
        log_error "Target Group 생성에 실패했습니다."
        exit 1
    fi
}

# Target 등록
register_targets() {
    log_info "Target 등록 중..."
    
    # Target 등록
    aws elbv2 register-targets \
        --target-group-arn $TG_ARN \
        --targets Id=$TARGET_INSTANCE_IDS
    
    if [ $? -eq 0 ]; then
        log_success "Target이 등록되었습니다."
    else
        log_error "Target 등록에 실패했습니다."
        exit 1
    fi
}

# Listener 생성
create_listener() {
    log_info "Listener 생성 중..."
    
    # HTTP Listener 생성
    aws elbv2 create-listener \
        --load-balancer-arn $ALB_ARN \
        --protocol HTTP \
        --port 80 \
        --default-actions Type=forward,TargetGroupArn=$TG_ARN
    
    if [ $? -eq 0 ]; then
        log_success "HTTP Listener가 생성되었습니다."
    else
        log_error "HTTP Listener 생성에 실패했습니다."
        exit 1
    fi
}

# ALB DNS 이름 출력
get_alb_dns() {
    log_info "ALB DNS 이름 조회 중..."
    
    ALB_DNS=$(aws elbv2 describe-load-balancers \
        --load-balancer-arns $ALB_ARN \
        --query 'LoadBalancers[0].DNSName' \
        --output text)
    
    if [ $? -eq 0 ]; then
        log_success "ALB DNS 이름: $ALB_DNS"
        echo "ALB_DNS=$ALB_DNS" >> .env.aws
        log_info "애플리케이션에 접속하세요: http://$ALB_DNS"
    else
        log_error "ALB DNS 이름 조회에 실패했습니다."
        exit 1
    fi
}

# 헬스체크 확인
check_health() {
    log_info "헬스체크 확인 중..."
    
    # Target Group 헬스체크 확인
    aws elbv2 describe-target-health \
        --target-group-arn $TG_ARN \
        --query 'TargetHealthDescriptions[0].TargetHealth.State' \
        --output text
    
    if [ $? -eq 0 ]; then
        log_success "헬스체크가 정상입니다."
    else
        log_warning "헬스체크에 문제가 있을 수 있습니다."
    fi
}

# 메인 실행
main() {
    log_info "🚀 AWS ELB 설정을 시작합니다..."
    
    check_env_vars
    check_aws_cli
    check_aws_credentials
    
    create_alb
    create_target_group
    register_targets
    create_listener
    get_alb_dns
    check_health
    
    log_success "✅ AWS ELB 설정이 완료되었습니다!"
    log_info "다음 단계: GCP Cloud Load Balancing 설정"
}

# 스크립트 실행
main "$@"
