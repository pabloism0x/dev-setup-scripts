#!/bin/bash

# Rust 개발 환경 설치 스크립트
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
echo "  Rust 개발 환경 설치 스크립트"
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

# Rust 의존성 패키지 설치
install_dependencies() {
    detect_os
    log_info "감지된 운영체제: $OS $VER"
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        # Ubuntu/Debian
        log_info "Rust 의존성 패키지 설치 중..."
        sudo apt install -y curl wget git build-essential libssl-dev pkg-config
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]] || [[ "$OS" == *"AlmaLinux"* ]]; then
        # RHEL 계열
        log_info "Rust 의존성 패키지 설치 중..."
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y curl wget git gcc gcc-c++ make openssl-devel pkgconfig
        else
            sudo yum install -y curl wget git gcc gcc-c++ make openssl-devel pkgconfig
        fi
        
    elif [[ "$OS" == *"Fedora"* ]]; then
        # Fedora
        log_info "Rust 의존성 패키지 설치 중..."
        sudo dnf install -y curl wget git gcc gcc-c++ make openssl-devel pkgconfig
        
    elif [[ "$OS" == *"openSUSE"* ]] || [[ "$OS" == *"SUSE"* ]]; then
        # openSUSE
        log_info "Rust 의존성 패키지 설치 중..."
        sudo zypper install -y curl wget git gcc gcc-c++ make libopenssl-devel pkg-config
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        # Arch 계열
        log_info "Rust 의존성 패키지 설치 중..."
        sudo pacman -S --noconfirm curl wget git base-devel openssl pkg-config
        
    elif [[ "$OS" == *"Alpine"* ]]; then
        # Alpine
        log_info "Rust 의존성 패키지 설치 중..."
        sudo apk add curl wget git build-base openssl-dev pkgconfig
        
    else
        log_warning "지원하지 않는 운영체제입니다: $OS"
        log_info "의존성 패키지를 수동으로 설치해주세요: curl, wget, git, gcc, openssl-dev"
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

# Rustup 설치 (Rust 공식 설치 도구)
log_info "Rustup(Rust 설치 도구) 설치 중..."
if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # 환경 변수 임시 적용
    source ~/.cargo/env
else
    log_info "Rustup이 이미 설치되어 있습니다."
fi

# Rust 최신 stable 버전 설치/업데이트
log_info "Rust stable 버전 설치/업데이트 중..."
rustup default stable
rustup update

# 작업 디렉토리 생성
log_info "Rust 작업 디렉토리 생성 중..."
mkdir -p ~/workspace/rust

# .bashrc에 Rust 관련 설정 추가
log_info "Rust 환경 변수 설정 중..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# ======================================
# Rust 개발 환경 설정
# ======================================

# Rust 환경 변수
source ~/.cargo/env

# Rust alias
alias rs='cargo run'
alias rsb='cargo build'
alias rst='cargo test'
alias rsc='cargo check'
alias rsd='cargo doc --open'
alias rsf='cargo fmt'
alias rsl='cargo clippy'
alias rsu='cargo update'
alias rsa='cargo add'
alias rswork='cd ~/workspace/rust'

# Cargo 빌드 옵션 alias
alias rsrel='cargo build --release'
alias rstrel='cargo test --release'
alias rsbench='cargo bench'

