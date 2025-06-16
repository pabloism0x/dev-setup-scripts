#!/bin/bash

# 개발 환경 전체 설치 스크립트
# 작성자: pabloism0x
# 용도: 현대적인 개발 및 클라우드 엔지니어링 환경 구축

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 배너 출력
print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 개발 환경 자동 설치 스크립트 🚀                    ║
║                                                              ║
║     현대적인 개발 및 클라우드 엔지니어링 환경을 구축하세요   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 설치 옵션 선택
show_installation_menu() {
    echo ""
    echo "설치할 구성을 선택하세요:"
    echo ""
    echo "1. 🌐 프론트엔드 개발자"
    echo "   - 기본 도구 + Node.js + Docker"
    echo ""
    echo "2. 🖥️  백엔드 개발자"
    echo "   - 기본 도구 + Python + Go + Docker + AWS CLI"
    echo ""
    echo "3. 🌐 풀스택 웹 개발자 (추천)"
    echo "   - 기본 도구 + 보안 + Node.js + Python + Docker + Kubernetes"
    echo ""
    echo "4. ☁️  클라우드/인프라 엔지니어"
    echo "   - 기본 도구 + 보안 + Go + Rust + Docker + 모든 클라우드 도구"
    echo ""
    echo "5. 🛠️  전체 설치 (모든 도구)"
    echo "   - 모든 스크립트 실행 (가장 완전한 환경)"
    echo ""
    echo "6. 🎯 커스텀 설치"
    echo "   - 개별 스크립트 선택 실행"
    echo ""
    echo "7. ❌ 종료"
    echo ""
}

# 개별 스크립트 실행 함수
run_script() {
    local script_path="$1"
    local script_name="$2"
    
    if [ -f "$script_path" ]; then
        log_step "$script_name 설치 중..."
        chmod +x "$script_path"
        
        if "$script_path"; then
            log_success "$script_name 설치 완료!"
        else
            log_error "$script_name 설치 실패!"
            return 1
        fi
    else
        log_error "$script_path 파일을 찾을 수 없습니다!"
        return 1
    fi
    
    echo ""
}

# 프론트엔드 개발자 설치
install_frontend_dev() {
    log_info "프론트엔드 개발 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    
    log_success "프론트엔드 개발 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 프로젝트를 시작할 수 있습니다:"
    echo "  nodeinit my-react-app    # React 프로젝트"
    echo "  nodeinit my-vue-app      # Vue 프로젝트"
    echo "  dcinit my-frontend       # Docker Compose 환경"
}

# 백엔드 개발자 설치
install_backend_dev() {
    log_info "백엔드 개발 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "framework/setup-python.sh" "Python 개발 환경"
    run_script "framework/setup-golang.sh" "Go 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    
    log_success "백엔드 개발 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 프로젝트를 시작할 수 있습니다:"
    echo "  pyinit my-api           # FastAPI/Django 프로젝트"
    echo "  goinit my-service       # Go 마이크로서비스"
    echo "  awsinit my-lambda       # AWS Lambda 프로젝트"
}

# 풀스택 웹 개발자 설치
install_fullstack_dev() {
    log_info "풀스택 웹 개발 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "framework/setup-python.sh" "Python 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "풀스택 웹 개발 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 프로젝트를 시작할 수 있습니다:"
    echo "  nodeinit my-frontend    # React/Vue 프론트엔드"
    echo "  pyinit my-backend       # FastAPI/Django 백엔드"
    echo "  dcinit my-app           # Docker Compose 프로젝트"
}

# 클라우드/인프라 엔지니어 설치
install_cloud_engineer() {
    log_info "클라우드/인프라 엔지니어 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    run_script "framework/setup-golang.sh" "Go 개발 환경"
    run_script "framework/setup-rust.sh" "Rust 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    run_script "cloud/setup-gcp-cli.sh" "Google Cloud CLI 도구"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "클라우드/인프라 엔지니어 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 인프라 프로젝트를 시작할 수 있습니다:"
    echo "  awsinit my-cdk-project cdk      # AWS CDK 프로젝트"
    echo "  gcinit my-gcp-project app-engine # GCP 프로젝트"
    echo "  goinit my-k8s-operator          # Kubernetes Operator"
}

