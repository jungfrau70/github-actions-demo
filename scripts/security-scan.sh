#!/bin/bash

# 🔒 Day3 보안 스캔 스크립트
# GitHub Actions CI/CD Practice - Day3 Security Scanning

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

echo -e "${PURPLE}🔒 Day3 보안 스캔 시작${NC}"
echo "================================================"

# 1. NPM 의존성 보안 스캔
log_info "NPM 의존성 보안 스캔 실행 중..."
if command -v npm > /dev/null; then
    npm audit --audit-level moderate > npm-audit-results.txt 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "NPM 보안 스캔 완료"
        
        # 취약점 수 확인
        vulnerabilities=$(grep -o "found [0-9]* vulnerabilities" npm-audit-results.txt | grep -o "[0-9]*")
        if [ -z "$vulnerabilities" ]; then
            vulnerabilities=0
        fi
        
        echo "📊 NPM 보안 스캔 결과:"
        echo "  - 발견된 취약점: $vulnerabilities개"
        
        if [ "$vulnerabilities" -gt 0 ]; then
            log_warning "⚠️ 취약점이 발견되었습니다. 자세한 내용은 npm-audit-results.txt를 확인하세요."
            
            # 심각도별 취약점 수 확인
            critical=$(grep -c "critical" npm-audit-results.txt || echo "0")
            high=$(grep -c "high" npm-audit-results.txt || echo "0")
            moderate=$(grep -c "moderate" npm-audit-results.txt || echo "0")
            low=$(grep -c "low" npm-audit-results.txt || echo "0")
            
            echo "  - Critical: $critical개"
            echo "  - High: $high개"
            echo "  - Moderate: $moderate개"
            echo "  - Low: $low개"
        else
            log_success "✅ 보안 취약점이 발견되지 않았습니다."
        fi
    else
        log_error "NPM 보안 스캔 실패"
    fi
else
    log_warning "NPM이 설치되지 않았습니다. NPM 보안 스캔을 건너뜁니다."
fi

