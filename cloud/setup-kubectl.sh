#!/bin/bash

# Kubernetes 도구 설치 스크립트
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
echo "  Kubernetes 도구 설치 스크립트"
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
        x86_64) K8S_ARCH="amd64" ;;
        aarch64|arm64) K8S_ARCH="arm64" ;;
        armv7l) K8S_ARCH="arm" ;;
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
        sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y curl wget
        else
            sudo yum install -y curl wget
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "의존성 패키지 설치 중..."
        sudo dnf install -y curl wget
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "의존성 패키지 설치 중..."
        sudo zypper install -y curl wget
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "의존성 패키지 설치 중..."
        sudo pacman -S --noconfirm curl wget
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "의존성 패키지 설치 중..."
        sudo apk add curl wget
        
    else
        log_warning "지원하지 않는 운영체제입니다: $OS"
        log_info "의존성 패키지를 수동으로 설치해주세요: curl, wget"
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

# kubectl 설치
install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        log_info "kubectl이 이미 설치되어 있습니다"
        return 0
    fi
    
    log_info "kubectl 설치 중..."
    
    # kubectl 최신 버전 확인
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    
    # kubectl 다운로드 및 설치
    cd /tmp
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${K8S_ARCH}/kubectl"
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${K8S_ARCH}/kubectl.sha256"
    
    # 체크섬 검증
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    
    # 설치
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # 정리
    rm -f kubectl kubectl.sha256
    
    log_success "kubectl 설치 완료"
}

install_kubectl

# kubectl 버전 확인
KUBECTL_VERSION=$(kubectl version --client --output=yaml | grep gitVersion | cut -d'"' -f2)
log_success "kubectl 설치 확인: $KUBECTL_VERSION"

# Helm 설치
log_info "Helm 설치 중..."
if ! command -v helm >/dev/null 2>&1; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "Helm 설치 완료"
else
    log_info "Helm이 이미 설치되어 있습니다"
fi

# k9s 설치 (Kubernetes CLI UI)
log_info "k9s 설치 중..."
if ! command -v k9s >/dev/null 2>&1; then
    cd /tmp
    
    # k9s 최신 버전 확인
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    
    # k9s 다운로드
    K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${K8S_ARCH}.tar.gz"
    wget -q "$K9S_URL" -O k9s.tar.gz
    
    # 압축 해제 및 설치
    tar -xzf k9s.tar.gz
    sudo mv k9s /usr/local/bin/
    
    # 정리
    rm -f k9s.tar.gz LICENSE README.md
    
    log_success "k9s 설치 완료"
else
    log_info "k9s가 이미 설치되어 있습니다"
fi

# kubectx와 kubens 설치 (컨텍스트 및 네임스페이스 전환 도구)
log_info "kubectx 및 kubens 설치 중..."
if ! command -v kubectx >/dev/null 2>&1; then
    cd /tmp
    
    # kubectx 다운로드
    git clone https://github.com/ahmetb/kubectx.git
    sudo mv kubectx/kubectx /usr/local/bin/
    sudo mv kubectx/kubens /usr/local/bin/
    
    # 정리
    rm -rf kubectx/
    
    log_success "kubectx 및 kubens 설치 완료"
else
    log_info "kubectx가 이미 설치되어 있습니다"
fi

# kustomize 설치
log_info "kustomize 설치 중..."
if ! command -v kustomize >/dev/null 2>&1; then
    cd /tmp
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    log_success "kustomize 설치 완료"
else
    log_info "kustomize가 이미 설치되어 있습니다"
fi

# stern 설치 (다중 파드 로그 확인 도구)
log_info "stern 설치 중..."
if ! command -v stern >/dev/null 2>&1; then
    cd /tmp
    
    # stern 최신 버전 확인
    STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | grep tag_name | cut -d '"' -f 4)
    
    # stern 다운로드
    STERN_URL="https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_${K8S_ARCH}.tar.gz"
    wget -q "$STERN_URL" -O stern.tar.gz
    
    # 압축 해제 및 설치
    tar -xzf stern.tar.gz
    sudo mv stern /usr/local/bin/
    
    # 정리
    rm -f stern.tar.gz LICENSE README.md
    
    log_success "stern 설치 완료"
