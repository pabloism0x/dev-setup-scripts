#!/bin/bash

# Podman 컨테이너 환경 설치 스크립트
# 작성자: pabloism0x
# 용도: Discord Bot 컨테이너화를 위한 Podman 환경 구성

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 시작 메시지
echo "========================================"
echo "  Podman 컨테이너 환경 설치 스크립트"
echo "========================================"
echo ""

# 운영체제 및 패키지 매니저 감지
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS=RedHat
        VER=$(cat /etc/redhat-release)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

# Podman 설치 함수
install_podman() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian - 버전별 패키지 차이 고려
        log_info "Podman 관련 패키지 설치 중..."
        
        # Ubuntu 22.04 이상에서는 containers-common 대신 다른 패키지들 사용
        if [[ "$OS" == *"Ubuntu"* ]] && [[ "$VER" == "22.04" ]] || [[ "$VER" > "22.04" ]]; then
            sudo apt install -y podman buildah skopeo crun conmon containernetworking-plugins
        else
            # 이전 버전이나 Debian은 기존 방식
            sudo apt install -y podman buildah skopeo crun conmon containers-common 2>/dev/null || \
            sudo apt install -y podman buildah skopeo crun conmon
        fi
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "Podman 관련 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y podman buildah skopeo crun conmon container-tools
        else
            sudo yum install -y podman buildah skopeo crun conmon container-tools
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "Podman 관련 패키지 설치 중..."
        sudo dnf install -y podman buildah skopeo crun conmon container-tools
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "Podman 관련 패키지 설치 중..."
        sudo zypper install -y podman buildah skopeo crun conmon
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "Podman 관련 패키지 설치 중..."
        sudo pacman -S --noconfirm podman buildah skopeo crun conmon
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "Podman 관련 패키지 설치 중..."
        sudo apk add podman buildah skopeo crun
        
    else
        log_error "지원하지 않는 운영체제입니다: $OS"
        log_info "수동으로 Podman을 설치해주세요: https://podman.io/getting-started/installation"
        exit 1
    fi
}

# 패키지 목록 업데이트
log_info "패키지 목록 업데이트 중..."
if command -v apt >/dev/null 2>&1; then
    sudo apt update
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf check-update || true
elif command -v yum >/dev/null 2>&1; then
    sudo yum check-update || true
elif command -v zypper >/dev/null 2>&1; then
    sudo zypper refresh
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy
elif command -v apk >/dev/null 2>&1; then
    sudo apk update
fi

# Podman 설치
install_podman

# Podman 버전 확인
PODMAN_VERSION=$(podman --version)
log_success "Podman 설치 완료: $PODMAN_VERSION"

# 사용자 네임스페이스 설정
log_info "사용자 네임스페이스 설정 중..."
if ! grep -q "^$USER:" /etc/subuid; then
    echo "$USER:100000:65536" | sudo tee -a /etc/subuid
fi

if ! grep -q "^$USER:" /etc/subgid; then
    echo "$USER:100000:65536" | sudo tee -a /etc/subgid
fi

# Podman 설정 디렉토리 생성
log_info "Podman 설정 디렉토리 생성 중..."
mkdir -p ~/.config/containers
mkdir -p ~/.local/share/containers
mkdir -p ~/containers

# containers.conf 설정 파일 생성 (Ubuntu 22.04 호환)
log_info "Podman 설정 파일 생성 중..."
cat > ~/.config/containers/containers.conf << 'CONTAINERS_EOF'
[containers]
log_driver = "journald"

[engine]
cgroup_manager = "systemd"
events_logger = "journald"
CONTAINERS_EOF

# registries.conf 설정 파일 생성
log_info "레지스트리 설정 파일 생성 중..."
cat > ~/.config/containers/registries.conf << 'REGISTRIES_EOF'
[registries.search]
registries = ['docker.io', 'quay.io', 'registry.fedoraproject.org']

[registries.insecure]
registries = []

[registries.block]
registries = []
REGISTRIES_EOF

# storage.conf 설정 파일 생성
log_info "스토리지 설정 파일 생성 중..."
cat > ~/.config/containers/storage.conf << 'STORAGE_EOF'
[storage]
driver = "overlay"
runroot = "/run/user/$(id -u)/containers"
graphroot = "$HOME/.local/share/containers/storage"

[storage.options]
additionalimagestores = []

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
STORAGE_EOF

# .bashrc에 Podman 관련 alias 추가
log_info "Podman 관련 alias 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Podman 관련 Alias 및 함수
# ======================================

