#!/bin/bash

# Docker 컨테이너 환경 설치 스크립트
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
echo "  Docker 컨테이너 환경 설치 스크립트"
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

# Docker 설치 함수
install_docker() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian - 공식 Docker 저장소 사용
        log_info "Docker 의존성 패키지 설치 중..."
        sudo apt install -y ca-certificates curl gnupg lsb-release
        
        log_info "Docker GPG 키 추가 중..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        log_info "Docker 저장소 추가 중..."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt update
        
        log_info "Docker 패키지 설치 중..."
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "Docker 의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y yum-utils device-mapper-persistent-data lvm2
            sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        else
            sudo yum install -y yum-utils device-mapper-persistent-data lvm2
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "Docker 패키지 설치 중..."
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "Docker 패키지 설치 중..."
        sudo zypper install -y docker docker-compose
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "Docker 패키지 설치 중..."
        sudo pacman -S --noconfirm docker docker-compose
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "Docker 패키지 설치 중..."
        sudo apk add docker docker-compose
        
    else
        log_error "지원하지 않는 운영체제입니다: $OS"
        log_info "수동으로 Docker를 설치해주세요: https://docs.docker.com/install/"
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

# Docker 설치
install_docker

# Docker 서비스 시작 및 활성화
log_info "Docker 서비스 시작 및 활성화 중..."
sudo systemctl enable docker
sudo systemctl start docker

# 사용자를 docker 그룹에 추가
log_info "사용자를 docker 그룹에 추가 중..."
sudo usermod -aG docker $USER

# Docker 버전 확인
DOCKER_VERSION=$(docker --version)
log_success "Docker 설치 완료: $DOCKER_VERSION"

# Docker Compose 버전 확인
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker-compose --version)
    log_success "Docker Compose 설치 완료: $COMPOSE_VERSION"
else
    # Docker Compose 플러그인 확인
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version)
        log_success "Docker Compose Plugin 설치 완료: $COMPOSE_VERSION"
    fi
fi

# 작업 디렉토리 생성
log_info "Docker 작업 디렉토리 생성 중..."
mkdir -p ~/containers/docker
mkdir -p ~/containers/docker/compose
mkdir -p ~/containers/docker/volumes

# .bashrc에 Docker 관련 alias 추가
log_info "Docker 관련 alias 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Docker 관련 Alias 및 함수
# ======================================

# 기본 Docker 명령어 alias
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dlogs='docker logs'
alias dexec='docker exec -it'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dbuild='docker build'
alias drun='docker run'
alias dpull='docker pull'
alias dpush='docker push'
alias dinspect='docker inspect'
alias dstats='docker stats'
alias dnetwork='docker network'
alias dvolume='docker volume'

# Docker Compose alias
alias dcup='docker compose up'
alias dcdown='docker compose down'
alias dcbuild='docker compose build'
alias dcpull='docker compose pull'
alias dclogs='docker compose logs'
alias dcps='docker compose ps'
alias dcrestart='docker compose restart'

# Docker 시스템 관리 함수
dclean() {
    echo '🧹 Docker 시스템 정리 중...'
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    echo '✅ Docker 정리 완료!'
}

dcleanall() {
    echo '⚠️  모든 Docker 리소스를 정리합니다 (이미지 포함)'
    echo '계속하시겠습니까? (y/N)'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        docker system prune -a -f --volumes
        echo '✅ 모든 Docker 리소스 정리 완료!'
    else
        echo '❌ 취소되었습니다.'
    fi
}

dinfo() {
    echo '=== Docker 시스템 정보 ==='
    echo '컨테이너 수: '$(docker ps -a | wc -l)' 개'
    echo '이미지 수: '$(docker images | wc -l)' 개'
    echo '볼륨 수: '$(docker volume ls | wc -l)' 개'
    echo '네트워크 수: '$(docker network ls | wc -l)' 개'
    echo ''
    echo '실행 중인 컨테이너:'
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    echo ''
    echo '저장된 이미지:'
    docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
    echo ''
    echo '디스크 사용량:'
    docker system df
}