else
    log_info "stern이 이미 설치되어 있습니다"
fi

# kubectl 플러그인 설치 (krew)
log_info "kubectl 플러그인 매니저 krew 설치 중..."
if ! kubectl krew version >/dev/null 2>&1; then
    cd /tmp
    
    # krew 설치
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${K8S_ARCH}.tar.gz"
    tar zxvf krew-linux_${K8S_ARCH}.tar.gz
    KREW=./krew-linux_${K8S_ARCH}
    "$KREW" install krew
    
    # 정리
    rm -f krew-*
    
    log_success "krew 설치 완료"
else
    log_info "krew가 이미 설치되어 있습니다"
fi

# 작업 디렉토리 생성
log_info "Kubernetes 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/kubernetes
mkdir -p ~/workspace/kubernetes/manifests
mkdir -p ~/workspace/kubernetes/helm-charts
mkdir -p ~/workspace/kubernetes/kustomize
mkdir -p ~/.kube

# .bashrc에 Kubernetes 관련 설정 추가
log_info "Kubernetes 관련 환경 설정 추가 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Kubernetes 개발 환경 설정
# ======================================

# kubectl 자동완성
source <(kubectl completion bash)
complete -F __start_kubectl k

# krew PATH 추가
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubectl alias
alias k='kubectl'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kdes='kubectl describe'
alias kedit='kubectl edit'
alias kget='kubectl get'
alias klogs='kubectl logs'
alias kpf='kubectl port-forward'
alias kexec='kubectl exec -it'

# 네임스페이스 관련 alias
alias kgns='kubectl get namespaces'
alias kcns='kubens'

# 컨텍스트 관련 alias
alias kctx='kubectx'
alias kgctx='kubectl config current-context'

# 리소스 확인 alias
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgi='kubectl get ingress'
alias kgn='kubectl get nodes'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'

# 상세 정보 확인 alias
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'

# 로그 확인 alias
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs --previous'

# 실행 및 디버깅 alias
alias krun='kubectl run'
alias kdebug='kubectl run debug-pod --image=busybox --rm -it --restart=Never --'

# Helm alias
alias h='helm'
alias hls='helm list'
alias his='helm install'
alias hup='helm upgrade'
alias hun='helm uninstall'
alias hsearch='helm search'

# k9s alias
alias k9='k9s'

# Kubernetes 컨텍스트 정보 함수
kinfo() {
    echo "=== Kubernetes 클러스터 정보 ==="
    echo "현재 컨텍스트: $(kubectl config current-context 2>/dev/null || echo '설정되지 않음')"
    echo "현재 네임스페이스: $(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo 'default')"
    echo ""
    
    if kubectl cluster-info >/dev/null 2>&1; then
        echo "클러스터 정보:"
        kubectl cluster-info
        echo ""
        
        echo "노드 정보:"
        kubectl get nodes --output=wide
        echo ""
        
        echo "네임스페이스 목록:"
        kubectl get namespaces
    else
        echo "❌ 클러스터에 연결할 수 없습니다"
    fi
}

# Kubernetes 리소스 요약 함수
ksummary() {
    echo "=== Kubernetes 리소스 요약 ==="
    echo ""
    
    echo "🖥️  노드:"
    kubectl get nodes --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "📦 네임스페이스:"
    kubectl get namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "🚀 파드 (전체):"
    kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "📋 디플로이먼트:"
    kubectl get deployments --all-namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "🌐 서비스:"
    kubectl get services --all-namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "🔧 컨피그맵:"
    kubectl get configmaps --all-namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
    echo ""
    
    echo "🔐 시크릿:"
    kubectl get secrets --all-namespaces --no-headers 2>/dev/null | wc -l || echo "조회 실패"
}