# Rust 개발 도구 함수
rsinit() {
    if [ $# -eq 0 ]; then
        echo "사용법: rsinit <프로젝트명> [라이브러리|바이너리]"
        return 1
    fi
    
    PROJECT_NAME="$1"
    PROJECT_TYPE="${2:-binary}"  # 기본값: binary
    
    cd ~/workspace/rust
    
    if [ "$PROJECT_TYPE" = "lib" ] || [ "$PROJECT_TYPE" = "library" ]; then
        cargo new "$PROJECT_NAME" --lib
        echo "📚 Rust 라이브러리 프로젝트 '$PROJECT_NAME' 생성 완료"
    else
        cargo new "$PROJECT_NAME"
        echo "🚀 Rust 바이너리 프로젝트 '$PROJECT_NAME' 생성 완료"
    fi
    
    cd "$PROJECT_NAME"
    
    # 기본 의존성 추가
    cargo add serde --features derive
    cargo add tokio --features full
    cargo add clap --features derive
    
    echo "📁 위치: ~/workspace/rust/$PROJECT_NAME"
    echo "🔧 기본 의존성 추가됨: serde, tokio, clap"
    echo "🚀 실행: cargo run"
}

# Rust 프로젝트 정보 확인
rsinfo() {
    if [ -f "Cargo.toml" ]; then
        echo "=== Rust 프로젝트 정보 ==="
        echo "프로젝트명: $(grep '^name' Cargo.toml | cut -d'"' -f2)"
        echo "버전: $(grep '^version' Cargo.toml | cut -d'"' -f2)"
        echo "Rust 에디션: $(grep '^edition' Cargo.toml | cut -d'"' -f2)"
        echo ""
        echo "의존성 목록:"
        cargo tree --depth 1
    else
        echo "❌ Cargo.toml 파일을 찾을 수 없습니다."
        echo "Rust 프로젝트 디렉토리에서 실행해주세요."
    fi
}

# Rust 환경 정보
rsenv() {
    echo "=== Rust 개발 환경 정보 ==="
    echo "Rust 버전: $(rustc --version)"
    echo "Cargo 버전: $(cargo --version)"
    echo "Rustup 버전: $(rustup --version | head -n1)"
    echo ""
    echo "설치된 툴체인:"
    rustup show
    echo ""
    echo "설치된 컴포넌트:"
    rustup component list --installed
}

# 성능 테스트 실행
rsbench() {
    echo "🏃 Rust 벤치마크 실행 중..."
    cargo bench
}

# 전체 테스트 스위트 실행
rstall() {
    echo "🧪 전체 테스트 실행 중..."
    cargo test &&
    cargo clippy -- -D warnings &&
    cargo fmt --check &&
    echo "✅ 모든 테스트 통과!"
}

BASHRC_EOF

# 환경 변수 임시 적용
source ~/.cargo/env

# Rust 버전 확인
RUST_VERSION=$(rustc --version)
CARGO_VERSION=$(cargo --version)
log_success "Rust 설치 완료: $RUST_VERSION"
log_success "Cargo 설치 완료: $CARGO_VERSION"

# 유용한 Rust 도구들 설치
log_info "유용한 Rust 도구들 설치 중..."

# 코드 포맷터 (이미 포함되어 있지만 최신 버전으로 업데이트)
rustup component add rustfmt

# 클리피 (Rust 린터)
rustup component add clippy

# 추가 개발 도구들
cargo install cargo-watch      # 파일 변경 감지 및 자동 빌드
cargo install cargo-edit       # Cargo.toml 편집 도구 (cargo add, cargo rm)
cargo install cargo-outdated   # 오래된 의존성 확인
cargo install cargo-audit      # 보안 취약점 확인
cargo install cargo-expand     # 매크로 확장 확인
cargo install sccache          # 컴파일 캐시
cargo install bacon            # 백그라운드 컴파일러

# 웹 개발 도구들
cargo install cargo-generate   # 프로젝트 템플릿 생성기
cargo install wasm-pack        # WebAssembly 패키지 도구

# Rust 개발 템플릿 생성
log_info "Rust 개발 템플릿 생성 중..."
mkdir -p ~/workspace/rust/templates

# HTTP 서버 템플릿 (Axum)
cat > ~/workspace/rust/templates/http_server.rs << 'HTTP_EOF'
use axum::{
    extract::Query,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::net::TcpListener;
use tower::ServiceBuilder;
use tower_http::cors::CorsLayer;

#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    timestamp: String,
}

#[derive(Serialize, Deserialize)]
struct HelloResponse {
    message: String,
    name: String,
}

#[derive(Deserialize)]
struct HelloParams {
    name: Option<String>,
}

async fn health() -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        timestamp: chrono::Utc::now().to_rfc3339(),
    })
}

