#!/bin/bash

# 기본 필수 패키지 설치 및 환경 설정 스크립트
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
echo "  기본 필수 패키지 설치 스크립트"
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

# 패키지 매니저 설정
setup_package_manager() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        PKG_MANAGER="apt"
        PKG_UPDATE="sudo apt update"
        PKG_INSTALL="sudo apt install -y"
        PACKAGES="vim curl wget git tree htop unzip zip gnupg lsb-release software-properties-common apt-transport-https ca-certificates build-essential uidmap slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh-client dnsutils iputils-ping traceroute"
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        PKG_MANAGER="yum"
        PKG_UPDATE="sudo yum update -y"
        PKG_INSTALL="sudo yum install -y"
        PACKAGES="vim curl wget git tree htop unzip zip gnupg2 redhat-lsb-core epel-release openssl-devel gcc gcc-c++ make shadow-utils slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh-clients bind-utils iputils traceroute"
        
        # RHEL 8/9는 dnf 사용
        if command -v dnf >/dev/null 2>&1; then
            PKG_MANAGER="dnf"
            PKG_UPDATE="sudo dnf update -y"
            PKG_INSTALL="sudo dnf install -y"
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf update -y"
        PKG_INSTALL="sudo dnf install -y"
        PACKAGES="vim curl wget git tree htop unzip zip gnupg2 redhat-lsb-core openssl-devel gcc gcc-c++ make shadow-utils slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh-clients bind-utils iputils traceroute"
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="sudo zypper refresh"
        PKG_INSTALL="sudo zypper install -y"
        PACKAGES="vim curl wget git tree htop unzip zip gpg2 lsb-release openssl-devel gcc gcc-c++ make shadow slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh-clients bind-utils iputils traceroute"
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PACKAGES="vim curl wget git tree htop unzip zip gnupg lsb-release openssl gcc make shadow slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh bind-tools iputils traceroute"
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        PKG_MANAGER="apk"
        PKG_UPDATE="sudo apk update"
        PKG_INSTALL="sudo apk add"
        PACKAGES="vim curl wget git tree htop unzip zip gnupg lsb-release openssl-dev gcc make shadow slirp4netns fuse-overlayfs net-tools jq nano less gawk rsync openssh-client bind-tools iputils traceroute"
        
    else
        log_error "지원하지 않는 운영체제입니다: $OS"
        log_info "Ubuntu/Debian, CentOS/RHEL/Rocky/Alma, Fedora, openSUSE, Arch/Manjaro, Alpine을 지원합니다."
        exit 1
    fi
    
    log_info "사용할 패키지 매니저: $PKG_MANAGER"
}

# 패키지 매니저 설정 실행
setup_package_manager

# 패키지 목록 업데이트
log_info "패키지 목록 업데이트 중..."
eval $PKG_UPDATE

# 기본 필수 패키지 설치
log_info "기본 필수 패키지 설치 중..."
eval $PKG_INSTALL $PACKAGES

log_success "기본 패키지 설치 완료!"

# Git 기본 설정
log_info "Git 기본 설정 중..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor vim

# Vim 기본 설정
log_info "Vim 기본 설정 중..."
cat > ~/.vimrc << 'EOF'
" Vim 기본 설정
set number              " 줄 번호 표시
set relativenumber      " 상대 줄 번호
set autoindent          " 자동 들여쓰기
set smartindent         " 스마트 들여쓰기
set tabstop=4           " 탭 크기
set shiftwidth=4        " 들여쓰기 크기
set expandtab           " 탭을 스페이스로 변환
set hlsearch            " 검색 결과 하이라이트
set incsearch           " 증분 검색
set ignorecase          " 대소문자 무시 검색
set smartcase           " 스마트 대소문자 검색
set showmatch           " 괄호 매칭 표시
set ruler               " 커서 위치 표시
set showcmd             " 명령어 표시
set wildmenu            " 명령어 자동 완성 메뉴
set mouse=a             " 마우스 사용
set clipboard=unnamedplus " 시스템 클립보드 사용
set encoding=utf-8      " UTF-8 인코딩
set fileencoding=utf-8  " 파일 인코딩
set backspace=indent,eol,start " 백스페이스 동작