# 전체 설치
install_everything() {
    log_info "전체 개발 환경 설치를 시작합니다... (시간이 오래 걸릴 수 있습니다)"
    echo ""
    
    # 시스템 도구
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    
    # 프로그래밍 언어
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "framework/setup-python.sh" "Python 개발 환경"
    run_script "framework/setup-golang.sh" "Go 개발 환경"
    run_script "framework/setup-rust.sh" "Rust 개발 환경"
    
    # 컨테이너
    run_script "linux/setup-podman.sh" "Podman 컨테이너 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    
    # 클라우드 도구
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    run_script "cloud/setup-gcp-cli.sh" "Google Cloud CLI 도구"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "전체 개발 환경 설치 완료! 🎉"
    echo ""
    echo "이제 모든 개발 도구를 사용할 수 있습니다!"
}

# 커스텀 설치
install_custom() {
    echo ""
    echo "설치할 스크립트를 선택하세요 (여러 개 선택 가능, 스페이스로 구분):"
    echo ""
    echo "시스템 도구:"
    echo "  1) linux/setup-basic.sh     - 기본 시스템 도구"
    echo "  2) linux/setup-security.sh  - 보안 강화 설정"
    echo ""
    echo "프로그래밍 언어:"
    echo "  3) framework/setup-nodejs.sh - Node.js 개발 환경"
    echo "  4) framework/setup-python.sh - Python 개발 환경"
    echo "  5) framework/setup-golang.sh - Go 개발 환경"
    echo "  6) framework/setup-rust.sh   - Rust 개발 환경"
    echo ""
    echo "컨테이너:"
    echo "  7) linux/setup-podman.sh    - Podman 컨테이너"
    echo "  8) linux/setup-docker.sh    - Docker 컨테이너"
    echo ""
    echo "클라우드 도구:"
    echo "  9) cloud/setup-aws-cli.sh   - AWS CLI 도구"
    echo " 10) cloud/setup-gcp-cli.sh   - Google Cloud CLI 도구"
    echo " 11) cloud/setup-kubectl.sh   - Kubernetes 도구"
    echo ""
    echo -n "선택 (예: 1 3 7 9): "
    read -r selections
    
    declare -A script_map=(
        [1]="linux/setup-basic.sh|기본 시스템 도구"
        [2]="linux/setup-security.sh|보안 강화 설정"
        [3]="framework/setup-nodejs.sh|Node.js 개발 환경"
        [4]="framework/setup-python.sh|Python 개발 환경"
        [5]="framework/setup-golang.sh|Go 개발 환경"
        [6]="framework/setup-rust.sh|Rust 개발 환경"
        [7]="linux/setup-podman.sh|Podman 컨테이너 환경"
        [8]="linux/setup-docker.sh|Docker 컨테이너 환경"
        [9]="cloud/setup-aws-cli.sh|AWS CLI 도구"
        [10]="cloud/setup-gcp-cli.sh|Google Cloud CLI 도구"
        [11]="cloud/setup-kubectl.sh|Kubernetes 도구"
    )
    
    if [ -z "$selections" ]; then
        log_warning "선택된 스크립트가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "선택된 스크립트들을 설치합니다..."
    echo ""
    
    for selection in $selections; do
        if [[ -n "${script_map[$selection]}" ]]; then
            IFS='|' read -r script_path script_name <<< "${script_map[$selection]}"
            run_script "$script_path" "$script_name"
        else
            log_warning "잘못된 선택: $selection"
        fi
    done
    
    log_success "선택된 스크립트 설치 완료! 🎉"
}

# 설치 완료 후 안내 메시지
show_completion_message() {
    echo ""
    echo -e "${GREEN}========================================"
    echo "   🎉 설치 완료! 🎉"
    echo "========================================"
    echo -e "${NC}"
    echo "다음 단계를 수행하세요:"
    echo ""
    echo "1. 환경 변수 적용:"
    echo "   source ~/.bashrc"
    echo "   (또는 터미널을 재시작하세요)"
    echo ""
    echo "2. Docker 권한 적용 (Docker 설치한 경우):"
    echo "   newgrp docker"
    echo "   (또는 재로그인하세요)"
    echo ""
    echo "3. 설치 확인:"
    echo "   sysinfo          # 시스템 정보 확인"
    echo "   nodeinfo         # Node.js 정보 (설치한 경우)"
    echo "   pyinfo           # Python 정보 (설치한 경우)"
    echo "   goinfo           # Go 정보 (설치한 경우)"
    echo "   dinfo            # Docker 정보 (설치한 경우)"
    echo ""
    echo "4. 보안 상태 확인 (보안 설정한 경우):"
    echo "   seccheck         # 보안 상태 확인"
    echo ""
    echo "🔗 유용한 링크:"
    echo "   - 프로젝트 문서: https://github.com/yourusername/dev-setup-scripts"
    echo "   - 이슈 리포트: https://github.com/yourusername/dev-setup-scripts/issues"
    echo ""
    echo "❓ 문제가 발생했나요?"
    echo "   GitHub Issues에서 도움을 요청하세요!"
    echo ""
}

