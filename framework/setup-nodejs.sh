#!/bin/bash

# Node.js 개발 환경 설치 스크립트
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
echo "  Node.js 개발 환경 설치 스크립트"
echo "========================================"
echo ""

# 시스템 패키지 목록 업데이트
log_info "패키지 목록 업데이트 중..."
sudo apt update

# Node.js 20.x LTS 설치
log_info "Node.js 20.x LTS 저장소 추가 중..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

log_info "Node.js 설치 중..."
sudo apt-get install -y nodejs

# 버전 확인
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)

log_success "Node.js 설치 완료: $NODE_VERSION"
log_success "npm 설치 완료: $NPM_VERSION"

# npm 최신 버전으로 업데이트
log_info "npm을 최신 버전으로 업데이트 중..."
sudo npm install -g npm@latest

# 글로벌 패키지 설치
log_info "글로벌 개발 도구 설치 중..."

# TypeScript 관련
sudo npm install -g typescript@latest
sudo npm install -g ts-node@latest
sudo npm install -g @types/node@latest

# 개발 도구
sudo npm install -g nodemon@latest
sudo npm install -g pnpm@latest
sudo npm install -g yarn@latest

# 유틸리티
sudo npm install -g pm2@latest

# 설치된 글로벌 패키지 확인
log_info "설치된 글로벌 패키지:"
npm list -g --depth=0

# 버전 확인
echo ""
echo "========================================"
echo "  설치 완료 - 버전 정보"
echo "========================================"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "TypeScript: $(tsc --version)"
echo "ts-node: $(ts-node --version)"
echo "nodemon: $(nodemon --version)"
echo "pnpm: $(pnpm --version)"
echo "yarn: $(yarn --version)"
echo "PM2: $(pm2 --version)"

# 개발 디렉토리 생성
log_info "개발 디렉토리 생성 중..."
mkdir -p ~/workspace
mkdir -p ~/workspace/discord-bot
mkdir -p ~/workspace/scripts
mkdir -p ~/workspace/logs

# .bashrc에 Node.js 관련 환경 변수 추가
log_info "환경 변수 설정 중..."
{
    echo ""
    echo "# ======================================"
    echo "# Node.js 개발 환경 설정"
    echo "# ======================================"
    echo ""
    echo "# Node.js 환경 변수"
    echo "export NODE_ENV=development"
    echo "export PATH=\$PATH:\$(npm bin -g)"
    echo "export NODE_OPTIONS='--max-old-space-size=4096'"
    echo ""
    echo "# npm 설정"
    echo "export NPM_CONFIG_PROGRESS=false"
    echo "export NPM_CONFIG_LOGLEVEL=warn"
    echo ""
    echo "# yarn 설정"
    echo "export YARN_CACHE_FOLDER=~/.yarn-cache"
    echo "export PATH=\$PATH:\$(yarn global bin 2>/dev/null || echo '')"
    echo ""
    echo "# pnpm 설정"
    echo "export PNPM_HOME=~/.local/share/pnpm"
    echo "export PATH=\$PNPM_HOME:\$PATH"
    echo ""
    echo "# 개발 편의 alias (Node.js 특화)"
    echo "alias cdw='cd ~/workspace'"
    echo "alias cdn='cd ~/workspace/discord-bot'"
    echo "alias logs='tail -f ~/logs/*.log 2>/dev/null || echo \"로그 파일이 없습니다.\"'"
    echo ""
    echo "# Node.js 개발 alias"
    echo "alias nrs='npm run start'"
    echo "alias nrd='npm run dev'"
    echo "alias nrb='npm run build'"
    echo "alias nrt='npm run test'"
    echo "alias ni='npm install'"
    echo "alias nid='npm install --save-dev'"
    echo "alias nig='npm install -g'"
    echo "alias nci='npm ci'"
    echo "alias nls='npm list'"
    echo "alias nout='npm outdated'"
    echo "alias nup='npm update'"
    echo ""
    echo "# yarn alias"
    echo "alias y='yarn'"
    echo "alias ya='yarn add'"
    echo "alias yad='yarn add --dev'"
    echo "alias yag='yarn global add'"
    echo "alias yr='yarn remove'"
    echo "alias yrs='yarn run start'"
    echo "alias yrd='yarn run dev'"
    echo "alias yrb='yarn run build'"
    echo "alias yrt='yarn run test'"
    echo "alias yi='yarn install'"
    echo "alias yls='yarn list'"
    echo "alias yout='yarn outdated'"
    echo "alias yup='yarn upgrade'"
    echo ""
    echo "# pnpm alias"
    echo "alias p='pnpm'"
    echo "alias pa='pnpm add'"
    echo "alias pad='pnpm add --save-dev'"
    echo "alias pag='pnpm add --global'"
    echo "alias pr='pnpm remove'"
    echo "alias prs='pnpm run start'"
    echo "alias prd='pnpm run dev'"
    echo "alias prb='pnpm run build'"
    echo "alias prt='pnpm run test'"
    echo "alias pi='pnpm install'"
    echo "alias pls='pnpm list'"
    echo "alias pout='pnpm outdated'"
    echo "alias pup='pnpm update'"
    echo ""
    echo "# 패키지 매니저 유틸리티 함수"
    echo "pkginfo() {"
    echo "    echo '=== 패키지 매니저 정보 ==='"
    echo "    echo 'npm: '$(npm --version)"
    echo "    echo 'yarn: '$(yarn --version 2>/dev/null || echo '미설치')"
    echo "    echo 'pnpm: '$(pnpm --version 2>/dev/null || echo '미설치')"
    echo "    echo '========================'"
    echo "}"
    echo ""
    echo "cleanpkg() {"
    echo "    echo '🧹 패키지 캐시 정리 중...'"
    echo "    npm cache clean --force 2>/dev/null || echo 'npm 캐시 정리 실패'"
    echo "    yarn cache clean 2>/dev/null || echo 'yarn 캐시 정리 실패 (yarn 미설치 가능)'"
    echo "    pnpm store prune 2>/dev/null || echo 'pnpm 캐시 정리 실패 (pnpm 미설치 가능)'"
    echo "    echo '✅ 캐시 정리 완료!'"
    echo "}"
    echo ""
    echo "nodeinfo() {"
    echo "    echo '=== Node.js 환경 정보 ==='"
    echo "    echo 'Node.js: '$(node --version)"
    echo "    echo 'npm: '$(npm --version)"
    echo "    echo 'TypeScript: '$(tsc --version 2>/dev/null || echo '미설치')"
    echo "    echo 'ts-node: '$(ts-node --version 2>/dev/null || echo '미설치')"
    echo "    echo 'nodemon: '$(nodemon --version 2>/dev/null || echo '미설치')"
    echo "    echo 'yarn: '$(yarn --version 2>/dev/null || echo '미설치')"
    echo "    echo 'pnpm: '$(pnpm --version 2>/dev/null || echo '미설치')"
    echo "    echo 'PM2: '$(pm2 --version 2>/dev/null || echo '미설치')"
    echo "    echo '========================'"
    echo "}"
    echo ""
} >> ~/.bashrc

# 권한 설정
log_info "권한 설정 중..."
sudo chown -R $USER:$USER ~/.npm
sudo chown -R $USER:$USER ~/workspace

log_success "Node.js 개발 환경 설치가 완료되었습니다!"
log_info "새로운 터미널을 열거나 'source ~/.bashrc'를 실행하여 환경 변수를 적용하세요."

echo ""
echo "========================================"
echo "  설치 완료!"
echo "========================================"
echo "다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "개발 디렉토리: ~/workspace"
echo "========================================"