# 개발 환경 자동 설정 스크립트 🚀

Linux 환경에서 현대적인 개발 및 클라우드 엔지니어링에 필요한 모든 도구를 한 번에 설치하는 자동화 스크립트 모음입니다.

## 📋 목차

- [개요](#개요)
- [지원 환경](#지원-환경)
- [빠른 시작](#빠른-시작)
- [스크립트 구성](#스크립트-구성)
- [사용법](#사용법)
- [설치되는 도구들](#설치되는-도구들)
- [문제 해결](#문제-해결)
- [기여하기](#기여하기)

## 🎯 개요

이 프로젝트는 Linux 환경에서 개발 환경을 빠르고 일관성 있게 구축하기 위한 자동화 스크립트 모음입니다. 현대적인 웹 개발, 백엔드 개발, 인프라 엔지니어링, 클라우드 네이티브 개발에 필요한 모든 도구를 포함합니다.

### ✨ 주요 특징

- **🔧 완전 자동화**: 클릭 한 번으로 전체 개발 환경 구축
- **🌍 다중 배포판 지원**: Ubuntu, Debian, CentOS, Fedora, Arch Linux 등
- **🎨 개발자 친화적**: 유용한 alias, 함수, 템플릿 제공
- **🛡️ 보안 중심**: 방화벽, SSH 보안, 침입 탐지 시스템 자동 설정
- **☁️ 클라우드 Ready**: AWS, GCP, Kubernetes 도구 포함
- **📦 컨테이너 지원**: Docker와 Podman 모두 지원

## 🖥️ 지원 환경

### 운영체제
- **Ubuntu** 20.04, 22.04, 24.04
- **Debian** 11, 12
- **CentOS** 8, 9
- **Rocky Linux** 8, 9
- **AlmaLinux** 8, 9
- **Fedora** 38, 39, 40
- **openSUSE** Leap, Tumbleweed
- **Arch Linux** / **Manjaro**
- **Alpine Linux**

### 아키텍처
- **x86_64** (AMD64)
- **ARM64** (AArch64)
- **ARMv7** (일부 도구)

## 🚀 빠른 시작

### 전체 설치 (권장)
```bash
# 리포지토리 클론
git clone https://github.com/yourusername/dev-setup-scripts.git
cd dev-setup-scripts

# 전체 설치 실행
chmod +x install-all.sh
./install-all.sh
```

### 웹 개발 최소 환경
```bash
# 기본 도구 + Node.js + 컨테이너
./linux/setup-basic.sh
./framework/setup-nodejs.sh
./linux/setup-docker.sh
```

### 개별 스크립트 실행
```bash
# 실행 권한 부여
chmod +x linux/setup-basic.sh

# 개별 실행
./linux/setup-basic.sh
```

## 📁 스크립트 구성

```
install-scripts/
├── framework/          # 프로그래밍 언어 및 런타임
│   ├── setup-nodejs.sh    # Node.js 20 LTS + npm + 개발도구
│   ├── setup-python.sh    # Python 3.11 + Poetry + pyenv
│   ├── setup-golang.sh    # Go 1.21 + 개발도구
│   └── setup-rust.sh      # Rust stable + Cargo + WebAssembly
├── linux/              # 시스템 도구 및 설정
│   ├── setup-basic.sh     # 기본 패키지 + vim + git 설정
│   ├── setup-podman.sh    # Podman 컨테이너 (rootless)
│   ├── setup-docker.sh    # Docker 컨테이너
│   └── setup-security.sh  # 방화벽 + SSH 보안 + 침입탐지
└── cloud/              # 클라우드 도구
    ├── setup-aws-cli.sh   # AWS CLI + CDK + SAM + Terraform
    ├── setup-gcp-cli.sh   # Google Cloud CLI + 도구들
    └── setup-kubectl.sh   # Kubernetes CLI + Helm + k9s
```

## 📖 사용법

### 1. 스크립트 다운로드 및 권한 설정
```bash
git clone https://github.com/yourusername/dev-setup-scripts.git
cd dev-setup-scripts
find . -name "*.sh" -exec chmod +x {} \;
```

### 2. 시나리오별 설치

#### 🌐 프론트엔드 개발자
```bash
./linux/setup-basic.sh      # 기본 도구
./framework/setup-nodejs.sh # Node.js + React/Vue/Angular
./linux/setup-docker.sh     # 컨테이너 환경
```

#### 🖥️ 백엔드 개발자
```bash
./linux/setup-basic.sh      # 기본 도구
./framework/setup-python.sh # Python + FastAPI/Django
./framework/setup-golang.sh # Go + 마이크로서비스
./linux/setup-docker.sh     # 컨테이너
./cloud/setup-aws-cli.sh    # 클라우드 배포
```

#### 🌐 풀스택 웹 개발자
```bash
./linux/setup-basic.sh      # 기본 도구
./linux/setup-security.sh   # 보안 설정
./framework/setup-nodejs.sh # Frontend
./framework/setup-python.sh # Backend
./linux/setup-docker.sh     # 컨테이너
./cloud/setup-kubectl.sh    # Kubernetes
```

#### ☁️ 클라우드/인프라 엔지니어
```bash
./linux/setup-basic.sh      # 기본 도구
./linux/setup-security.sh   # 보안 설정
./framework/setup-golang.sh # Go 도구 개발
./framework/setup-rust.sh   # 시스템 프로그래밍
./linux/setup-docker.sh     # 컨테이너
./cloud/setup-aws-cli.sh    # AWS 도구
./cloud/setup-gcp-cli.sh    # Google Cloud 도구
./cloud/setup-kubectl.sh    # Kubernetes 도구
```

### 3. 환경 변수 적용
```bash
# 설치 후 실행 (또는 재로그인)
source ~/.bashrc
```

## 🛠️ 설치되는 도구들

### 기본 시스템 도구 (`linux/setup-basic.sh`)
- **패키지 매니저**: 최신 버전으로 업그레이드
- **기본 도구**: curl, wget, git, vim, htop, tree, unzip
- **vim 설정**: 개발자용 설정, 플러그인, 테마
- **bash 개선**: 히스토리, 자동완성, 유용한 alias
- **압축 도구**: zip, unzip, tar, gzip

### Node.js 환경 (`framework/setup-nodejs.js`)
- **Node.js**: 20 LTS (NVM으로 설치)
- **패키지 매니저**: npm, yarn, pnpm
- **개발 도구**: nodemon, pm2, typescript, eslint
- **프레임워크**: Express, React, Vue 설정
- **템플릿**: Express API, React App, TypeScript 프로젝트

### Python 환경 (`framework/setup-python.sh`)
- **Python**: 3.11 + 최신 pip
- **환경 관리**: pyenv, Poetry, virtualenv
- **개발 도구**: black, flake8, mypy, pytest
- **웹 프레임워크**: Flask, FastAPI, Django
- **과학 도구**: numpy, pandas, matplotlib
- **템플릿**: Flask API, FastAPI, Django 프로젝트

### Go 환경 (`framework/setup-golang.sh`)
- **Go**: 1.21 LTS
- **개발 도구**: goimports, golint, staticcheck
- **웹 프레임워크**: gin, echo 라이브러리
- **마이크로서비스**: gRPC, 컨테이너 도구
- **템플릿**: HTTP 서버, CLI 앱, 마이크로서비스

### Rust 환경 (`framework/setup-rust.sh`)
- **Rust**: stable 채널 (rustup)
- **개발 도구**: rustfmt, clippy, cargo-watch
- **웹 개발**: Axum, Actix-web 도구
- **WebAssembly**: wasm-pack 도구
- **템플릿**: HTTP 서버, CLI 앱, WebAssembly

### 컨테이너 환경 (`linux/setup-podman.sh`, `linux/setup-docker.sh`)
- **Podman**: rootless 컨테이너 (보안 중심)
- **Docker**: 표준 컨테이너 + Docker Compose
- **개발 도구**: buildah, skopeo (Podman)
- **템플릿**: Dockerfile, docker-compose.yml

### 보안 도구 (`linux/setup-security.sh`)
- **방화벽**: UFW/firewalld 자동 설정
- **SSH 보안**: 키 기반 인증, 설정 강화
- **침입 탐지**: Fail2Ban
- **안티바이러스**: ClamAV
- **시스템 감사**: AIDE, rkhunter, lynis

### AWS 도구 (`cloud/setup-aws-cli.sh`)
- **AWS CLI**: v2 최신 버전
- **개발 도구**: CDK, SAM CLI, Copilot
- **인프라**: Terraform, Session Manager
- **템플릿**: Lambda, CloudFormation, CDK

### Google Cloud 도구 (`cloud/setup-gcp-cli.sh`)
- **gcloud CLI**: 최신 버전 + 구성요소
- **개발 도구**: Cloud SDK, Cloud Build
- **템플릿**: App Engine, Cloud Functions, Cloud Run

### Kubernetes 도구 (`cloud/setup-kubectl.sh`)
- **kubectl**: 최신 버전 + 자동완성
- **관리 도구**: Helm, k9s, kubectx/kubens
- **유틸리티**: stern, kustomize, krew
- **템플릿**: Deployment, Service, Ingress

## 🔧 유용한 명령어

설치 후 사용할 수 있는 유용한 명령어들입니다:

### 일반 도구
```bash
# 시스템 정보
sysinfo          # 시스템 정보 요약
netinfo          # 네트워크 정보
diskinfo         # 디스크 사용량

# 개발 도구
projinit         # 새 프로젝트 초기화
gitsetup         # Git 설정 도우미
```

### Node.js
```bash
nodeinit myapp   # Node.js 프로젝트 생성
nodeinfo         # Node.js 환경 정보
```

### Python
```bash
pyinit myproject # Python 프로젝트 생성
mkvenv myenv     # 가상환경 생성
lsvenv           # 가상환경 목록
```

### Go
```bash
goinit myservice # Go 프로젝트 생성
goinfo           # Go 환경 정보
```

### Rust
```bash
rsinit mylib     # Rust 프로젝트 생성
rsenv            # Rust 환경 정보
```

### 컨테이너
```bash
# Docker
dinfo            # Docker 시스템 정보
dclean           # Docker 정리
dcinit myapp     # Docker Compose 프로젝트

# Podman
podinfo          # Podman 시스템 정보
podclean         # Podman 정리
```

### 보안
```bash
seccheck         # 보안 상태 확인
secscan          # 전체 보안 스캔
viruscan /home   # 바이러스 스캔
```

### 클라우드
```bash
# AWS
awsinfo          # AWS 계정 정보
awsuse profile   # AWS 프로필 변경
awsinit myapp    # AWS 프로젝트 생성

# Google Cloud
gcinfo           # GCP 계정 정보
gcuse project    # GCP 프로젝트 변경
gcinit myapp     # GCP 프로젝트 생성

# Kubernetes
kinfo            # 클러스터 정보
ksummary         # 리소스 요약
kenter podname   # 파드 접속
```

## 🔍 문제 해결

### 일반적인 문제

#### 1. 권한 오류
```bash
# 스크립트 실행 권한 부여
chmod +x script-name.sh

# sudo 권한 확인
sudo -v
```

#### 2. 네트워크 연결 문제
```bash
# DNS 확인
nslookup google.com

# 방화벽 상태 확인
sudo ufw status
```

#### 3. 패키지 설치 실패
```bash
# 패키지 캐시 업데이트
sudo apt update          # Ubuntu/Debian
sudo dnf check-update    # Fedora/RHEL
```

#### 4. 환경 변수 적용 안됨
```bash
# 수동으로 적용
source ~/.bashrc

# 또는 재로그인
exit
# 다시 로그인
```

### 스크립트별 문제

#### Node.js 설치 실패
```bash
# NVM 수동 설치
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
```

#### Docker 권한 문제
```bash
# Docker 그룹에 사용자 추가 확인
groups $USER

# 그룹 권한 수동 적용
newgrp docker
```

#### Kubernetes 연결 실패
```bash
# kubectl 설정 확인
kubectl config get-contexts

# 클러스터 연결 테스트
kubectl cluster-info
```

### 로그 확인
```bash
# 스크립트 실행 로그 저장
./script-name.sh 2>&1 | tee install.log

# 시스템 로그 확인
journalctl -f
tail -f /var/log/syslog
```

## 🤝 기여하기

이 프로젝트에 기여해주세요! 

### 기여 방법

1. **이슈 리포트**: 버그나 개선 사항을 GitHub Issues에 등록
2. **풀 리퀘스트**: 코드 개선이나 새로운 기능 추가
3. **문서 개선**: README나 주석 개선
4. **테스트**: 다양한 환경에서 테스트 후 피드백

### 개발 가이드라인

```bash
# 포크 및 클론
git clone https://github.com/your-username/dev-setup-scripts.git
cd dev-setup-scripts

# 새 브랜치 생성
git checkout -b feature/new-feature

# 변경사항 커밋
git add .
git commit -m "feat: 새로운 기능 추가"

# 푸시 및 풀 리퀘스트
git push origin feature/new-feature
```

### 코딩 스타일

- **스크립트**: Bash best practices 준수
- **함수명**: 소문자 + 언더스코어 (`install_package`)
- **변수명**: 대문자 + 언더스코어 (`PACKAGE_NAME`)
- **주석**: 각 섹션별로 명확한 설명 추가

### 테스트 환경

새로운 스크립트나 변경사항은 다음 환경에서 테스트해주세요:

- **Ubuntu 22.04** (주요 타겟)
- **CentOS Stream 9** (RHEL 계열)
- **Docker 컨테이너** 환경에서 테스트

## 📄 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE)를 따릅니다.

## 📞 지원 및 문의

- **GitHub Issues**: 버그 리포트 및 기능 요청
- **Discussions**: 일반적인 질문 및 토론
- **Email**: pabloism0x@gmail.com

## 🙏 감사의 말

이 프로젝트는 다음 오픈소스 프로젝트들의 도움을 받았습니다:

- [NVM](https://github.com/nvm-sh/nvm) - Node.js 버전 관리
- [Poetry](https://python-poetry.org/) - Python 패키지 관리
- [Rustup](https://rustup.rs/) - Rust 툴체인 관리
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Kubernetes CLI
- [Helm](https://helm.sh/) - Kubernetes 패키지 매니저

---

**⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요!**

**🐛 버그를 발견하셨나요? [Issues](https://github.com/yourusername/dev-setup-scripts/issues)에 등록해주세요.**

**💡 새로운 아이디어가 있으신가요? [Discussions](https://github.com/yourusername/dev-setup-scripts/discussions)에서 공유해주세요.**