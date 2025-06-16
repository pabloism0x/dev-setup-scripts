#!/bin/bash

# Google Cloud CLI 및 도구 설치 스크립트
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
echo "  Google Cloud CLI 및 도구 설치 스크립트"
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
        x86_64) GCP_ARCH="x86_64" ;;
        aarch64|arm64) GCP_ARCH="arm" ;;
        *) 
            log_error "지원하지 않는 아키텍처입니다: $ARCH"
            exit 1
            ;;
    esac
}

# 의존성 패키지 설치
install_dependencies() {
    detect_system
    log_info "감지된 운영체제: $OS $VER ($ARCH)"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian
        log_info "의존성 패키지 설치 중..."
        sudo apt install -y apt-transport-https ca-certificates gnupg curl lsb-release python3 python3-pip
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y curl wget python3 python3-pip
        else
            sudo yum install -y curl wget python3 python3-pip
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "의존성 패키지 설치 중..."
        sudo dnf install -y curl wget python3 python3-pip
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "의존성 패키지 설치 중..."
        sudo zypper install -y curl wget python3 python3-pip
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "의존성 패키지 설치 중..."
        sudo pacman -S --noconfirm curl wget python python-pip
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "의존성 패키지 설치 중..."
        sudo apk add curl wget python3 py3-pip
        
    else
        log_warning "지원하지 않는 운영체제입니다: $OS"
        log_info "의존성 패키지를 수동으로 설치해주세요: curl, wget, python3, pip"
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

# 의존성 패키지 설치
install_dependencies

# Google Cloud CLI 설치
install_gcloud() {
    if command -v gcloud >/dev/null 2>&1; then
        log_info "Google Cloud CLI가 이미 설치되어 있습니다"
        return 0
    fi
    
    log_info "Google Cloud CLI 설치 중..."
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian - 공식 저장소 사용
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        
        sudo apt update
        sudo apt install -y google-cloud-cli
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]] || [[ "$OS" == *"Fedora"* ]]; then
        # RHEL 계열
        sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << 'REPO_EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
REPO_EOF
        
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y google-cloud-cli
        else
            sudo yum install -y google-cloud-cli
        fi
        
    else
        # 다른 배포판 - 스크립트 설치 방법 사용
        log_info "스크립트를 통한 Google Cloud CLI 설치 중..."
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
        source ~/google-cloud-sdk/path.bash.inc
        source ~/google-cloud-sdk/completion.bash.inc
    fi
}

install_gcloud

# Google Cloud CLI 버전 확인
GCLOUD_VERSION=$(gcloud --version | head -n1)
log_success "Google Cloud CLI 설치 완료: $GCLOUD_VERSION"

# 추가 Google Cloud 구성 요소 설치
log_info "Google Cloud 추가 구성 요소 설치 중..."

# Cloud SQL Proxy
gcloud components install cloud_sql_proxy --quiet || log_warning "Cloud SQL Proxy 설치 실패"

# App Engine 확장
gcloud components install app-engine-python app-engine-java app-engine-go --quiet || log_warning "App Engine 확장 설치 실패"

# Cloud Build 로컬 빌더
gcloud components install cloud-build-local --quiet || log_warning "Cloud Build Local 설치 실패"

# Anthos CLI
gcloud components install anthoscli --quiet || log_warning "Anthos CLI 설치 실패"

# Cloud Run 프록시
gcloud components install cloud-run-proxy --quiet || log_warning "Cloud Run Proxy 설치 실패"

# Terraform용 Google Cloud Provider 설치 (선택사항)
if command -v terraform >/dev/null 2>&1; then
    log_info "Terraform Google Cloud Provider 설정 스킵 (필요시 수동 설정)"
fi

# 작업 디렉토리 생성
log_info "Google Cloud 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/gcp
mkdir -p ~/workspace/gcp/app-engine
mkdir -p ~/workspace/gcp/cloud-functions
mkdir -p ~/workspace/gcp/cloud-run
mkdir -p ~/workspace/gcp/compute-engine
mkdir -p ~/workspace/gcp/kubernetes
mkdir -p ~/workspace/gcp/terraform