# 파드 상태 확인 함수
kstatus() {
    local namespace="${1:-}"
    
    if [ -n "$namespace" ]; then
        echo "=== 파드 상태 ($namespace 네임스페이스) ==="
        kubectl get pods -n "$namespace" --output=wide
    else
        echo "=== 파드 상태 (현재 네임스페이스) ==="
        kubectl get pods --output=wide
    fi
    
    echo ""
    echo "문제가 있는 파드:"
    if [ -n "$namespace" ]; then
        kubectl get pods -n "$namespace" --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || echo "없음"
    else
        kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || echo "없음"
    fi
}

# 리소스 사용량 확인 함수
kresources() {
    echo "=== 노드 리소스 사용량 ==="
    kubectl top nodes 2>/dev/null || echo "metrics-server가 설치되지 않았습니다"
    echo ""
    
    echo "=== 파드 리소스 사용량 (상위 10개) ==="
    kubectl top pods --all-namespaces --sort-by=cpu 2>/dev/null | head -11 || echo "metrics-server가 설치되지 않았습니다"
}

# 파드 로그 실시간 확인 함수
klive() {
    if [ $# -eq 0 ]; then
        echo "사용법: klive <파드명> [네임스페이스]"
        echo "현재 네임스페이스의 파드:"
        kubectl get pods --output=custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp
        return 1
    fi
    
    local pod_name="$1"
    local namespace="${2:-}"
    
    if [ -n "$namespace" ]; then
        kubectl logs -f "$pod_name" -n "$namespace"
    else
        kubectl logs -f "$pod_name"
    fi
}

# 파드 접속 함수
kenter() {
    if [ $# -eq 0 ]; then
        echo "사용법: kenter <파드명> [네임스페이스] [컨테이너명]"
        echo "현재 네임스페이스의 파드:"
        kubectl get pods --output=custom-columns=NAME:.metadata.name,STATUS:.status.phase,CONTAINERS:.spec.containers[*].name
        return 1
    fi
    
    local pod_name="$1"
    local namespace="${2:-}"
    local container="${3:-}"
    
    local cmd="kubectl exec -it $pod_name"
    
    if [ -n "$namespace" ]; then
        cmd="$cmd -n $namespace"
    fi
    
    if [ -n "$container" ]; then
        cmd="$cmd -c $container"
    fi
    
    cmd="$cmd -- /bin/bash"
    
    echo "🔗 파드에 접속 중: $pod_name"
    eval "$cmd" 2>/dev/null || eval "${cmd//bash/sh}"
}

# 포트 포워딩 함수
kforward() {
    if [ $# -lt 2 ]; then
        echo "사용법: kforward <파드명> <로컬포트:파드포트> [네임스페이스]"
        echo "예시: kforward my-app 8080:80"
        return 1
    fi
    
    local pod_name="$1"
    local ports="$2"
    local namespace="${3:-}"
    
    local cmd="kubectl port-forward $pod_name $ports"
    
    if [ -n "$namespace" ]; then
        cmd="$cmd -n $namespace"
    fi
    
    echo "🔌 포트 포워딩 시작: $pod_name ($ports)"
    echo "Ctrl+C로 중지하세요"
    eval "$cmd"
}

# Kubernetes 매니페스트 생성 함수
kgenerate() {
    if [ $# -eq 0 ]; then
        echo "사용법: kgenerate <타입> <이름> [옵션]"
        echo "타입: deployment, service, configmap, secret, ingress"
        return 1
    fi
    
    local resource_type="$1"
    local resource_name="$2"
    
    case "$resource_type" in
        "deployment"|"deploy")
            kubectl create deployment "$resource_name" --image=nginx --dry-run=client -o yaml > "${resource_name}-deployment.yaml"
            echo "✅ ${resource_name}-deployment.yaml 생성 완료"
            ;;
        "service"|"svc")
            kubectl create service clusterip "$resource_name" --tcp=80:80 --dry-run=client -o yaml > "${resource_name}-service.yaml"
            echo "✅ ${resource_name}-service.yaml 생성 완료"
            ;;
        "configmap"|"cm")
            kubectl create configmap "$resource_name" --from-literal=key1=value1 --dry-run=client -o yaml > "${resource_name}-configmap.yaml"
            echo "✅ ${resource_name}-configmap.yaml 생성 완료"
            ;;
        "secret")
            kubectl create secret generic "$resource_name" --from-literal=key1=value1 --dry-run=client -o yaml > "${resource_name}-secret.yaml"
            echo "✅ ${resource_name}-secret.yaml 생성 완료"
            ;;
        *)
            echo "❌ 지원하지 않는 리소스 타입입니다: $resource_type"
            ;;
    esac
}

