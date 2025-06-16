#!/bin/bash

# Go 개발 환경 설치 스크립트
# 작성자: pabloism0x

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
echo "  Go 개발 환경 설치 스크립트"
echo "========================================"
echo ""

# 운영체제 및 아키텍처 감지
detect_system() {
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
    
    # 아키텍처 감지
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) GO_ARCH="amd64" ;;
        aarch64|arm64) GO_ARCH="arm64" ;;
        armv7l) GO_ARCH="armv6l" ;;
        *) 
            log_error "지원하지 않는 아키텍처입니다: $ARCH"
            exit 1
            ;;
    esac
}

# Go 설치 함수
install_go() {
    detect_system
    log_info "감지된 운영체제: $OS $VER ($ARCH)"
    
    # Go 최신 버전 정보 가져오기
    GO_VERSION="1.21.5"  # 안정적인 LTS 버전
    GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    GO_URL="https://golang.org/dl/${GO_TARBALL}"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian - 의존성 패키지 설치
        log_info "Go 의존성 패키지 설치 중..."
        sudo apt install -y wget curl git build-essential
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "Go 의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y wget curl git gcc gcc-c++ make
        else
            sudo yum install -y wget curl git gcc gcc-c++ make
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "Go 의존성 패키지 설치 중..."
        sudo dnf install -y wget curl git gcc gcc-c++ make
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "Go 의존성 패키지 설치 중..."
        sudo zypper install -y wget curl git gcc gcc-c++ make
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "Go 의존성 패키지 설치 중..."
        sudo pacman -S --noconfirm wget curl git base-devel
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "Go 의존성 패키지 설치 중..."
        sudo apk add wget curl git build-base
        
    else
        log_warning "지원하지 않는 운영체제입니다: $OS"
        log_info "의존성 패키지를 수동으로 설치해주세요: wget, curl, git, gcc"
    fi
    
    # 기존 Go 설치 확인 및 제거
    if [ -d "/usr/local/go" ]; then
        log_info "기존 Go 설치 발견. 제거 중..."
        sudo rm -rf /usr/local/go
    fi
    
    # Go 다운로드 및 설치
    log_info "Go ${GO_VERSION} 다운로드 중..."
    cd /tmp
    wget -q "$GO_URL" -O "$GO_TARBALL"
    
    log_info "Go ${GO_VERSION} 설치 중..."
    sudo tar -C /usr/local -xzf "$GO_TARBALL"
    
    # 다운로드 파일 정리
    rm -f "$GO_TARBALL"
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

# Go 설치
install_go

# 작업 디렉토리 생성
log_info "Go 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/go
mkdir -p ~/go/src ~/go/bin ~/go/pkg

# .bashrc에 Go 관련 설정 추가
log_info "Go 환경 변수 설정 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Go 개발 환경 설정
# ======================================

# Go 환경 변수
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Go alias
alias gob='go build'
alias gor='go run'
alias got='go test'
alias gom='go mod'
alias goi='go install'
alias gof='gofmt -w'
alias goget='go get'
alias gomod='go mod init'
alias gotidy='go mod tidy'
alias gowork='cd ~/workspace/go'

# Go 개발 도구 함수
goinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: goinit <프로젝트명> [모듈명]"
        return 1
    fi
    
    PROJECT_NAME="$1"
    MODULE_NAME="${2:-$PROJECT_NAME}"
    
    mkdir -p ~/workspace/go/"$PROJECT_NAME"
    cd ~/workspace/go/"$PROJECT_NAME"
    
    # Go 모듈 초기화
    go mod init "$MODULE_NAME"
    
    # 기본 파일들 생성
    echo "# $PROJECT_NAME

Go 프로젝트

## 실행
\`\`\`bash
go run main.go
\`\`\`

## 빌드
\`\`\`bash
go build -o $PROJECT_NAME
\`\`\`

## 테스트
\`\`\`bash
go test ./...
\`\`\`" > README.md

    echo "# Binaries
$PROJECT_NAME
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary
*.test

# Output of go coverage tool
*.out

# Go workspace file
go.work

# IDE
.vscode/
.idea/" > .gitignore

    # main.go 파일 생성
    echo 'package main

import "fmt"

func main() {
    fmt.Printf("Hello, %s!\\n", "'$PROJECT_NAME'")
}' > main.go

    # 기본 테스트 파일 생성
    echo 'package main

import "testing"

func TestMain(t *testing.T) {
    // 테스트 코드 작성
    t.Log("테스트가 실행되었습니다")
}' > main_test.go
    
    echo "✅ Go 프로젝트 '$PROJECT_NAME' 초기화 완료"
    echo "📁 위치: ~/workspace/go/$PROJECT_NAME"
    echo "🚀 실행: go run main.go"
}

# Go 벤치마크 실행 함수
gobench() {
    echo "🏃 Go 벤치마크 실행 중..."
    go test -bench=. -benchmem
}

# Go 의존성 확인 함수
godeps() {
    echo "📦 Go 모듈 의존성:"
    go list -m all
}

# Go 빌드 정보 확인 함수
goinfo() {
    echo "=== Go 개발 환경 정보 ==="
    echo "Go 버전: $(go version)"
    echo "GOPATH: $GOPATH"
    echo "GOROOT: $(go env GOROOT)"
    echo "GOOS: $(go env GOOS)"
    echo "GOARCH: $(go env GOARCH)"
    echo ""
    echo "설치된 Go 도구들:"
    ls $GOBIN 2>/dev/null || echo "설치된 도구가 없습니다."
}

BASHRC_EOF

# 환경 변수 임시 적용
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

# Go 버전 확인
GO_VERSION_INSTALLED=$(go version)
log_success "Go 설치 완료: $GO_VERSION_INSTALLED"

# 유용한 Go 도구들 설치
log_info "유용한 Go 도구들 설치 중..."

# 기본 개발 도구들
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/lint/golint@latest
go install github.com/gordonklaus/ineffassign@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest

# 웹 개발 도구들
go install github.com/gin-gonic/gin@latest
go install github.com/labstack/echo/v4@latest

# 유틸리티 도구들
go install github.com/air-verse/air@latest  # Hot reload
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest  # Linter

# Go 개발 템플릿 생성
log_info "Go 개발 템플릿 생성 중..."
mkdir -p ~/workspace/go/templates

# HTTP 서버 템플릿
cat > ~/workspace/go/templates/http_server.go << 'HTTP_EOF'
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "time"
)

type Response struct {
    Message string    `json:"message"`
    Time    time.Time `json:"time"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    response := Response{
        Message: "Server is healthy",
        Time:    time.Now(),
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
    response := Response{
        Message: "Hello, Go HTTP Server!",
        Time:    time.Now(),
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func main() {
    http.HandleFunc("/health", healthHandler)
    http.HandleFunc("/", helloHandler)
    
    port := ":8080"
    fmt.Printf("Server starting on port %s\n", port)
    log.Fatal(http.ListenAndServe(port, nil))
}
HTTP_EOF

# CLI 애플리케이션 템플릿
cat > ~/workspace/go/templates/cli_app.go << 'CLI_EOF