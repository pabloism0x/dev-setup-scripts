#!/bin/bash

# Linux 보안 강화 설정 스크립트
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
echo "  Linux 보안 강화 설정 스크립트"
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

# 보안 도구 설치 함수
install_security_tools() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian
        log_info "보안 도구 설치 중..."
        sudo apt install -y ufw fail2ban unattended-upgrades apt-listchanges aide rkhunter chkrootkit lynis clamav clamav-daemon
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "보안 도구 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y firewalld fail2ban dnf-automatic aide rkhunter chkrootkit lynis clamav clamav-update
        else
            sudo yum install -y firewalld fail2ban yum-cron aide rkhunter chkrootkit lynis clamav clamav-update
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "보안 도구 설치 중..."
        sudo dnf install -y firewalld fail2ban dnf-automatic aide rkhunter chkrootkit lynis clamav clamav-update
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "보안 도구 설치 중..."
        sudo zypper install -y firewalld fail2ban aide rkhunter chkrootkit lynis clamav
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "보안 도구 설치 중..."
        sudo pacman -S --noconfirm ufw fail2ban aide rkhunter chkrootkit lynis clamav
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "보안 도구 설치 중..."
        sudo apk add ufw fail2ban aide rkhunter chkrootkit lynis clamav clamav-daemon
        
    else
        log_error "지원하지 않는 운영체제입니다: $OS"
        log_info "수동으로 보안 도구를 설치해주세요"
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

# 보안 도구 설치
install_security_tools

# 방화벽 설정 (UFW 또는 firewalld)
setup_firewall() {
    if command -v ufw >/dev/null 2>&1; then
        log_info "UFW 방화벽 설정 중..."
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        
        # 기본 포트 허용
        sudo ufw allow ssh
        sudo ufw allow 80/tcp   # HTTP
        sudo ufw allow 443/tcp  # HTTPS
        
        # 개발용 포트들 (필요시 주석 해제)
        # sudo ufw allow 3000/tcp  # React dev server
        # sudo ufw allow 8000/tcp  # Django/FastAPI
        # sudo ufw allow 5000/tcp  # Flask
        
        sudo ufw --force enable
        log_success "UFW 방화벽 활성화 완료"
        
    elif command -v firewall-cmd >/dev/null 2>&1; then
        log_info "firewalld 방화벽 설정 중..."
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        
        # 기본 서비스 허용
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        
        sudo firewall-cmd --reload
        log_success "firewalld 방화벽 활성화 완료"
    else
        log_warning "방화벽 도구를 찾을 수 없습니다"
    fi
}

setup_firewall

# SSH 보안 강화
log_info "SSH 보안 설정 강화 중..."
SSH_CONFIG="/etc/ssh/sshd_config"

# SSH 설정 백업
sudo cp "$SSH_CONFIG" "$SSH_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"

# SSH 보안 설정 적용
sudo sed -i 's/#Port 22/Port 22/' "$SSH_CONFIG"
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' "$SSH_CONFIG"
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' "$SSH_CONFIG"
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSH_CONFIG"
sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' "$SSH_CONFIG"
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' "$SSH_CONFIG"
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/' "$SSH_CONFIG"
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' "$SSH_CONFIG"

# SSH 프로토콜 2만 사용
echo "Protocol 2" | sudo tee -a "$SSH_CONFIG" > /dev/null

log_success "SSH 보안 설정 완료"

# Fail2Ban 설정
log_info "Fail2Ban 설정 중..."
if command -v fail2ban-server >/dev/null 2>&1; then
    # Fail2Ban jail 설정
    sudo tee /etc/fail2ban/jail.local > /dev/null << 'FAIL2BAN_EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[apache-auth]
enabled = false

[apache-badbots]
enabled = false

[apache-noscript]
enabled = false

[apache-overflows]
enabled = false

[nginx-http-auth]
enabled = false

[nginx-limit-req]
enabled = false
FAIL2BAN_EOF

    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    log_success "Fail2Ban 설정 완료"