# 기본 Podman 명령어 alias
alias pods='podman ps'
alias podsa='podman ps -a'
alias podi='podman images'
alias podrm='podman rm'
alias podrmi='podman rmi'
alias podlogs='podman logs'
alias podexec='podman exec -it'
alias podstop='podman stop'
alias podstart='podman start'
alias podrestart='podman restart'
alias podbuild='podman build'
alias podrun='podman run'
alias podpull='podman pull'
alias podpush='podman push'
alias podinspect='podman inspect'
alias podtop='podman top'
alias podstats='podman stats'

# Buildah 관련 alias
alias bud='buildah bud'
alias buildah-from='buildah from'
alias buildah-run='buildah run'
alias buildah-commit='buildah commit'

# 컨테이너 관리 함수
podclean() {
    echo '🧹 사용하지 않는 컨테이너 및 이미지 정리 중...'
    podman container prune -f
    podman image prune -f
    podman volume prune -f
    echo '✅ 정리 완료!'
}

podinfo() {
    echo '=== Podman 시스템 정보 ==='
    echo '컨테이너 수: '$(podman ps -a | wc -l)' 개'
    echo '이미지 수: '$(podman images | wc -l)' 개'
    echo '볼륨 수: '$(podman volume ls | wc -l)' 개'
    echo ''
    echo '실행 중인 컨테이너:'
    podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    echo ''
    echo '저장된 이미지:'
    podman images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
}

podenter() {
    if [ $# -eq 0 ]; then
        echo '사용법: podenter <컨테이너명>'
        echo '실행 중인 컨테이너:'
        podman ps --format 'table {{.Names}}\t{{.Status}}'
        return 1
    fi
    podman exec -it "$1" /bin/bash 2>/dev/null || podman exec -it "$1" /bin/sh
}

podlf() {
    if [ $# -eq 0 ]; then
        echo '사용법: podlf <컨테이너명>'
        echo '실행 중인 컨테이너:'
        podman ps --format 'table {{.Names}}\t{{.Status}}'
        return 1
    fi
    echo '📋 실시간 로그 확인 (Ctrl+C로 종료):'
    podman logs -f "$1"
}

podstopall() {
    echo '⚠️  모든 실행 중인 컨테이너를 정지합니다.'
    echo '계속하시겠습니까? (y/N)'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        podman stop $(podman ps -q) 2>/dev/null || echo '정지할 컨테이너가 없습니다.'
        echo '✅ 모든 컨테이너 정지 완료'
    else
        echo '❌ 취소되었습니다.'
    fi
}

podrmall() {
    echo '⚠️  모든 정지된 컨테이너를 삭제합니다.'
    echo '계속하시겠습니까? (y/N)'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        podman rm $(podman ps -aq) 2>/dev/null || echo '삭제할 컨테이너가 없습니다.'
        echo '✅ 모든 컨테이너 삭제 완료'
    else
        echo '❌ 취소되었습니다.'
    fi
}

# 환경 변수
export BUILDAH_FORMAT=docker

BASHRC_EOF

# 권한 설정
log_info "권한 설정 중..."
sudo chown -R $USER:$USER ~/.config/containers ~/.local/share/containers ~/containers

# Podman 테스트
log_info "Podman 설치 테스트 중..."
if timeout 30 podman run --rm hello-world > /dev/null 2>&1; then
    log_success "Podman 설치 테스트 성공!"
else
    log_warning "Podman 테스트 실패 또는 타임아웃 - 수동으로 확인해주세요"
fi

# .bashrc 적용
log_info "환경 설정 적용 중..."
source ~/.bashrc

# 완료 메시지
echo ""
echo "========================================"
echo "  Podman 설치 완료!"
echo "========================================"
echo "Podman 버전: $(podman --version)"
if command -v buildah >/dev/null 2>&1; then
    echo "Buildah 버전: $(buildah --version)"
fi
if command -v skopeo >/dev/null 2>&1; then
    echo "Skopeo 버전: $(skopeo --version)"
fi
echo ""
echo "📁 컨테이너 설정 디렉토리: ~/.config/containers/"
echo "📁 컨테이너 데이터 디렉토리: ~/.local/share/containers/"
echo "📁 작업 디렉토리: ~/containers/"
echo ""
echo "🔧 사용 가능한 alias 및 함수:"
echo "  • pods       - podman ps"
echo "  • podi       - podman images"
echo "  • podclean   - 컨테이너 정리"
echo "  • podinfo    - 시스템 정보"
echo "  • podenter   - 컨테이너 접속"
echo "  • podlf      - 실시간 로그"
echo "  • podstopall - 모든 컨테이너 정지"
echo "  • podrmall   - 모든 컨테이너 삭제"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "🧪 테스트 명령어:"
echo "podman run --rm hello-world"
echo "========================================"