# .bashrc에 Google Cloud 관련 설정 추가
log_info "Google Cloud 관련 환경 설정 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Google Cloud 개발 환경 설정
# ======================================

# Google Cloud CLI 자동완성
if [ -f ~/google-cloud-sdk/completion.bash.inc ]; then
    source ~/google-cloud-sdk/completion.bash.inc
fi

# Google Cloud CLI 경로 (스크립트 설치 시)
if [ -f ~/google-cloud-sdk/path.bash.inc ]; then
    source ~/google-cloud-sdk/path.bash.inc
fi

# Google Cloud 환경 변수
export GOOGLE_CLOUD_PROJECT=""

# gcloud alias
alias gclogin='gcloud auth login'
alias gclogout='gcloud auth revoke --all'
alias gcproject='gcloud config get-value project'
alias gcprojects='gcloud projects list'
alias gcregion='gcloud config get-value compute/region'
alias gczone='gcloud config get-value compute/zone'

# Compute Engine alias
alias gcelist='gcloud compute instances list'
alias gcestart='gcloud compute instances start'
alias gcestop='gcloud compute instances stop'
alias gcessh='gcloud compute ssh'

# Cloud Storage alias
alias gsls='gsutil ls'
alias gscp='gsutil cp'
alias gsmb='gsutil mb'
alias gsrb='gsutil rb'

# Cloud SQL alias
alias gcsl='gcloud sql instances list'
alias gcsd='gcloud sql databases list'

# App Engine alias
alias gaedeploy='gcloud app deploy'
alias gaelogs='gcloud app logs tail -s default'
alias gaebrowse='gcloud app browse'

# Cloud Functions alias
alias gcflist='gcloud functions list'
alias gcfdeploy='gcloud functions deploy'
alias gcflogs='gcloud functions logs read'

# Cloud Run alias
alias gcrlist='gcloud run services list'
alias gcrdeploy='gcloud run deploy'
alias gcrlogs='gcloud run services logs read'

# GKE alias
alias gkelist='gcloud container clusters list'
alias gkecreds='gcloud container clusters get-credentials'