else
    log_warning "Fail2Ban이 설치되지 않았습니다"
fi

# 자동 업데이트 설정
setup_auto_updates() {
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        log_info "자동 보안 업데이트 설정 중..."
        
        # unattended-upgrades 설정
        sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null << 'UNATTENDED_EOF'
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}-security";
        "${distro_id}ESMApps:${distro_codename}-apps-security";
        "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
UNATTENDED_EOF

        sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'AUTO_UPGRADES_EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
AUTO_UPGRADES_EOF

        log_success "자동 보안 업데이트 설정 완료"
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]] || [[ "$OS" == *"Fedora"* ]]; then
        log_info "자동 업데이트 설정 중..."
        
        if command -v dnf >/dev/null 2>&1; then
            # dnf-automatic 설정
            sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
            sudo systemctl enable --now dnf-automatic.timer
        else
            # yum-cron 설정
            sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
            sudo systemctl enable --now yum-cron
        fi
        
        log_success "자동 업데이트 설정 완료"
    fi
}

setup_auto_updates

# 시스템 감사 도구 설정 (AIDE)
log_info "시스템 무결성 검사 도구 설정 중..."
if command -v aide >/dev/null 2>&1; then
    # AIDE 데이터베이스 초기화
    sudo aide --init || sudo aideinit
    
    if [ -f /var/lib/aide/aide.db.new ]; then
        sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    fi
    
    # 주간 AIDE 검사 크론잡 추가
    echo "0 2 * * 0 root /usr/bin/aide --check | mail -s 'AIDE 무결성 검사 보고서' root" | sudo tee -a /etc/crontab > /dev/null
    
    log_success "AIDE 시스템 무결성 검사 설정 완료"
else
    log_warning "AIDE가 설치되지 않았습니다"
fi

# ClamAV 안티바이러스 설정
log_info "ClamAV 안티바이러스 설정 중..."
if command -v clamscan >/dev/null 2>&1; then
    # ClamAV 바이러스 정의 업데이트
    sudo freshclam || true
    
    # 일일 바이러스 검사 스크립트 생성
    sudo tee /usr/local/bin/daily-clamscan.sh > /dev/null << 'CLAMSCAN_EOF'
#!/bin/bash

SCAN_DIR="/home"
LOG_FILE="/var/log/clamav/daily-scan.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$DATE] ClamAV 일일 스캔 시작" >> $LOG_FILE
clamscan -r --infected --remove=yes $SCAN_DIR >> $LOG_FILE 2>&1
echo "[$DATE] ClamAV 일일 스캔 완료" >> $LOG_FILE
CLAMSCAN_EOF

    sudo chmod +x /usr/local/bin/daily-clamscan.sh
    sudo mkdir -p /var/log/clamav
    
    # 일일 바이러스 검사 크론잡 추가
    echo "0 3 * * * root /usr/local/bin/daily-clamscan.sh" | sudo tee -a /etc/crontab > /dev/null
    
    log_success "ClamAV 안티바이러스 설정 완료"
else
    log_warning "ClamAV가 설치되지 않았습니다"
fi

# 커널 보안 설정
log_info "커널 보안 매개변수 설정 중..."
sudo tee /etc/sysctl.d/99-security.conf > /dev/null << 'SYSCTL_EOF'
# 네트워크 보안 설정
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# IPv6 설정
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# 기타 보안 설정
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
SYSCTL_EOF

sudo sysctl -p /etc/sysctl.d/99-security.conf
log_success "커널 보안 매개변수 설정 완료"

# .bashrc에 보안 관련 alias 추가
log_info "보안 관련 명령어 alias 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# 보안 관련 Alias 및 함수
# ======================================

# 방화벽 관리
alias fwstatus='sudo ufw status verbose 2>/dev/null || sudo firewall-cmd --list-all 2>/dev/null'
alias fwlist='sudo ufw status numbered 2>/dev/null || sudo firewall-cmd --list-services 2>/dev/null'

