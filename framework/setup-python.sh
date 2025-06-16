#!/bin/bash

# Python 개발 환경 설치 스크립트
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
echo "  Python 개발 환경 설치 스크립트"
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

# Python 설치 함수
install_python() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian
        log_info "Python 관련 패키지 설치 중..."
        sudo apt install -y python3 python3-pip python3-venv python3-dev python3-setuptools python3-wheel build-essential libssl-dev libffi-dev python3-tk
        
        # deadsnakes PPA 추가 (최신 Python 버전용)
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt update
        sudo apt install -y python3.11 python3.11-venv python3.11-dev
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "Python 관련 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y python3 python3-pip python3-devel python3-setuptools python3-wheel gcc gcc-c++ make openssl-devel libffi-devel tkinter
        else
            sudo yum install -y python3 python3-pip python3-devel python3-setuptools python3-wheel gcc gcc-c++ make openssl-devel libffi-devel tkinter
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "Python 관련 패키지 설치 중..."
        sudo dnf install -y python3 python3-pip python3-devel python3-setuptools python3-wheel gcc gcc-c++ make openssl-devel libffi-devel python3-tkinter
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "Python 관련 패키지 설치 중..."
        sudo zypper install -y python3 python3-pip python3-devel python3-setuptools python3-wheel gcc gcc-c++ make libopenssl-devel libffi-devel python3-tk
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "Python 관련 패키지 설치 중..."
        sudo pacman -S --noconfirm python python-pip python-setuptools python-wheel base-devel openssl libffi tk
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "Python 관련 패키지 설치 중..."
        sudo apk add python3 py3-pip python3-dev py3-setuptools py3-wheel build-base openssl-dev libffi-dev
        
    else
        log_error "지원하지 않는 운영체제입니다: $OS"
        log_info "수동으로 Python을 설치해주세요: https://python.org"
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

# Python 설치
install_python

# Python 버전 확인
PYTHON_VERSION=$(python3 --version)
log_success "Python 설치 완료: $PYTHON_VERSION"

# pip 업그레이드
log_info "pip 업그레이드 중..."
python3 -m pip install --upgrade pip

# Poetry 설치 (Python 패키지 관리자)
log_info "Poetry 설치 중..."
curl -sSL https://install.python-poetry.org | python3 -

# 유용한 Python 패키지들 설치
log_info "유용한 Python 패키지들 설치 중..."
python3 -m pip install --user virtualenv pipenv black flake8 mypy pytest requests numpy pandas matplotlib jupyter ipython

# pyenv 설치 (Python 버전 관리자)
log_info "pyenv 설치 중..."
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

# 작업 디렉토리 생성
log_info "Python 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/python
mkdir -p ~/venvs

# .bashrc에 Python 관련 설정 추가
log_info "Python 관련 환경 설정 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Python 개발 환경 설정
# ======================================

# pyenv 설정
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Poetry 설정
export PATH="$HOME/.local/bin:$PATH"

# Python alias
alias py='python3'
alias pip='python3 -m pip'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias pyserver='python3 -m http.server'
alias pyjupyter='jupyter notebook'
alias pytest='python3 -m pytest'
alias pyformat='black . && flake8 .'