# 2. Docker 이미지 보안 스캔 (Trivy 사용)
log_info "Docker 이미지 보안 스캔 실행 중..."
if command -v docker > /dev/null; then
    # Docker 이미지 확인
    if docker images | grep -q "github-actions-demo"; then
        log_info "Docker 이미지 발견, Trivy로 스캔 중..."
        
        # Trivy 설치 확인
        if command -v trivy > /dev/null; then
            trivy image github-actions-demo:latest > trivy-results.txt 2>&1
            
            if [ $? -eq 0 ]; then
                log_success "Docker 이미지 보안 스캔 완료"
                
                # 결과 파싱
                total_vulns=$(grep -o "Total: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
                critical=$(grep -o "CRITICAL: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
                high=$(grep -o "HIGH: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
                medium=$(grep -o "MEDIUM: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
                low=$(grep -o "LOW: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
                
                echo "📊 Docker 이미지 보안 스캔 결과:"
                echo "  - 총 취약점: $total_vulns개"
                echo "  - Critical: $critical개"
                echo "  - High: $high개"
                echo "  - Medium: $medium개"
                echo "  - Low: $low개"
                
                if [ "$critical" -gt 0 ] || [ "$high" -gt 0 ]; then
                    log_warning "⚠️ 심각한 보안 취약점이 발견되었습니다!"
                    echo "자세한 내용은 trivy-results.txt를 확인하세요."
                fi
            else
                log_warning "Docker 이미지 보안 스캔 실패"
            fi
        else
            log_warning "Trivy가 설치되지 않았습니다. Docker 이미지 보안 스캔을 건너뜁니다."
            echo "Trivy 설치 방법:"
            echo "  - macOS: brew install trivy"
            echo "  - Linux: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
        fi
    else
        log_warning "github-actions-demo Docker 이미지를 찾을 수 없습니다."
        echo "먼저 Docker 이미지를 빌드하세요: docker build -t github-actions-demo:latest ."
    fi
else
    log_warning "Docker가 설치되지 않았습니다. Docker 이미지 보안 스캔을 건너뜁니다."
fi

# 3. 코드 품질 스캔 (ESLint 사용)
log_info "코드 품질 스캔 실행 중..."
if command -v npm > /dev/null && [ -f "package.json" ]; then
    if npm list eslint > /dev/null 2>&1; then
        npm run lint > eslint-results.txt 2>&1
        
        if [ $? -eq 0 ]; then
            log_success "코드 품질 스캔 완료 - 문제 없음"
        else
            log_warning "코드 품질 문제가 발견되었습니다."
            echo "자세한 내용은 eslint-results.txt를 확인하세요."
        fi
    else
        log_warning "ESLint가 설치되지 않았습니다. 코드 품질 스캔을 건너뜁니다."
    fi
else
    log_warning "NPM 또는 package.json이 없습니다. 코드 품질 스캔을 건너뜁니다."
fi

# 4. 보안 헤더 확인
log_info "보안 헤더 확인 중..."
if command -v curl > /dev/null; then
    # 애플리케이션이 실행 중인지 확인
    if curl -s "http://localhost:3000/health" > /dev/null; then
        log_info "애플리케이션 응답 헤더 확인 중..."
        
        # 보안 헤더 확인
        headers=$(curl -I -s "http://localhost:3000/")
        
        security_headers=(
            "X-Content-Type-Options"
            "X-Frame-Options"
            "X-XSS-Protection"
            "Strict-Transport-Security"
            "Content-Security-Policy"
        )
        
        echo "📊 보안 헤더 확인 결과:"
        for header in "${security_headers[@]}"; do
            if echo "$headers" | grep -qi "$header"; then
                log_success "✅ $header - 설정됨"
            else
                log_warning "⚠️ $header - 설정되지 않음"
            fi
        done
    else
        log_warning "애플리케이션이 실행되지 않았습니다. 보안 헤더 확인을 건너뜁니다."
    fi
else
    log_warning "curl이 설치되지 않았습니다. 보안 헤더 확인을 건너뜁니다."
fi

# 5. 포트 스캔 (netstat 사용)
log_info "포트 스캔 실행 중..."
if command -v netstat > /dev/null; then
    echo "📊 열린 포트 확인:"
    netstat -tuln | grep LISTEN | while read line; do
        port=$(echo $line | awk '{print $4}' | cut -d: -f2)
        if [ ! -z "$port" ]; then
            echo "  - 포트 $port: 열림"
        fi
    done
else
    log_warning "netstat이 설치되지 않았습니다. 포트 스캔을 건너뜁니다."
fi

# 6. 보안 스캔 요약
echo ""
echo "================================================"
echo -e "${PURPLE}🔒 보안 스캔 요약${NC}"
echo "================================================"

# NPM 취약점 요약
if [ -f "npm-audit-results.txt" ]; then
    npm_vulns=$(grep -o "found [0-9]* vulnerabilities" npm-audit-results.txt | grep -o "[0-9]*" || echo "0")
    echo "NPM 취약점: $npm_vulns개"
fi

# Docker 취약점 요약
if [ -f "trivy-results.txt" ]; then
    docker_vulns=$(grep -o "Total: [0-9]*" trivy-results.txt | grep -o "[0-9]*" || echo "0")
    echo "Docker 취약점: $docker_vulns개"
fi

echo "스캔 완료 시간: $(date)"
echo ""

# 7. 보안 권장사항
echo -e "${YELLOW}💡 보안 개선 권장사항${NC}"

if [ -f "npm-audit-results.txt" ] && [ "$npm_vulns" -gt 0 ]; then
    echo "- NPM 취약점을 수정하세요: npm audit fix"
fi

if [ -f "trivy-results.txt" ] && [ "$docker_vulns" -gt 0 ]; then
    echo "- Docker 이미지의 취약점을 수정하세요"
    echo "- 베이스 이미지를 최신 버전으로 업데이트하세요"
fi

echo "- 정기적인 보안 스캔을 자동화하세요"
echo "- 의존성을 정기적으로 업데이트하세요"
echo "- 보안 헤더를 추가하세요"
echo "- HTTPS를 사용하세요"
echo "- 민감한 정보를 환경 변수로 관리하세요"

log_success "🎉 보안 스캔 완료!"