# 클러스터 헬스 체크 함수
khealthcheck() {
    echo "=== Kubernetes 클러스터 헬스 체크 ==="
    echo ""
    
    echo "🔍 API 서버 연결:"
    if kubectl cluster-info >/dev/null 2>&1; then
        echo "✅ 정상"
    else
        echo "❌ 실패"
        return 1
    fi
    
    echo ""
    echo "🖥️  노드 상태:"
    kubectl get nodes --no-headers | while read line; do
        node_name=$(echo $line | awk '{print $1}')
        node_status=$(echo $line | awk '{print $2}')
        if [ "$node_status" = "Ready" ]; then
            echo "✅ $node_name: Ready"
        else
            echo "❌ $node_name: $node_status"
        fi
    done
    
    echo ""
    echo "📦 시스템 파드 상태:"
    kubectl get pods -n kube-system --no-headers | while read line; do
        pod_name=$(echo $line | awk '{print $1}')
        pod_status=$(echo $line | awk '{print $3}')
        if [ "$pod_status" = "Running" ] || [ "$pod_status" = "Completed" ]; then
            echo "✅ $pod_name: $pod_status"
        else
            echo "❌ $pod_name: $pod_status"
        fi
    done
}

BASHRC_EOF

# Kubernetes 매니페스트 템플릿 생성
log_info "Kubernetes 매니페스트 템플릿 생성 중..."
mkdir -p ~/workspace/kubernetes/templates

# Deployment 템플릿
cat > ~/workspace/kubernetes/templates/deployment.yaml << 'DEPLOY_EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
DEPLOY_EOF

# Service 템플릿
cat > ~/workspace/kubernetes/templates/service.yaml << 'SVC_EOF'
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  labels:
    app: my-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: my-app
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-loadbalancer
  labels:
    app: my-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: my-app
SVC_EOF

# ConfigMap 템플릿
cat > ~/workspace/kubernetes/templates/configmap.yaml << 'CM_EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
data:
  # 일반 키-값 쌍
  database_url: "postgresql://localhost:5432/myapp"
  redis_url: "redis://localhost:6379"
  
  # 환경별 설정
  app.properties: |
    app.name=my-application
    app.version=1.0.0
    app.environment=production
    
    # 데이터베이스 설정
    db.host=localhost
    db.port=5432
    db.name=myapp
    
    # 로깅 설정
    log.level=INFO
    log.file=/var/log/app.log
  
  # nginx 설정 예시
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
CM_EOF

# Secret 템플릿
cat > ~/workspace/kubernetes/templates/secret.yaml << 'SECRET_EOF'
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
type: Opaque
data:
  # Base64로 인코딩된 값들
  # 실제 사용시에는 base64로 인코딩해야 함
  # echo -n "mypassword" | base64
  database-password: bXlwYXNzd29yZA==
  api-key: YWJjZGVmZ2hpams=
  
---
apiVersion: v1
kind: Secret
metadata:
  name: my-app-tls
type: kubernetes.io/tls
data:
  # TLS 인증서 (base64 인코딩)
  tls.crt: LS0tLS1CRUdJTi...
  tls.key: LS0tLS1CRUdJTi...
SECRET_EOF

# Ingress 템플릿
cat > ~/workspace/kubernetes/templates/ingress.yaml << 'INGRESS_EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: my-app-api-service
            port:
              number: 8080
INGRESS_EOF