# 가상환경 관리 함수
mkvenv() {
    if [ $# -eq 0 ]; then
        echo "사용법: mkvenv <환경명>"
        return 1
    fi
    python3 -m venv ~/venvs/"$1"
    echo "가상환경 '$1' 생성 완료"
    echo "활성화: source ~/venvs/$1/bin/activate"
}

rmvenv() {
    if [ $# -eq 0 ]; then
        echo "사용법: rmvenv <환경명>"
        echo "사용 가능한 환경:"
        ls ~/venvs/ 2>/dev/null || echo "생성된 가상환경이 없습니다."
        return 1
    fi
    if [ -d ~/venvs/"$1" ]; then
        rm -rf ~/venvs/"$1"
        echo "가상환경 '$1' 삭제 완료"
    else
        echo "가상환경 '$1'을 찾을 수 없습니다."
    fi
}

lsvenv() {
    echo "생성된 가상환경 목록:"
    ls ~/venvs/ 2>/dev/null || echo "생성된 가상환경이 없습니다."
}

# Python 프로젝트 시작 함수
pyinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: pyinit <프로젝트명>"
        return 1
    fi
    
    PROJECT_NAME="$1"
    mkdir -p ~/workspace/python/"$PROJECT_NAME"
    cd ~/workspace/python/"$PROJECT_NAME"
    
    # 가상환경 생성
    python3 -m venv venv
    source venv/bin/activate
    
    # 기본 파일들 생성
    echo "# $PROJECT_NAME" > README.md
    echo "__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.pytest_cache/
*.egg-info/
.DS_Store" > .gitignore
    
    echo "requests
black
flake8
mypy
pytest" > requirements.txt
    
    mkdir -p src tests
    touch src/__init__.py
    touch tests/__init__.py
    echo "print('Hello, $PROJECT_NAME!')" > src/main.py
    
    echo "✅ Python 프로젝트 '$PROJECT_NAME' 초기화 완료"
    echo "📁 위치: ~/workspace/python/$PROJECT_NAME"
    echo "🔧 가상환경이 활성화되었습니다."
    echo "📦 패키지 설치: pip install -r requirements.txt"
}

BASHRC_EOF

# Python 개발용 템플릿 파일 생성
log_info "Python 개발 템플릿 생성 중..."
mkdir -p ~/workspace/python/templates

# Flask 템플릿
cat > ~/workspace/python/templates/flask_app.py << 'FLASK_EOF'
#!/usr/bin/env python3
"""
Flask 웹 애플리케이션 템플릿
"""

from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"message": "Hello, Flask!"})

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
FLASK_EOF

# FastAPI 템플릿
cat > ~/workspace/python/templates/fastapi_app.py << 'FASTAPI_EOF'
#!/usr/bin/env python3
"""
FastAPI 웹 애플리케이션 템플릿
"""

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="My API", version="1.0.0")

class Item(BaseModel):
    name: str
    description: str = None

@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/items/")
def create_item(item: Item):
    return {"item": item}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
FASTAPI_EOF

# Discord Bot 템플릿
cat > ~/workspace/python/templates/discord_bot.py << 'DISCORD_EOF'
#!/usr/bin/env python3
"""
Discord Bot 템플릿
"""

import discord
from discord.ext import commands
import asyncio

# Bot 설정
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print(f'{bot.user} 봇이 준비되었습니다!')

@bot.command(name='ping')
async def ping(ctx):
    await ctx.send(f'Pong! {round(bot.latency * 1000)}ms')

@bot.command(name='hello')
async def hello(ctx):
    await ctx.send(f'안녕하세요, {ctx.author.mention}!')

if __name__ == '__main__':
    # TOKEN을 환경 변수에서 가져오거나 직접 입력
    import os
    TOKEN = os.getenv('DISCORD_BOT_TOKEN')
    if not TOKEN:
        TOKEN = input('Discord Bot Token을 입력하세요: ')
    
    bot.run(TOKEN)
DISCORD_EOF

# 완료 메시지
echo ""
echo "========================================"
echo "  Python 개발 환경 설치 완료!"
echo "========================================"
echo "Python 버전: $(python3 --version)"
echo "pip 버전: $(python3 -m pip --version)"
if command -v poetry >/dev/null 2>&1; then
    echo "Poetry 버전: $(poetry --version)"
fi
echo ""
echo "📁 작업 디렉토리:"
echo "  • ~/workspace/python/ - Python 프로젝트들"
echo "  • ~/venvs/ - 가상환경들"
echo "  • ~/workspace/python/templates/ - 개발 템플릿들"
echo ""
echo "🔧 사용 가능한 명령어:"
echo "  • py - python3"
echo "  • mkvenv <이름> - 가상환경 생성"
echo "  • rmvenv <이름> - 가상환경 삭제"
echo "  • lsvenv - 가상환경 목록"
echo "  • pyinit <프로젝트명> - 새 프로젝트 초기화"
echo "  • pyserver - HTTP 서버 실행"
echo "  • pyjupyter - Jupyter Notebook 실행"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "🧪 테스트 명령어:"
echo "pyinit test-project"
echo "========================================"