# 메인 함수
main() {
    # 루트 권한 체크
    if [ "$EUID" -eq 0 ]; then
        log_error "이 스크립트를 root 권한으로 실행하지 마세요!"
        log_info "일반 사용자로 실행하면 필요한 부분에서만 sudo를 요청합니다."
        exit 1
    fi
    
    # sudo 권한 확인
    if ! sudo -v; then
        log_error "sudo 권한이 필요합니다. 관리자에게 문의하세요."
        exit 1
    fi
    
    # 배너 출력
    print_banner
    
    # 시스템 정보 출력
    echo "현재 시스템 정보:"
    echo "  - OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  - 아키텍처: $(uname -m)"
    echo "  - 사용자: $(whoami)"
    echo ""
    
    # 메뉴 반복
    while true; do
        show_installation_menu
        echo -n "선택하세요 (1-7): "
        read -r choice
        
        case $choice in
            1)
                install_frontend_dev
                show_completion_message
                break
                ;;
            2)
                install_backend_dev
                show_completion_message
                break
                ;;
            3)
                install_fullstack_dev
                show_completion_message
                break
                ;;
            4)
                install_cloud_engineer
                show_completion_message
                break
                ;;
            5)
                echo ""
                log_warning "전체 설치는 시간이 오래 걸릴 수 있습니다. 계속하시겠습니까? (y/N)"
                read -r confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    install_everything
                    show_completion_message
                    break
                else
                    echo "설치가 취소되었습니다."
                fi
                ;;
            6)
                install_custom
                show_completion_message
                break
                ;;
            7)
                echo "설치를 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                echo ""
                ;;
        esac
    done
}

# 스크립트 시작
main "$@"#!/bin/bash

# 개발 환경 전체 설치 스크립트
# 작성자: pabloism0x
# 용도: Discord Bot 개발부터 클라우드 배포까지 전체 환경 구축

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 배너 출력
print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 개발 환경 자동 설치 스크립트 🚀                    ║
║                                                              ║
║   Discord Bot 개발부터 클라우드 배포까지 모든 환경을 구축   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 설치 옵션 선택
show_installation_menu() {
    echo ""
    echo "설치할 구성을 선택하세요:"
    echo ""
    echo "1. 💻 Discord Bot 개발자 (추천)"
    echo "   - 기본 도구 + Node.js + Podman + AWS CLI"
    echo ""
    echo "2. 🌐 풀스택 웹 개발자"
    echo "   - 기본 도구 + 보안 + Node.js + Python + Docker + Kubernetes"
    echo ""
    echo "3. ☁️  클라우드 엔지니어"
    echo "   - 기본 도구 + 보안 + Go + Rust + Docker + 모든 클라우드 도구"
    echo ""
    echo "4. 🛠️  전체 설치 (모든 도구)"
    echo "   - 모든 스크립트 실행 (가장 완전한 환경)"
    echo ""
    echo "5. 🎯 커스텀 설치"
    echo "   - 개별 스크립트 선택 실행"
    echo ""
    echo "6. ❌ 종료"
    echo ""
}

# 개별 스크립트 실행 함수
run_script() {
    local script_path="$1"
    local script_name="$2"
    
    if [ -f "$script_path" ]; then
        log_step "$script_name 설치 중..."
        chmod +x "$script_path"
        
        if "$script_path"; then
            log_success "$script_name 설치 완료!"
        else
            log_error "$script_name 설치 실패!"
            return 1
        fi
    else
        log_error "$script_path 파일을 찾을 수 없습니다!"
        return 1
    fi
    
    echo ""
}

# Discord Bot 개발자 설치
install_discord_dev() {
    log_info "Discord Bot 개발 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "linux/setup-podman.sh" "Podman 컨테이너 환경"
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    
    log_success "Discord Bot 개발 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 Discord Bot 프로젝트를 시작할 수 있습니다:"
    echo "  nodeinit my-discord-bot"
    echo "  cd ~/workspace/nodejs/my-discord-bot"
    echo "  npm install discord.js"
}