# 시스템 보안 상태 확인
alias secstatus='sudo fail2ban-client status 2>/dev/null; echo ""; sudo lynis show version 2>/dev/null'

# 로그 확인
alias authlog='sudo tail -f /var/log/auth.log 2>/dev/null || sudo tail -f /var/log/secure 2>/dev/null'
alias syslog='sudo tail -f /var/log/syslog 2>/dev/null || sudo tail -f /var/log/messages 2>/dev/null'

# 네트워크 연결 확인
alias netcon='sudo netstat -tuln'
alias ports='sudo ss -tuln'

# 보안 검사 함수
seccheck() {
    echo "=== 시스템 보안 상태 검사 ==="
    echo ""
    
    echo "🔥 방화벽 상태:"
    sudo ufw status 2>/dev/null || sudo firewall-cmd --state 2>/dev/null || echo "방화벽 정보를 확인할 수 없습니다"
    echo ""
    
    echo "🚫 Fail2Ban 상태:"
    sudo fail2ban-client status 2>/dev/null || echo "Fail2Ban이 설치되지 않았습니다"
    echo ""
    
    echo "🔍 활성 네트워크 연결:"
    sudo ss -tuln | head -10
    echo ""
    
    echo "👤 최근 로그인 사용자:"
    last | head -5
    echo ""
    
    echo "⚠️  실패한 로그인 시도:"
    sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || \
    sudo grep "Failed password" /var/log/secure 2>/dev/null | tail -5 || \
    echo "로그 파일을 찾을 수 없습니다"
}

# 보안 스캔 함수
secscan() {
    echo "🔍 시스템 보안 스캔 실행 중..."
    
    if command -v lynis >/dev/null 2>&1; then
        echo "Lynis 보안 감사 실행 중..."
        sudo lynis audit system --quick
    else
        echo "Lynis가 설치되지 않았습니다"
    fi
    
    if command -v rkhunter >/dev/null 2>&1; then
        echo "RKHunter 루트킷 검사 실행 중..."
        sudo rkhunter --check --skip-keypress --report-warnings-only
    else
        echo "RKHunter가 설치되지 않았습니다"
    fi
    
    if command -v chkrootkit >/dev/null 2>&1; then
        echo "Chkrootkit 루트킷 검사 실행 중..."
        sudo chkrootkit
    else
        echo "Chkrootkit이 설치되지 않았습니다"
    fi
}