# HPA (Horizontal Pod Autoscaler) 템플릿
cat > ~/workspace/kubernetes/templates/hpa.yaml << 'HPA_EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
HPA_EOF

# PersistentVolumeClaim 템플릿
cat > ~/workspace/kubernetes/templates/pvc.yaml << 'PVC_EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-shared-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  resources:
    requests:
      storage: 50Gi
PVC_EOF

# Helm Chart 기본 구조 생성
log_info "Helm Chart 템플릿 생성 중..."
mkdir -p ~/workspace/kubernetes/helm-charts/my-app/{templates,charts}

# Chart.yaml
cat > ~/workspace/kubernetes/helm-charts/my-app/Chart.yaml << 'CHART_EOF'
apiVersion: v2
name: my-app
description: A Helm chart for my application
type: application
version: 0.1.0
appVersion: "1.0.0"

dependencies: []

keywords:
  - web
  - api
  - microservice

maintainers:
  - name: Your Name
    email: your.email@example.com
    url: https://github.com/yourusername
EOF

# values.yaml
cat > ~/workspace/kubernetes/helm-charts/my-app/values.yaml << 'VALUES_EOF'
# Default values for my-app
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80
  targetPort: 80

ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: my-app.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

env:
  - name: ENVIRONMENT
    value: "production"

configMap:
  data:
    app.properties: |
      app.name=my-application
      app.version=1.0.0

nodeSelector: {}
tolerations: []
affinity: {}
EOF

# Kubernetes 도구 설정 스크립트 생성
log_info "Kubernetes 도구 설정 스크립트 생성 중..."
cat > ~/workspace/kubernetes/k8s-setup-helper.sh << 'K8S_HELPER_EOF'
#!/bin/bash

# Kubernetes 도구 설정 도우미 스크립트

echo "========================================"
echo "  Kubernetes 도구 설정 도우미"
echo "========================================"
echo ""

echo "1. kubectl 설정 확인"
echo "2. 클러스터 연결 설정"
echo "3. 네임스페이스 생성"
echo "4. 개발 환경 설정"
echo "5. 헬스 체크"
echo ""

read -p "선택하세요 (1-5): " choice

case $choice in
    1)
        echo "kubectl 설정 확인 중..."
        echo ""
        echo "=== kubectl 버전 ==="
        kubectl version --client
        echo ""
        echo "=== 현재 컨텍스트 ==="
        kubectl config current-context 2>/dev/null || echo "컨텍스트가 설정되지 않았습니다"
        echo ""
        echo "=== 사용 가능한 컨텍스트 ==="
        kubectl config get-contexts
        ;;
    2)
        echo "클러스터 연결 설정을 시작합니다..."
        echo ""
        echo "클러스터 유형을 선택하세요:"
        echo "1. minikube"
        echo "2. kind"
        echo "3. EKS"
        echo "4. GKE"
        echo "5. AKS"
        echo "6. 기타 (kubeconfig 파일)"
        echo ""
        read -p "선택 (1-6): " cluster_type
        
        case $cluster_type in
            1)
                echo "minikube 시작 중..."
                minikube start
                kubectl config use-context minikube
                ;;
            2)
                echo "kind 클러스터 생성 중..."
                read -p "클러스터 이름 (기본: kind): " cluster_name
                cluster_name=${cluster_name:-kind}
                kind create cluster --name "$cluster_name"
                ;;
            3)
                echo "EKS 클러스터 연결 설정..."
                read -p "클러스터 이름: " cluster_name
                read -p "리전 (기본: ap-northeast-2): " region
                region=${region:-ap-northeast-2}
                aws eks update-kubeconfig --region "$region" --name "$cluster_name"
                ;;
            4)
                echo "GKE 클러스터 연결 설정..."
                read -p "클러스터 이름: " cluster_name
                read -p "존/리전: " zone
                read -p "프로젝트 ID: " project_id
                gcloud container clusters get-credentials "$cluster_name" --zone "$zone" --project "$project_id"
                ;;
            5)
                echo "AKS 클러스터 연결 설정..."
                read -p "클러스터 이름: " cluster_name
                read -p "리소스 그룹: " resource_group
                az aks get-credentials --resource-group "$resource_group" --name "$cluster_name"
                ;;
            6)
                echo "kubeconfig 파일 경로를 입력하세요:"
                read -p "경로: " kubeconfig_path
                if [ -f "$kubeconfig_path" ]; then
                    export KUBECONFIG="$kubeconfig_path"
                    echo "✅ kubeconfig 설정 완료"
                else
                    echo "❌ 파일을 찾을 수 없습니다: $kubeconfig_path"
                fi
                ;;
        esac
        ;;
    3)
        echo "네임스페이스 생성..."
        read -p "네임스페이스 이름: " namespace
        kubectl create namespace "$namespace"
        echo "✅ 네임스페이스 '$namespace' 생성 완료"
        
        read -p "이 네임스페이스를 기본으로 설정하시겠습니까? (y/N): " set_default
        if [ "$set_default" = "y" ] || [ "$set_default" = "Y" ]; then
            kubectl config set-context --current --namespace="$namespace"
            echo "✅ 기본 네임스페이스를 '$namespace'로 설정했습니다"
        fi
        ;;
    4)
        echo "개발 환경 설정 중..."
        
        # metrics-server 설치 (minikube/kind용)
        echo "metrics-server 설치 중..."
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        
        # NGINX Ingress Controller 설치
        echo "NGINX Ingress Controller 설치 중..."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
        
        echo "✅ 개발 환경 설정 완료"
        ;;
    5)
        echo "클러스터 헬스 체크 실행 중..."
        khealthcheck
        ;;
    *)
        echo "잘못된 선택입니다."
        ;;