# 풀스택 웹 개발자 설치
install_fullstack_dev() {
    log_info "풀스택 웹 개발 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "framework/setup-python.sh" "Python 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "풀스택 웹 개발 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 프로젝트를 시작할 수 있습니다:"
    echo "  nodeinit my-frontend    # React/Vue 프론트엔드"
    echo "  pyinit my-backend       # FastAPI/Django 백엔드"
    echo "  dcinit my-app           # Docker Compose 프로젝트"
}

# 클라우드 엔지니어 설치
install_cloud_engineer() {
    log_info "클라우드 엔지니어 환경 설치를 시작합니다..."
    echo ""
    
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    run_script "framework/setup-golang.sh" "Go 개발 환경"
    run_script "framework/setup-rust.sh" "Rust 개발 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    run_script "cloud/setup-gcp-cli.sh" "Google Cloud CLI 도구"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "클라우드 엔지니어 환경 설치 완료! 🎉"
    echo ""
    echo "다음 명령어로 인프라 프로젝트를 시작할 수 있습니다:"
    echo "  awsinit my-cdk-project cdk      # AWS CDK 프로젝트"
    echo "  gcinit my-gcp-project app-engine # GCP 프로젝트"
    echo "  goinit my-k8s-operator          # Kubernetes Operator"
}

# 전체 설치
install_everything() {
    log_info "전체 개발 환경 설치를 시작합니다... (시간이 오래 걸릴 수 있습니다)"
    echo ""
    
    # 시스템 도구
    run_script "linux/setup-basic.sh" "기본 시스템 도구"
    run_script "linux/setup-security.sh" "보안 강화 설정"
    
    # 프로그래밍 언어
    run_script "framework/setup-nodejs.sh" "Node.js 개발 환경"
    run_script "framework/setup-python.sh" "Python 개발 환경"
    run_script "framework/setup-golang.sh" "Go 개발 환경"
    run_script "framework/setup-rust.sh" "Rust 개발 환경"
    
    # 컨테이너
    run_script "linux/setup-podman.sh" "Podman 컨테이너 환경"
    run_script "linux/setup-docker.sh" "Docker 컨테이너 환경"
    
    # 클라우드 도구
    run_script "cloud/setup-aws-cli.sh" "AWS CLI 도구"
    run_script "cloud/setup-gcp-cli.sh" "Google Cloud CLI 도구"
    run_script "cloud/setup-kubectl.sh" "Kubernetes 도구"
    
    log_success "전체 개발 환경 설치 완료! 🎉"
    echo ""
    echo "이제 모든 개발 도구를 사용할 수 있습니다!"
}

# 커스텀 설치
install_custom() {
    echo ""
    echo "설치할 스크립트를 선택하세요 (여러 개 선택 가능, 스페이스로 구분):"
    echo ""
    echo "시스템 도구:"
    echo "  1) linux/setup-basic.sh     - 기본 시스템 도구"
    echo "  2) linux/setup-security.sh  - 보안 강화 설정"
    echo ""
    echo "프로그래밍 언어:"
    echo "  3) framework/setup-nodejs.sh - Node.js 개발 환경"
    echo "  4) framework/setup-python.sh - Python 개발 환경"
    echo "  5) framework/setup-golang.sh - Go 개발 환경"
    echo "  6) framework/setup-rust.sh   - Rust 개발 환경"
    echo ""
    echo "컨테이너:"
    echo "  7) linux/setup-podman.sh    - Podman 컨테이너"
    echo "  8) linux/setup-docker.sh    - Docker 컨테이너"
    echo ""
    echo "클라우드 도구:"
    echo "  9) cloud/setup-aws-cli.sh   - AWS CLI 도구"
    echo " 10) cloud/setup-gcp-cli.sh   - Google Cloud CLI 도구"
    echo " 11) cloud/setup-kubectl.sh   - Kubernetes 도구"
    echo ""
    echo -n "선택 (예: 1 3 7 9): "
    read -r selections
    
    declare -A script_map=(
        [1]="linux/setup-basic.sh|기본 시스템 도구"
        [2]="linux/setup-security.sh|보안 강화 설정"
        [3]="framework/setup-nodejs.sh|Node.js 개발 환경"
        [4]="framework/setup-python.sh|Python 개발 환경"
        [5]="framework/setup-golang.sh|Go 개발 환경"
        [6]="framework/setup-rust.sh|Rust 개발 환경"
        [7]="linux/setup-podman.sh|Podman 컨테이너 환경"
        [8]="linux/setup-docker.sh|Docker 컨테이너 환경"
        [9]="cloud/setup-aws-cli.sh|AWS CLI 도구"
        [10]="cloud/setup-gcp-cli.sh|Google Cloud CLI 도구"
        [11]="cloud/setup-kubectl.sh|Kubernetes 도구"
    )
    
    if [ -z "$selections" ]; then
        log_warning "선택된 스크립트가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "선택된 스크립트들을 설치합니다..."
    echo ""
    
    for selection in $selections; do
        if [[ -n "${script_map[$selection]}" ]]; then
            IFS='|' read -r script_path script_name <<< "${script_map[$selection]}"
            run_script "$script_path" "$script_name"
        else
            log_warning "잘못된 선택: $selection"
        fi
    done
    
    log_success "선택된 스크립트 설치 완료! 🎉"
}