# 바이러스 스캔 함수
viruscan() {
    if [ $# -eq 0 ]; then
        echo "사용법: viruscan <디렉토리경로>"
        echo "예시: viruscan /home"
        return 1
    fi
    
    if command -v clamscan >/dev/null 2>&1; then
        echo "🦠 ClamAV 바이러스 스캔 실행 중: $1"
        sudo clamscan -r --infected --bell "$1"
    else
        echo "ClamAV가 설치되지 않았습니다"
    fi
}

# 포트 스캔 확인 함수
portscan() {
    if [ $# -eq 0 ]; then
        TARGET="localhost"
    else
        TARGET="$1"
    fi
    
    echo "🔍 $TARGET 포트 스캔 중..."
    
    if command -v nmap >/dev/null 2>&1; then
        nmap -sT -O "$TARGET"
    else
        echo "nmap이 설치되지 않았습니다. netcat으로 기본 포트 확인 중..."
        for port in 22 80 443 3000 8000 5432 3306; do
            timeout 1 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null && \
            echo "포트 $port: 열림" || echo "포트 $port: 닫힘"
        done
    fi
}

# SSH 키 생성 함수
sshkeygen() {
    if [ $# -eq 0 ]; then
        KEY_NAME="id_rsa_$(date +%Y%m%d)"
    else
        KEY_NAME="$1"
    fi
    
    echo "🔐 SSH 키 쌍 생성 중: $KEY_NAME"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/"$KEY_NAME" -C "$(whoami)@$(hostname)-$(date +%Y%m%d)"
    
    echo "✅ SSH 키 생성 완료:"
    echo "공개키: ~/.ssh/$KEY_NAME.pub"
    echo "개인키: ~/.ssh/$KEY_NAME"
    echo ""
    echo "서버에 공개키 복사:"
    echo "ssh-copy-id -i ~/.ssh/$KEY_NAME.pub user@server"
}

BASHRC_EOF

# 보안 모니터링 스크립트 생성
log_info "보안 모니터링 스크립트 생성 중..."
sudo tee /usr/local/bin/security-report.sh > /dev/null << 'SECURITY_REPORT_EOF'
#!/bin/bash

# 보안 상태 보고서 생성 스크립트
REPORT_FILE="/var/log/security-report-$(date +%Y%m%d).log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "=======================================" > $REPORT_FILE
echo "시스템 보안 상태 보고서" >> $REPORT_FILE
echo "생성일시: $DATE" >> $REPORT_FILE
echo "=======================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 시스템 정보
echo "=== 시스템 정보 ===" >> $REPORT_FILE
uname -a >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 방화벽 상태
echo "=== 방화벽 상태 ===" >> $REPORT_FILE
ufw status verbose 2>/dev/null >> $REPORT_FILE || firewall-cmd --list-all 2>/dev/null >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Fail2Ban 상태
echo "=== Fail2Ban 상태 ===" >> $REPORT_FILE
fail2ban-client status 2>/dev/null >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 최근 로그인
echo "=== 최근 로그인 (최근 10개) ===" >> $REPORT_FILE
last | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 실패한 로그인 시도
echo "=== 실패한 로그인 시도 (최근 10개) ===" >> $REPORT_FILE
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 >> $REPORT_FILE || \
grep "Failed password" /var/log/secure 2>/dev/null | tail -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 네트워크 연결
echo "=== 활성 네트워크 연결 ===" >> $REPORT_FILE
ss -tuln >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 디스크 사용량
echo "=== 디스크 사용량 ===" >> $REPORT_FILE
df -h >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "보고서 생성 완료: $REPORT_FILE"
SECURITY_REPORT_EOF

sudo chmod +x /usr/local/bin/security-report.sh

# 주간 보안 보고서 크론잡 추가
echo "0 1 * * 0 root /usr/local/bin/security-report.sh" | sudo tee -a /etc/crontab > /dev/null

# SSH 서비스 재시작
log_info "SSH 서비스 재시작 중..."
sudo systemctl restart sshd || sudo systemctl restart ssh

# 완료 메시지
echo ""
echo "========================================"
echo "  Linux 보안 강화 설정 완료!"
echo "========================================"
echo ""
echo "🔐 적용된 보안 설정:"
echo "  • 방화벽 활성화 (SSH, HTTP, HTTPS 허용)"
echo "  • SSH 보안 강화 (루트 로그인 차단, 재시도 제한)"
echo "  • Fail2Ban 침입 탐지 시스템"
echo "  • 자동 보안 업데이트"
echo "  • 시스템 무결성 검사 (AIDE)"
echo "  • 안티바이러스 (ClamAV)"
echo "  • 커널 보안 매개변수 최적화"
echo ""
echo "🔧 사용 가능한 보안 명령어:"
echo "  • seccheck - 보안 상태 확인"
echo "  • secscan - 전체 보안 스캔"
echo "  • viruscan <경로> - 바이러스 스캔"
echo "  • portscan [호스트] - 포트 스캔"
echo "  • sshkeygen [키이름] - SSH 키 생성"
echo "  • fwstatus - 방화벽 상태"
echo "  • authlog - 인증 로그 확인"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "⚠️  중요 보안 권고사항:"
echo "  1. SSH 키 기반 인증 사용 권장"
echo "  2. 정기적인 시스템 업데이트"
echo "  3. 강력한 암호 정책 사용"
echo "  4. 불필요한 서비스 비활성화"
echo "  5. 로그 정기 확인"
echo ""
echo "🧪 보안 상태 확인:"
echo "seccheck"
echo "========================================"