denter() {
    if [ $# -eq 0 ]; then
        echo '사용법: denter <컨테이너명>'
        echo '실행 중인 컨테이너:'
        docker ps --format 'table {{.Names}}\t{{.Status}}'
        return 1
    fi
    docker exec -it "$1" /bin/bash 2>/dev/null || docker exec -it "$1" /bin/sh
}

dlf() {
    if [ $# -eq 0 ]; then
        echo '사용법: dlf <컨테이너명>'
        echo '실행 중인 컨테이너:'
        docker ps --format 'table {{.Names}}\t{{.Status}}'
        return 1
    fi
    echo '📋 실시간 로그 확인 (Ctrl+C로 종료):'
    docker logs -f "$1"
}

dstopall() {
    echo '⚠️  모든 실행 중인 컨테이너를 정지합니다.'
    echo '계속하시겠습니까? (y/N)'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        docker stop $(docker ps -q) 2>/dev/null || echo '정지할 컨테이너가 없습니다.'
        echo '✅ 모든 컨테이너 정지 완료'
    else
        echo '❌ 취소되었습니다.'
    fi
}

drmall() {
    echo '⚠️  모든 정지된 컨테이너를 삭제합니다.'
    echo '계속하시겠습니까? (y/N)'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        docker rm $(docker ps -aq) 2>/dev/null || echo '삭제할 컨테이너가 없습니다.'
        echo '✅ 모든 컨테이너 삭제 완료'
    else
        echo '❌ 취소되었습니다.'
    fi
}

# Docker Compose 프로젝트 관리
dcinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: dcinit <프로젝트명>"
        return 1
    fi
    
    PROJECT_NAME="$1"
    mkdir -p ~/containers/docker/compose/"$PROJECT_NAME"
    cd ~/containers/docker/compose/"$PROJECT_NAME"
    
    # 기본 docker-compose.yml 생성
    cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  app:
    build: .
    container_name: ${PROJECT_NAME:-app}
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    restart: unless-stopped

  # 데이터베이스 (필요시 주석 해제)
  # db:
  #   image: postgres:15
  #   container_name: ${PROJECT_NAME:-app}-db
  #   environment:
  #     POSTGRES_DB: myapp
  #     POSTGRES_USER: user
  #     POSTGRES_PASSWORD: password
  #   volumes:
  #     - postgres_data:/var/lib/postgresql/data
  #   ports:
  #     - "5432:5432"

  # Redis (필요시 주석 해제)
  # redis:
  #   image: redis:7-alpine
  #   container_name: ${PROJECT_NAME:-app}-redis
  #   ports:
  #     - "6379:6379"

# volumes:
#   postgres_data:
COMPOSE_EOF

    # .env 파일 생성
    echo "PROJECT_NAME=$PROJECT_NAME
NODE_ENV=development
PORT=3000" > .env

    # .gitignore 생성
    echo ".env
.env.local
.env.production
node_modules/
logs/
*.log" > .gitignore

    # Dockerfile 템플릿 생성
    cat > Dockerfile << 'DOCKERFILE_EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
DOCKERFILE_EOF

    echo "✅ Docker Compose 프로젝트 '$PROJECT_NAME' 초기화 완료"
    echo "📁 위치: ~/containers/docker/compose/$PROJECT_NAME"
    echo "🚀 실행: docker compose up -d"
}

BASHRC_EOF

# Docker 개발 템플릿 생성
log_info "Docker 개발 템플릿 생성 중..."
mkdir -p ~/containers/docker/templates

# Node.js Dockerfile 템플릿
cat > ~/containers/docker/templates/Dockerfile.nodejs << 'NODEJS_DOCKERFILE_EOF'
# Node.js 애플리케이션용 멀티스테이지 Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# 의존성 파일 복사 및 설치
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 개발 의존성도 설치 (빌드용)
RUN npm ci
COPY . .
RUN npm run build

# 프로덕션 이미지
FROM node:18-alpine AS production

WORKDIR /app

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 빌드된 파일과 의존성만 복사
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
NODEJS_DOCKERFILE_EOF

# Python Dockerfile 템플릿
cat > ~/containers/docker/templates/Dockerfile.python << 'PYTHON_DOCKERFILE_EOF'
# Python 애플리케이션용 Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 보안을 위한 non-root 사용자 생성
RUN useradd --create-home --shell /bin/bash app
USER app

EXPOSE 8000

CMD ["python", "app.py"]
PYTHON_DOCKERFILE_EOF

# Go Dockerfile 템플릿
cat > ~/containers/docker/templates/Dockerfile.golang << 'GO_DOCKERFILE_EOF'
# Go 애플리케이션용 멀티스테이지 Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Go 모듈 파일 복사 및 의존성 다운로드
COPY go.mod go.sum ./
RUN go mod download

# 소스 코드 복사 및 빌드
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# 최종 이미지 (매우 작음)
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# 빌드된 바이너리만 복사
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
GO_DOCKERFILE_EOF

# 다양한 docker-compose 템플릿들
log_info "Docker Compose 템플릿 생성 중..."

# 풀스택 웹 애플리케이션 템플릿
cat > ~/containers/docker/templates/docker-compose.fullstack.yml << 'FULLSTACK_COMPOSE_EOF'
version: '3.8'

services:
  # 프론트엔드 (React/Vue/Angular)
  frontend:
    build: ./frontend
    container_name: frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    depends_on:
      - backend

  # 백엔드 API
  backend:
    build: ./backend
    container_name: backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  # PostgreSQL 데이터베이스
  db:
    image: postgres:15
    container_name: postgres_db
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"

  # Redis 캐시
  redis:
    image: redis:7-alpine
    container_name: redis_cache
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # Nginx 리버스 프록시
  nginx:
    image: nginx:alpine
    container_name: nginx_proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend

volumes:
  postgres_data:
  redis_data:
FULLSTACK_COMPOSE_EOF

# 모니터링 스택 템플릿
cat > ~/containers/docker/templates/docker-compose.monitoring.yml << 'MONITORING_COMPOSE_EOF'
version: '3.8'

services:
  # Prometheus 메트릭 수집
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

  # Grafana 대시보드
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources

  # Elasticsearch 로그 수집
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  # Kibana 로그 시각화
  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  prometheus_data:
  grafana_data:
  elasticsearch_data:
MONITORING_COMPOSE_EOF

# Docker 설치 테스트
log_info "Docker 설치 테스트 중..."
if timeout 30 docker run --rm hello-world > /dev/null 2>&1; then
    log_success "Docker 설치 테스트 성공!"
else
    log_warning "Docker 테스트 실패 또는 타임아웃 - 재로그인 후 확인해주세요"
fi

# 완료 메시지
echo ""
echo "========================================"
echo "  Docker 설치 완료!"
echo "========================================"
echo "Docker 버전: $(docker --version)"
if command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose 버전: $(docker-compose --version)"
elif docker compose version >/dev/null 2>&1; then
    echo "Docker Compose Plugin 버전: $(docker compose version)"
fi
echo ""
echo "📁 컨테이너 작업 디렉토리:"
echo "  • ~/containers/docker/ - Docker 프로젝트들"
echo "  • ~/containers/docker/compose/ - Docker Compose 프로젝트들"
echo "  • ~/containers/docker/templates/ - 개발 템플릿들"
echo ""
echo "🔧 사용 가능한 alias 및 함수:"
echo "  • d - docker"
echo "  • dc - docker compose"
echo "  • dps - docker ps"
echo "  • dinfo - Docker 시스템 정보"
echo "  • dclean - Docker 시스템 정리"
echo "  • denter - 컨테이너 접속"
echo "  • dcinit - Docker Compose 프로젝트 초기화"
echo ""
echo "⚠️  중요: docker 그룹 권한을 적용하려면 다음 중 하나를 실행하세요:"
echo "  • 로그아웃 후 다시 로그인"
echo "  • 또는: newgrp docker"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "🧪 테스트 명령어:"
echo "docker run --rm hello-world"
echo "dcinit test-app"
echo "========================================"