esac
K8S_HELPER_EOF

chmod +x ~/workspace/kubernetes/k8s-setup-helper.sh

# 완료 메시지
echo ""
echo "========================================"
echo "  Kubernetes 도구 설치 완료!"
echo "========================================"
echo "kubectl 버전: $(kubectl version --client --output=yaml | grep gitVersion | cut -d'"' -f2)"
if command -v helm >/dev/null 2>&1; then
    echo "Helm 버전: $(helm version --short)"
fi
if command -v k9s >/dev/null 2>&1; then
    echo "k9s 버전: $(k9s version -s)"
fi
echo ""
echo "📁 작업 디렉토리:"
echo "  • ~/workspace/kubernetes/ - Kubernetes 프로젝트들"
echo "  • ~/workspace/kubernetes/manifests/ - YAML 매니페스트들"
echo "  • ~/workspace/kubernetes/helm-charts/ - Helm 차트들"
echo "  • ~/workspace/kubernetes/templates/ - 리소스 템플릿들"
echo ""
echo "🔧 설치된 도구들:"
echo "  • kubectl - Kubernetes CLI"
echo "  • helm - 패키지 매니저"
echo "  • k9s - CLI UI"
echo "  • kubectx/kubens - 컨텍스트/네임스페이스 전환"
echo "  • kustomize - 구성 관리"
echo "  • stern - 멀티 파드 로그"
echo "  • krew - kubectl 플러그인 매니저"
echo ""
echo "🚀 사용 가능한 명령어:"
echo "  • kinfo - 클러스터 정보"
echo "  • ksummary - 리소스 요약"
echo "  • kstatus [네임스페이스] - 파드 상태"
echo "  • kresources - 리소스 사용량"
echo "  • kenter <파드명> - 파드 접속"
echo "  • klive <파드명> - 실시간 로그"
echo "  • khealthcheck - 헬스 체크"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "⚙️  Kubernetes 클러스터 설정:"
echo "1. 로컬 클러스터: minikube start 또는 kind create cluster"
echo "2. 클라우드 클러스터: 각 클라우드 제공자의 CLI 사용"
echo "3. 설정 도우미: ~/workspace/kubernetes/k8s-setup-helper.sh"
echo ""
echo "🧪 테스트 명령어:"
echo "kubectl cluster-info"
echo "kinfo"
echo "========================================"