# 설치 완료 후 안내 메시지
show_completion_message() {
    echo ""
    echo -e "${GREEN}========================================"
    echo "   🎉 설치 완료! 🎉"
    echo "========================================"
    echo -e "${NC}"
    echo "다음 단계를 수행하세요:"
    echo ""
    echo "1. 환경 변수 적용:"
    echo "   source ~/.bashrc"
    echo "   (또는 터미널을 재시작하세요)"
    echo ""
    echo "2. Docker 권한 적용 (Docker 설치한 경우):"
    echo "   newgrp docker"
    echo "   (또는 재로그인하세요)"
    echo ""
    echo "3. 설치 확인:"
    echo "   sysinfo          # 시스템 정보 확인"
    echo "   nodeinfo         # Node.js 정보 (설치한 경우)"
    echo "   pyinfo           # Python 정보 (설치한 경우)"
    echo "   goinfo           # Go 정보 (설치한 경우)"
    echo "   dinfo            # Docker 정보 (설치한 경우)"
    echo ""
    echo "4. 보안 상태 확인 (보안 설정한 경우):"
    echo "   seccheck         # 보안 상태 확인"
    echo ""
    echo "🔗 유용한 링크:"
    echo "   - 프로젝트 문서: https://github.com/yourusername/dev-setup-scripts"
    echo "   - 이슈 리포트: https://github.com/yourusername/dev-setup-scripts/issues"
    echo ""
    echo "❓ 문제가 발생했나요?"
    echo "   GitHub Issues에서 도움을 요청하세요!"
    echo ""
}

# 메인 함수
main() {
    # 루트 권한 체크
    if [ "$EUID" -eq 0 ]; then
        log_error "이 스크립트를 root 권한으로 실행하지 마세요!"
        log_info "일반 사용자로 실행하면 필요한 부분에서만 sudo를 요청합니다."
        exit 1
    fi
    
    # sudo 권한 확인
    if ! sudo -v; then
        log_error "sudo 권한이 필요합니다. 관리자에게 문의하세요."
        exit 1
    fi
    
    # 배너 출력
    print_banner
    
    # 시스템 정보 출력
    echo "현재 시스템 정보:"
    echo "  - OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  - 아키텍처: $(uname -m)"
    echo "  - 사용자: $(whoami)"
    echo ""
    
    # 메뉴 반복
    while true; do
        show_installation_menu
        echo -n "선택하세요 (1-7): "
        read -r choice
        
        case $choice in
            1)
                install_frontend_dev
                show_completion_message
                break
                ;;
            2)
                install_backend_dev
                show_completion_message
                break
                ;;
            3)
                install_fullstack_dev
                show_completion_message
                break
                ;;
            4)
                install_cloud_engineer
                show_completion_message
                break
                ;;
            5)
                echo ""
                log_warning "전체 설치는 시간이 오래 걸릴 수 있습니다. 계속하시겠습니까? (y/N)"
                read -r confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    install_everything
                    show_completion_message
                    break
                else
                    echo "설치가 취소되었습니다."
                fi
                ;;
            6)
                install_custom
                show_completion_message
                break
                ;;
            7)
                echo "설치를 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                echo ""
                ;;
        esac
    done
}

# 스크립트 시작
main "$@"