# Google Cloud 프로젝트 관리 함수
gcuse() {
    if [ $# -eq 0 ]; then
        echo "사용법: gcuse <프로젝트ID>"
        echo "사용 가능한 프로젝트:"
        gcloud projects list --format="table(projectId,name)"
        return 1
    fi
    
    gcloud config set project "$1"
    export GOOGLE_CLOUD_PROJECT="$1"
    echo "✅ Google Cloud 프로젝트 '$1' 활성화"
    echo "현재 사용자: $(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null || echo '인증 필요')"
}

# Google Cloud 리전/존 변경 함수
gcregion() {
    if [ $# -eq 0 ]; then
        echo "현재 리전: $(gcloud config get-value compute/region)"
        echo "현재 존: $(gcloud config get-value compute/zone)"
        echo ""
        echo "주요 Google Cloud 리전:"
        echo "  us-east1         (South Carolina)"
        echo "  us-west1         (Oregon)"
        echo "  europe-west1     (Belgium)"
        echo "  asia-east1       (Taiwan)"
        echo "  asia-northeast1  (Tokyo)"
        echo "  asia-northeast3  (Seoul)"
        echo "  asia-southeast1  (Singapore)"
        return 0
    fi
    
    gcloud config set compute/region "$1"
    echo "✅ Google Cloud 리전을 '$1'로 변경했습니다"
    
    # 존도 같이 설정할지 물어보기
    if [ $# -eq 2 ]; then
        gcloud config set compute/zone "$2"
        echo "✅ Google Cloud 존을 '$2'로 변경했습니다"
    fi
}

# Google Cloud 계정 정보 확인 함수
gcinfo() {
    echo "=== Google Cloud 계정 정보 ==="
    
    # 현재 사용자 정보
    echo "현재 사용자:"
    gcloud auth list --filter=status:ACTIVE --format="table(account,status)" 2>/dev/null || echo "인증이 필요합니다 (gcloud auth login)"
    echo ""
    
    # 현재 설정
    echo "현재 설정:"
    echo "프로젝트: $(gcloud config get-value project 2>/dev/null || echo '설정되지 않음')"
    echo "리전: $(gcloud config get-value compute/region 2>/dev/null || echo '설정되지 않음')"
    echo "존: $(gcloud config get-value compute/zone 2>/dev/null || echo '설정되지 않음')"
    echo ""
    
    # 사용 가능한 프로젝트
    echo "사용 가능한 프로젝트:"
    gcloud projects list --format="table(projectId,name,lifecycleState)" 2>/dev/null || echo "프로젝트 목록을 가져올 수 없습니다"
}

# Google Cloud 리소스 요약 함수
gcsummary() {
    local project=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$project" ]; then
        echo "❌ 프로젝트가 설정되지 않았습니다. gcuse <프로젝트ID>를 실행하세요."
        return 1
    fi
    
    echo "=== Google Cloud 리소스 요약 ($project) ==="
    echo ""
    
    echo "🖥️  Compute Engine 인스턴스:"
    gcloud compute instances list --format="value(name)" | wc -l 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "☁️  Cloud Storage 버킷:"
    gsutil ls 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "🗄️  Cloud SQL 인스턴스:"
    gcloud sql instances list --format="value(name)" | wc -l 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "⚡ Cloud Functions:"
    gcloud functions list --format="value(name)" | wc -l 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "🏃 Cloud Run 서비스:"
    gcloud run services list --format="value(metadata.name)" | wc -l 2>/dev/null || echo "조회 실패"
    echo ""
    
    echo "🎛️  GKE 클러스터:"
    gcloud container clusters list --format="value(name)" | wc -l 2>/dev/null || echo "조회 실패"
}

# Google Cloud 빌링 정보 함수
gcbilling() {
    echo "💰 Google Cloud 빌링 정보:"
    gcloud billing accounts list --format="table(name,displayName,open)" 2>/dev/null || echo "빌링 계정 정보를 확인할 수 없습니다"
    echo ""
    echo "현재 프로젝트 빌링 연결:"
    gcloud billing projects describe "$(gcloud config get-value project)" --format="value(billingAccountName)" 2>/dev/null || echo "빌링 정보를 확인할 수 없습니다"
}

# Google Cloud 프로젝트 초기화 함수
gcinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: gcinit <프로젝트명> [프로젝트타입]"
        echo "프로젝트 타입: app-engine, cloud-function, cloud-run, compute-engine, gke"
        return 1
    fi
    
    local project_name="$1"
    local project_type="${2:-app-engine}"
    
    case "$project_type" in
        "app-engine")
            mkdir -p ~/workspace/gcp/app-engine/"$project_name"
            cd ~/workspace/gcp/app-engine/"$project_name"
            
            # app.yaml 생성
            cat > app.yaml << 'GAE_EOF'
runtime: python39

env_variables:
  ENVIRONMENT: development

handlers:
- url: /static
  static_dir: static

- url: /.*
  script: auto
GAE_EOF

            # main.py 생성
            cat > main.py << 'MAIN_EOF'
from flask import Flask, render_template, request, jsonify
import os

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from App Engine!',
        'environment': os.getenv('ENVIRONMENT', 'production')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
MAIN_EOF

            # requirements.txt 생성
            echo "Flask==2.3.3
gunicorn==21.2.0" > requirements.txt

            echo "✅ App Engine 프로젝트 '$project_name' 생성 완료"
            echo "배포: gcloud app deploy"
            ;;
            
        "cloud-function")
            mkdir -p ~/workspace/gcp/cloud-functions/"$project_name"
            cd ~/workspace/gcp/cloud-functions/"$project_name"
            
            # main.py 생성
            cat > main.py << 'CF_EOF'
import json
from flask import Request
import functions_framework

@functions_framework.http
def hello_world(request: Request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`.
    """
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
        
    return json.dumps({
        'message': f'Hello {name}!',
        'method': request.method
    })
CF_EOF

            # requirements.txt 생성
            echo "functions-framework==3.4.0
Flask==2.3.3" > requirements.txt

            echo "✅ Cloud Function 프로젝트 '$project_name' 생성 완료"
            echo "배포: gcloud functions deploy $project_name --runtime python39 --trigger-http --allow-unauthenticated"
            ;;
            
        "cloud-run")
            mkdir -p ~/workspace/gcp/cloud-run/"$project_name"
            cd ~/workspace/gcp/cloud-run/"$project_name"
            
            # Dockerfile 생성
            cat > Dockerfile << 'CR_DOCKERFILE_EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
CR_DOCKERFILE_EOF

            # main.py 생성
            cat > main.py << 'CR_MAIN_EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from Cloud Run!',
        'service': os.getenv('K_SERVICE', 'unknown'),
        'revision': os.getenv('K_REVISION', 'unknown')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(debug=True, host='0.0.0.0', port=port)
CR_MAIN_EOF

            # requirements.txt 생성
            echo "Flask==2.3.3
gunicorn==21.2.0" > requirements.txt

            echo "✅ Cloud Run 프로젝트 '$project_name' 생성 완료"
            echo "배포: gcloud run deploy $project_name --source . --platform managed --allow-unauthenticated"
            ;;
            
        "compute-engine")
            mkdir -p ~/workspace/gcp/compute-engine/"$project_name"
            cd ~/workspace/gcp/compute-engine/"$project_name"
            
            # startup script 생성
            cat > startup-script.sh << 'CE_STARTUP_EOF'
#!/bin/bash

# Compute Engine 인스턴스 시작 스크립트
apt-get update
apt-get install -y nginx

# 기본 웹페이지 생성
cat > /var/www/html/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Compute Engine</title>
</head>
<body>
    <h1>Hello from Compute Engine!</h1>
    <p>Instance: <span id="hostname"></span></p>
    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
    </script>
</body>
</html>
HTML_EOF

systemctl enable nginx
systemctl start nginx
CE_STARTUP_EOF

            # 인스턴스 생성 스크립트
            cat > create-instance.sh << 'CE_CREATE_EOF'
#!/bin/bash

INSTANCE_NAME="$1"
if [ -z "$INSTANCE_NAME" ]; then
    INSTANCE_NAME="my-instance"
fi

gcloud compute instances create "$INSTANCE_NAME" \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=e2-micro \
    --metadata-from-file startup-script=startup-script.sh \
    --tags=http-server,https-server

gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow HTTP traffic"

echo "✅ 인스턴스 '$INSTANCE_NAME' 생성 완료"
echo "SSH 접속: gcloud compute ssh $INSTANCE_NAME"
CE_CREATE_EOF

            chmod +x create-instance.sh startup-script.sh

            echo "✅ Compute Engine 프로젝트 '$project_name' 생성 완료"
            echo "인스턴스 생성: ./create-instance.sh [인스턴스명]"
            ;;
            
        *)
            echo "❌ 지원하지 않는 프로젝트 타입입니다: $project_type"
            echo "사용 가능한 타입: app-engine, cloud-function, cloud-run, compute-engine"
            ;;
    esac
}

BASHRC_EOF

# Google Cloud 설정 도우미 스크립트 생성
log_info "Google Cloud 설정 도우미 스크립트 생성 중..."
cat > ~/workspace/gcp/gcp-setup-helper.sh << 'HELPER_EOF'
#!/bin/bash

# Google Cloud CLI 설정 도우미 스크립트

echo "========================================"
echo "  Google Cloud CLI 설정 도우미"
echo "========================================"
echo ""

echo "1. Google Cloud 로그인"
echo "2. 프로젝트 설정"
echo "3. 기본 리전/존 설정"
echo "4. 서비스 계정 키 설정"
echo "5. 설정 확인"
echo ""

read -p "선택하세요 (1-5): " choice

case $choice in
    1)
        echo "Google Cloud 로그인을 시작합니다..."
        gcloud auth login
        gcloud auth application-default login
        ;;
    2)
        echo "프로젝트 설정을 시작합니다..."
        echo "사용 가능한 프로젝트:"
        gcloud projects list --format="table(projectId,name)"
        echo ""
        read -p "사용할 프로젝트 ID를 입력하세요: " project_id
        gcloud config set project "$project_id"
        echo "✅ 프로젝트 '$project_id' 설정 완료"
        ;;
    3)
        echo "기본 리전/존 설정을 시작합니다..."
        echo "추천 리전:"
        echo "  asia-northeast3  (Seoul)"
        echo "  asia-northeast1  (Tokyo)"
        echo "  us-east1         (South Carolina)"
        echo ""
        read -p "리전을 입력하세요: " region
        read -p "존을 입력하세요 (예: ${region}-a): " zone
        
        gcloud config set compute/region "$region"
        gcloud config set compute/zone "$zone"
        echo "✅ 리전 '$region', 존 '$zone' 설정 완료"
        ;;
    4)
        echo "서비스 계정 키 설정을 시작합니다..."
        read -p "서비스 계정 키 파일 경로를 입력하세요: " key_file
        if [ -f "$key_file" ]; then
            gcloud auth activate-service-account --key-file="$key_file"
            export GOOGLE_APPLICATION_CREDENTIALS="$key_file"
            echo "✅ 서비스 계정 키 설정 완료"
        else
            echo "❌ 키 파일을 찾을 수 없습니다: $key_file"
        fi
        ;;
    5)
        echo "현재 Google Cloud 설정:"
        echo ""
        echo "=== 인증된 계정 ==="
        gcloud auth list
        echo ""
        echo "=== 현재 설정 ==="
        gcloud config list
        echo ""
        echo "=== 프로젝트 정보 ==="
        gcloud projects describe "$(gcloud config get-value project)" 2>/dev/null || echo "프로젝트가 설정되지 않았습니다"
        ;;
    *)
        echo "잘못된 선택입니다."
        ;;
esac
HELPER_EOF

chmod +x ~/workspace/gcp/gcp-setup-helper.sh

# Google Cloud 개발 템플릿 생성
log_info "Google Cloud 개발 템플릿 생성 중..."
mkdir -p ~/workspace/gcp/templates

# Cloud Function HTTP 템플릿
cat > ~/workspace/gcp/templates/cloud-function-http.py << 'CF_HTTP_EOF'
import json
import logging
from flask import Request
import functions_framework

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def main(request: Request):
    """HTTP Cloud Function 메인 핸들러
    
    Args:
        request (flask.Request): HTTP 요청 객체
        
    Returns:
        JSON 응답
    """
    # CORS 헤더 설정
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    }
    
    # OPTIONS 요청 처리 (CORS preflight)
    if request.method == 'OPTIONS':
        return ('', 204, headers)
    
    try:
        # 요청 데이터 파싱
        if request.method == 'POST':
            request_json = request.get_json(silent=True)
            if request_json and 'name' in request_json:
                name = request_json['name']
            else:
                name = 'World'
        else:
            name = request.args.get('name', 'World')
        
        # 비즈니스 로직
        result = {
            'message': f'Hello {name}!',
            'method': request.method,
            'timestamp': '2024-01-01T00:00:00Z'
        }
        
        logger.info(f"Request processed for: {name}")
        
        return (json.dumps(result), 200, headers)
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        
        error_response = {
            'error': 'Internal Server Error',
            'message': str(e)
        }
        
        return (json.dumps(error_response), 500, headers)
CF_HTTP_EOF

# Cloud Function Pub/Sub 템플릿
cat > ~/workspace/gcp/templates/cloud-function-pubsub.py << 'CF_PUBSUB_EOF'
import base64
import json
import logging
from typing import Any, Dict
import functions_framework

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.cloud_event
def main(cloud_event: Any) -> None:
    """Pub/Sub Cloud Function 메인 핸들러
    
    Args:
        cloud_event: Cloud Event 객체
    """
    try:
        # Pub/Sub 메시지 디코딩
        if 'data' in cloud_event.data:
            message_data = base64.b64decode(cloud_event.data['data']).decode('utf-8')
            message_json = json.loads(message_data)
        else:
            message_json = {}
        
        # 메시지 속성 가져오기
        attributes = cloud_event.data.get('attributes', {})
        
        logger.info(f"Received message: {message_json}")
        logger.info(f"Message attributes: {attributes}")
        
        # 비즈니스 로직 처리
        process_message(message_json, attributes)
        
        logger.info("Message processed successfully")
        
    except Exception as e:
        logger.error(f"Error processing Pub/Sub message: {str(e)}")
        raise

def process_message(data: Dict[str, Any], attributes: Dict[str, str]) -> None:
    """메시지 처리 로직
    
    Args:
        data: 메시지 데이터
        attributes: 메시지 속성
    """
    # 여기에 실제 비즈니스 로직 구현
    message_type = attributes.get('messageType', 'unknown')
    
    if message_type == 'user_event':
        handle_user_event(data)
    elif message_type == 'system_event':
        handle_system_event(data)
    else:
        logger.warning(f"Unknown message type: {message_type}")

def handle_user_event(data: Dict[str, Any]) -> None:
    """사용자 이벤트 처리"""
    user_id = data.get('userId')
    event_type = data.get('eventType')
    logger.info(f"Processing user event: {event_type} for user {user_id}")

def handle_system_event(data: Dict[str, Any]) -> None:
    """시스템 이벤트 처리"""
    system_id = data.get('systemId')
    event_type = data.get('eventType')
    logger.info(f"Processing system event: {event_type} for system {system_id}")
CF_PUBSUB_EOF

# App Engine 표준 환경 템플릿
cat > ~/workspace/gcp/templates/app-engine-standard.py << 'GAE_STD_EOF'
from flask import Flask, request, jsonify, render_template
import os
import logging
from google.cloud import ndb

# Flask 앱 초기화
app = Flask(__name__)

# NDB 클라이언트 초기화 (Datastore 사용시)
ndb_client = ndb.Client()

# 로깅 설정
if os.getenv('GAE_ENV', '').startswith('standard'):
    # 프로덕션 환경
    import google.cloud.logging
    client = google.cloud.logging.Client()
    client.setup_logging()
else:
    # 로컬 개발 환경
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

# Datastore 모델 예시
class User(ndb.Model):
    name = ndb.StringProperty(required=True)
    email = ndb.StringProperty(required=True)
    created_at = ndb.DateTimeProperty(auto_now_add=True)
    updated_at = ndb.DateTimeProperty(auto_now=True)

@app.route('/')
def index():
    """메인 페이지"""
    return jsonify({
        'message': 'Hello from App Engine!',
        'environment': os.getenv('GAE_ENV', 'local'),
        'service': os.getenv('GAE_SERVICE', 'default'),
        'version': os.getenv('GAE_VERSION', 'unknown')
    })

@app.route('/health')
def health():
    """헬스 체크 엔드포인트"""
    return jsonify({'status': 'healthy'})

@app.route('/users', methods=['GET', 'POST'])
def users():
    """사용자 관리 API"""
    with ndb_client.context():
        if request.method == 'GET':
            # 사용자 목록 조회
            users = User.query().fetch()
            return jsonify({
                'users': [
                    {
                        'id': user.key.id(),
                        'name': user.name,
                        'email': user.email,
                        'created_at': user.created_at.isoformat() if user.created_at else None
                    }
                    for user in users
                ]
            })
        
        elif request.method == 'POST':
            # 새 사용자 생성
            data = request.get_json()
            
            if not data or 'name' not in data or 'email' not in data:
                return jsonify({'error': 'name과 email이 필요합니다'}), 400
            
            user = User(
                name=data['name'],
                email=data['email']
            )
            user.put()
            
            return jsonify({
                'message': '사용자가 생성되었습니다',
                'user': {
                    'id': user.key.id(),
                    'name': user.name,
                    'email': user.email
                }
            }), 201

@app.errorhandler(500)
def server_error(e):
    logger.exception('An error occurred during a request.')
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # 로컬 개발 서버
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
GAE_STD_EOF

# Cloud Run 템플릿
cat > ~/workspace/gcp/templates/cloud-run-service.py << 'CR_SERVICE_EOF'
from flask import Flask, request, jsonify
import os
import logging
import signal
import sys
from concurrent.futures import ThreadPoolExecutor
import threading

# Flask 앱 초기화
app = Flask(__name__)

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 글로벌 변수
executor = ThreadPoolExecutor(max_workers=10)
shutdown_event = threading.Event()

@app.route('/')
def index():
    """메인 엔드포인트"""
    return jsonify({
        'message': 'Hello from Cloud Run!',
        'service': os.getenv('K_SERVICE', 'unknown'),
        'revision': os.getenv('K_REVISION', 'unknown'),
        'configuration': os.getenv('K_CONFIGURATION', 'unknown')
    })

@app.route('/health')
def health():
    """헬스 체크 엔드포인트"""
    return jsonify({
        'status': 'healthy',
        'timestamp': '2024-01-01T00:00:00Z'
    })

@app.route('/api/process', methods=['POST'])
def process_data():
    """데이터 처리 API"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'JSON 데이터가 필요합니다'}), 400
        
        # 비동기 처리 예시
        future = executor.submit(process_async_task, data)
        result = future.result(timeout=30)
        
        return jsonify({
            'message': '처리 완료',
            'result': result
        })
        
    except Exception as e:
        logger.error(f"Error processing data: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

def process_async_task(data):
    """비동기 작업 처리"""
    # 여기에 실제 비즈니스 로직 구현
    import time
    time.sleep(1)  # 시뮬레이션
    
    return {
        'processed_items': len(data) if isinstance(data, list) else 1,
        'status': 'completed'
    }

def signal_handler(signum, frame):
    """Graceful shutdown 처리"""
    logger.info(f"Received signal {signum}, shutting down gracefully...")
    shutdown_event.set()
    executor.shutdown(wait=True)
    sys.exit(0)

# Signal handler 등록
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(debug=False, host='0.0.0.0', port=port, threaded=True)
CR_SERVICE_EOF

# 완료 메시지
echo ""
echo "========================================"
echo "  Google Cloud CLI 및 도구 설치 완료!"
echo "========================================"
echo "Google Cloud CLI 버전: $(gcloud --version | head -n1)"
echo ""
echo "📁 작업 디렉토리:"
echo "  • ~/workspace/gcp/ - Google Cloud 프로젝트들"
echo "  • ~/workspace/gcp/app-engine/ - App Engine 프로젝트들"
echo "  • ~/workspace/gcp/cloud-functions/ - Cloud Functions 프로젝트들"
echo "  • ~/workspace/gcp/cloud-run/ - Cloud Run 프로젝트들"
echo "  • ~/workspace/gcp/templates/ - 개발 템플릿들"
echo ""
echo "🔧 사용 가능한 명령어:"
echo "  • gcinfo - Google Cloud 계정 정보"
echo "  • gcuse <프로젝트ID> - 프로젝트 변경"
echo "  • gcregion [리전] [존] - 리전/존 확인/변경"
echo "  • gcsummary - Google Cloud 리소스 요약"
echo "  • gcinit <프로젝트명> [타입] - 새 프로젝트 초기화"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "⚙️  Google Cloud CLI 설정:"
echo "1. 로그인: gcloud auth login"
echo "2. 프로젝트 설정: gcloud config set project PROJECT_ID"
echo "3. 설정 도우미: ~/workspace/gcp/gcp-setup-helper.sh"
echo ""
echo "🧪 테스트 명령어:"
echo "gcloud auth login"
echo "gcinit my-first-gcp-project app-engine"
echo "========================================"