async fn hello(Query(params): Query<HelloParams>) -> Json<HelloResponse> {
    let name = params.name.unwrap_or_else(|| "World".to_string());
    Json(HelloResponse {
        message: format!("Hello, {}!", name),
        name,
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/health", get(health))
        .route("/hello", get(hello))
        .layer(ServiceBuilder::new().layer(CorsLayer::permissive()));

    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("🚀 Server running on http://0.0.0.0:3000");
    
    axum::serve(listener, app).await.unwrap();
}
HTTP_EOF

# CLI 애플리케이션 템플릿
cat > ~/workspace/rust/templates/cli_app.rs << 'CLI_EOF'
use clap::{Arg, Command, ArgMatches};
use std::process;

fn main() {
    let matches = Command::new("rust-cli")
        .version("1.0")
        .author("Your Name <your.email@example.com>")
        .about("Rust CLI 애플리케이션 템플릿")
        .arg(
            Arg::new("name")
                .short('n')
                .long("name")
                .value_name("NAME")
                .help("이름을 설정합니다")
                .default_value("World"),
        )
        .arg(
            Arg::new("count")
                .short('c')
                .long("count")
                .value_name("COUNT")
                .help("반복 횟수를 설정합니다")
                .value_parser(clap::value_parser!(u32))
                .default_value("1"),
        )
        .arg(
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .help("상세 출력 모드")
                .action(clap::ArgAction::SetTrue),
        )
        .get_matches();

    run(&matches);
}

fn run(matches: &ArgMatches) {
    let name = matches.get_one::<String>("name").unwrap();
    let count = *matches.get_one::<u32>("count").unwrap();
    let verbose = matches.get_flag("verbose");

    if verbose {
        println!("이름: {}, 반복 횟수: {}", name, count);
    }

    for i in 1..=count {
        if verbose {
            println!("[{}] Hello, {}!", i, name);
        } else {
            println!("Hello, {}!", name);
        }
    }
}
CLI_EOF

# WebAssembly 템플릿
cat > ~/workspace/rust/templates/wasm_lib.rs << 'WASM_EOF'
use wasm_bindgen::prelude::*;

// 브라우저의 console.log 함수 바인딩
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

// console.log를 사용하는 매크로
macro_rules! console_log {
    ($($t:tt)*) => (log(&format_args!($($t)*).to_string()))
}

// WebAssembly로 노출할 함수
#[wasm_bindgen]
pub fn greet(name: &str) {
    console_log!("Hello, {}!", name);
}

#[wasm_bindgen]
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[wasm_bindgen]
pub struct Calculator {
    value: f64,
}

#[wasm_bindgen]
impl Calculator {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Calculator {
        Calculator { value: 0.0 }
    }

    #[wasm_bindgen(getter)]
    pub fn value(&self) -> f64 {
        self.value
    }

    pub fn add(&mut self, value: f64) {
        self.value += value;
    }

    pub fn multiply(&mut self, value: f64) {
        self.value *= value;
    }

    pub fn reset(&mut self) {
        self.value = 0.0;
    }
}
WASM_EOF

# 비동기 처리 템플릿
cat > ~/workspace/rust/templates/async_example.rs << 'ASYNC_EOF'
use tokio::time::{sleep, Duration};
use std::sync::Arc;
use tokio::sync::Mutex;

#[tokio::main]
async fn main() {
    println!("🚀 비동기 처리 예제 시작");

    // 기본 비동기 함수 호출
    simple_async().await;

    // 동시 실행 예제
    concurrent_tasks().await;

    // 뮤텍스를 사용한 공유 상태 관리
    shared_state_example().await;

    println!("✅ 모든 비동기 작업 완료");
}

async fn simple_async() {
    println!("⏰ 2초 대기 시작...");
    sleep(Duration::from_secs(2)).await;
    println!("✅ 2초 대기 완료");
}

async fn concurrent_tasks() {
    println!("🔄 동시 작업 실행 중...");
    
    let task1 = async {
        sleep(Duration::from_secs(1)).await;
        println!("📝 Task 1 완료");
        "Task 1 결과"
    };

    let task2 = async {
        sleep(Duration::from_secs(2)).await;
        println!("📝 Task 2 완료");
        "Task 2 결과"
    };

    let task3 = async {
        sleep(Duration::from_secs(1)).await;
        println!("📝 Task 3 완료");
        "Task 3 결과"
    };

    // 모든 작업이 완료될 때까지 대기
    let results = tokio::join!(task1, task2, task3);
    println!("📊 모든 작업 결과: {:?}", results);
}

async fn shared_state_example() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    // 여러 태스크에서 공유 카운터 증가
    for i in 0..5 {
        let counter = Arc::clone(&counter);
        let handle = tokio::spawn(async move {
            for _ in 0..10 {
                let mut num = counter.lock().await;
                *num += 1;
                println!("🔢 Task {}: 카운터 = {}", i, *num);
                // 뮤텍스 락 해제
                drop(num);
                sleep(Duration::from_millis(10)).await;
            }
        });
        handles.push(handle);
    }

    // 모든 태스크 완료 대기
    for handle in handles {
        handle.await.unwrap();
    }

    let final_count = *counter.lock().await;
    println!("🎯 최종 카운터 값: {}", final_count);
}
ASYNC_EOF

# 완료 메시지
echo ""
echo "========================================"
echo "  Rust 개발 환경 설치 완료!"
echo "========================================"
echo "Rust 버전: $(rustc --version)"
echo "Cargo 버전: $(cargo --version)"
echo ""
echo "📁 작업 디렉토리:"
echo "  • ~/workspace/rust/ - Rust 프로젝트들"
echo "  • ~/workspace/rust/templates/ - 개발 템플릿들"
echo "  • ~/.cargo/ - Cargo 설정 및 바이너리들"
echo ""
echo "🔧 설치된 Rust 도구들:"
echo "  • rustfmt - 코드 포맷터"
echo "  • clippy - 린터"
echo "  • cargo-watch - 파일 변경 감지"
echo "  • cargo-edit - Cargo.toml 편집"
echo "  • cargo-audit - 보안 취약점 확인"
echo "  • sccache - 컴파일 캐시"
echo "  • wasm-pack - WebAssembly 도구"
echo ""
echo "🚀 사용 가능한 명령어:"
echo "  • rsinit <프로젝트명> - 새 Rust 프로젝트 생성"
echo "  • rsinfo - 프로젝트 정보 확인"
echo "  • rsenv - Rust 환경 정보"
echo "  • rstall - 전체 테스트 실행"
echo ""
echo "📋 다음 명령어로 환경 변수를 적용하세요:"
echo "source ~/.bashrc"
echo ""
echo "🧪 테스트 명령어:"
echo "rsinit hello-rust"
echo "========================================"