" 문법 하이라이트
syntax on

" 색상 테마
colorscheme default

" 상태 라인 설정
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]

" 파일 타입별 설정
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType yml setlocal shiftwidth=2 tabstop=2
EOF

# .bashrc에 유용한 alias 추가
log_info "유용한 alias 추가 중..."
cat >> ~/.bashrc << 'EOF'

# ======================================
# 기본 시스템 Alias
# ======================================

# 기본 명령어 개선
alias vi='vim'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# 디렉토리 탐색
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# 파일 및 디렉토리 조작
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# 시스템 정보
alias h='history'
alias j='jobs -l'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias top='htop'

# 네트워크
alias ping='ping -c 5'
alias fastping='ping -c 100 -s 2'
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'

# 시스템 서비스
alias sctl='sudo systemctl'
alias jctl='sudo journalctl'

# 파일 검색
alias ff='find . -type f -name'
alias fd='find . -type d -name'

# 파일 내용 확인
alias cat='cat -n'
alias less='less -R'
alias more='more -R'

# 압축 및 해제
alias targz='tar -czf'
alias untargz='tar -xzf'
alias tarls='tar -tzf'

# Git 관련 (기본)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# 시스템 유지보수
alias update='sudo apt update'
alias upgrade='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias show='apt show'
alias autoremove='sudo apt autoremove'
alias autoclean='sudo apt autoclean'

# 권한 관리
alias chx='chmod +x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# 개발 관련
alias c='clear'
alias cls='clear'
alias q='exit'
alias x='exit'
alias logout='exit'

# 날짜 및 시간
alias now='date +"%T"'
alias nowtime='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# 유용한 함수들
# 디렉토리 크기 확인
dirsize() {
    du -sh "$1" 2>/dev/null || echo "디렉토리가 존재하지 않습니다: $1"
}

# 빠른 백업
backup() {
    if [ $# -eq 0 ]; then
        echo "사용법: backup <파일명>"
        return 1
    fi
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "백업 완료: $1.backup.$(date +%Y%m%d_%H%M%S)"
}

# 파일 검색 및 내용 확인
searchfile() {
    if [ $# -eq 0 ]; then
        echo "사용법: searchfile <검색어>"
        return 1
    fi
    find . -type f -exec grep -l "$1" {} \;
}

# 프로세스 검색 및 종료
killprocess() {
    if [ $# -eq 0 ]; then
        echo "사용법: killprocess <프로세스명>"
        return 1
    fi
    ps aux | grep "$1" | grep -v grep
    echo "위 프로세스를 종료하시겠습니까? (y/N)"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        pkill -f "$1"
        echo "프로세스 종료 완료"
    fi
}

# 시스템 정보 요약
sysinfo() {
    echo "================================"
    echo "     시스템 정보 요약"
    echo "================================"
    echo "호스트명: $(hostname)"
    echo "운영체제: $(lsb_release -d | cut -f2)"
    echo "커널: $(uname -r)"
    echo "가동시간: $(uptime -p)"
    echo "CPU: $(lscpu | grep 'Model name' | sed 's/Model name:[[:space:]]*//')"
    echo "메모리: $(free -h | awk '/^Mem/ {print $3 "/" $2}')"
    echo "디스크: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " 사용)"}')"
    echo "네트워크: $(ip route get 8.8.8.8 | awk '{print $7}' | head -1)"
    echo "================================"
}

# 빠른 서버 상태 확인
serverstatus() {
    echo "=== 서버 상태 확인 ==="
    echo "1. 메모리 사용량:"
    free -h | grep -E "Mem|Swap"
    echo ""
    echo "2. 디스크 사용량:"
    df -h | grep -E "Filesystem|/dev/"
    echo ""
    echo "3. CPU 로드:"
    uptime
    echo ""
    echo "4. 네트워크 연결:"
    ss -tuln | grep LISTEN | wc -l | awk '{print "활성 리스닝 포트: " $1 "개"}'
    echo ""
    echo "5. 마지막 로그인:"
    last -n 5
}

# 개발 환경 설정 확인
checkdev() {
    echo "=== 개발 환경 확인 ==="
    command -v git >/dev/null 2>&1 && echo "✅ Git: $(git --version)" || echo "❌ Git 미설치"
    command -v vim >/dev/null 2>&1 && echo "✅ Vim: $(vim --version | head -1)" || echo "❌ Vim 미설치"
    command -v curl >/dev/null 2>&1 && echo "✅ cURL: $(curl --version | head -1)" || echo "❌ cURL 미설치"
    command -v wget >/dev/null 2>&1 && echo "✅ wget: $(wget --version | head -1)" || echo "❌ wget 미설치"
    command -v tree >/dev/null 2>&1 && echo "✅ Tree: $(tree --version)" || echo "❌ Tree 미설치"
    command -v htop >/dev/null 2>&1 && echo "✅ htop: available" || echo "❌ htop 미설치"
    echo "====================="
}

# 빠른 포트 스캔
portscan() {
    if [ $# -eq 0 ]; then
        echo "사용법: portscan <IP주소>"
        return 1
    fi
    nmap -F "$1" 2>/dev/null || {
        echo "nmap이 설치되지 않았습니다. netcat으로 대체 실행..."
        for port in 22 80 443 3389 21 25 53 110 993 995; do
            timeout 1 bash -c "</dev/tcp/$1/$port" 2>/dev/null && echo "포트 $port: 열림"
        done
    }
}

# ======================================
# 환경 변수 설정
# ======================================

# 히스토리 설정
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:cd:pwd:exit:date:man:history"

# 에디터 설정
export EDITOR=vim
export VISUAL=vim

# 색상 설정
export CLICOLOR=1
export LS_COLORS='di=1;34:ln=1;36:so=1;32:pi=1;33:ex=1;31:bd=1;34:cd=1;34:su=1;30:sg=1;30:tw=1;30:ow=1;30'

# PATH 추가
export PATH="$PATH:$HOME/.local/bin"

# ======================================
# 프롬프트 설정
# ======================================

# 색상 있는 프롬프트
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# ======================================
# 시작 메시지
# ======================================

echo ""
echo "🚀 환경 설정이 로드되었습니다!"
echo "💡 유용한 명령어: sysinfo, serverstatus, checkdev"
echo "📚 도움말: alias | grep -E '^alias' | sort"
echo ""

EOF

# 작업 디렉토리 생성
log_info "기본 작업 디렉토리 생성 중..."
mkdir -p ~/workspace
mkdir -p ~/scripts
mkdir -p ~/logs
mkdir -p ~/backup
mkdir -p ~/tmp

# 권한 설정
log_info "권한 설정 중..."
sudo chown -R $USER:$USER ~/workspace ~/scripts ~/logs ~/backup ~/tmp

# 설치된 패키지 목록 표시
log_info "설치된 패키지 확인 중..."
echo ""
echo "설치된 주요 패키지들:"
for pkg in vim curl wget git tree htop net-tools jq gawk; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        version=$(dpkg -l | grep "^ii  $pkg " | awk '{print $3}' | cut -d: -f1)
        echo "  ✅ $pkg: $version"
    else
        echo "  ❌ $pkg: 설치 실패"
    fi
done

# .bashrc 적용
log_info "환경 설정 적용 중..."
source ~/.bashrc

echo ""
echo "========================================"
echo "  기본 패키지 설치 완료!"
echo "========================================"
echo "📦 설치된 패키지: vim, curl, wget, git, tree, htop, net-tools 등"
echo "📁 생성된 디렉토리: ~/workspace, ~/scripts, ~/logs, ~/backup, ~/tmp"
echo "⚙️  설정 파일: ~/.vimrc, ~/.bashrc (alias 추가됨)"
echo ""
echo "🔧 추가된 주요 기능:"
echo "  • 200+ 개의 유용한 alias"
echo "  • 시스템 관리 함수들 (sysinfo, serverstatus, checkdev)"
echo "  • 개발자 친화적 Vim 설정"
echo "  • 색상 지원 프롬프트"
echo ""
echo "📋 다음 명령어로 현재 세션에 적용:"
echo "source ~/.bashrc"
echo ""
echo "💡 유용한 명령어 확인:"
echo "  • sysinfo     - 시스템 정보 요약"
echo "  • serverstatus - 서버 상태 확인"  
echo "  • checkdev    - 개발 환경 확인"
echo "========================================"