# 기여 가이드 🤝

dev-setup-scripts 프로젝트에 기여해주셔서 감사합니다! 이 문서는 프로젝트에 기여하는 방법을 안내합니다.

## 📋 목차

- [코드 기여](#코드-기여)
- [버그 리포트](#버그-리포트)
- [기능 제안](#기능-제안)
- [개발 환경 설정](#개발-환경-설정)
- [코딩 스타일](#코딩-스타일)
- [커밋 메시지 규칙](#커밋-메시지-규칙)
- [풀 리퀘스트 가이드](#풀-리퀘스트-가이드)

## 🔧 코드 기여

### 1. 포크 및 클론
```bash
# 프로젝트 포크 후 클론
git clone https://github.com/your-username/dev-setup-scripts.git
cd dev-setup-scripts

# upstream 원격 저장소 추가
git remote add upstream https://github.com/original-owner/dev-setup-scripts.git
```

### 2. 브랜치 생성
```bash
# 새로운 기능 브랜치 생성
git checkout -b feature/add-new-language-support

# 버그 수정 브랜치 생성
git checkout -b fix/nodejs-installation-issue

# 문서 개선 브랜치 생성
git checkout -b docs/update-readme
```

### 3. 변경사항 구현
- **새로운 언어 지원**: `framework/setup-language.sh` 파일 추가
- **새로운 도구 지원**: 해당 카테고리의 디렉토리에 스크립트 추가
- **기존 스크립트 개선**: 해당 스크립트 파일 수정

### 4. 테스트
변경사항은 다음 환경에서 테스트해주세요:

**필수 테스트 환경:**
- Ubuntu 22.04 (Docker 컨테이너 권장)

**권장 테스트 환경:**
- CentOS Stream 9
- Fedora 39

**테스트 방법:**
```bash
# Docker 컨테이너에서 테스트
docker run -it ubuntu:22.04 bash

# 컨테이너 내에서
apt update && apt install -y git sudo
git clone https://github.com/your-username/dev-setup-scripts.git
cd dev-setup-scripts
./your-script.sh
```

## 🐛 버그 리포트

버그를 발견하셨나요? [Issues](https://github.com/original-owner/dev-setup-scripts/issues)에 다음 정보와 함께 리포트해주세요:

### 버그 리포트 템플릿
```markdown
## 🐛 버그 설명
간단하고 명확한 버그 설명

## 🔄 재현 단계
1. 스크립트 실행: `./framework/setup-nodejs.sh`
2. 오류 발생 지점: ...
3. 예상 결과 vs 실제 결과

## 💻 환경 정보
- OS: Ubuntu 22.04
- 아키텍처: x86_64
- 쉘: bash 5.1.16

## 📋 오류 로그
```
오류 메시지나 로그를 여기에 붙여넣기
```

## 📸 스크린샷 (선택사항)
오류 화면 캡처
```

## 💡 기능 제안

새로운 기능을 제안하고 싶으시나요? [Issues](https://github.com/original-owner/dev-setup-scripts/issues)에 다음과 같이 제안해주세요:

### 기능 제안 템플릿
```markdown
## 🚀 기능 제안
제안하는 기능에 대한 설명

## 🎯 해결하고자 하는 문제
이 기능이 어떤 문제를 해결하나요?

## 💭 제안하는 해결책
어떻게 구현하면 좋을지 아이디어

## 🔀 대안책 (선택사항)
다른 방법이 있다면 설명

## 📚 추가 정보 (선택사항)
참고할 만한 링크나 자료
```

## 🛠️ 개발 환경 설정

### 필수 도구
```bash
# Git 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 개발용 도구 설치 (우리 스크립트로!)
./linux/setup-basic.sh
```

### 권장 IDE/에디터 설정
- **VS Code**: Bash 확장 프로그램 설치
- **vim**: 기본 설정으로도 충분
- **nano**: 간단한 수정용

## 📝 코딩 스타일

### Bash 스크립트 스타일
```bash
#!/bin/bash

# 스크립트 상단에 설명 주석
# 작성자: your-name
# 용도: 스크립트 목적 설명

set -e  # 에러 발생 시 중단

# 함수명: 소문자 + 언더스코어
install_package() {
    local package_name="$1"
    # 함수 내용
}

# 변수명: 대문자 + 언더스코어
PACKAGE_NAME="example"
LOCAL_VAR="value"

# 조건문 스타일
if [ "$condition" = "value" ]; then
    echo "조건이 참입니다"
fi

# 반복문 스타일
for item in "${array[@]}"; do
    echo "$item"
done
```

### 주석 스타일
```bash
# 단일 라인 주석

# 다중 라인 주석의 경우
# 각 라인마다 # 사용

# 섹션 구분
# ======================================
# 패키지 설치 섹션
# ======================================
```

## 📨 커밋 메시지 규칙

### 커밋 메시지 형식
```
<이모지> <타입>: <제목>

<본문 (선택사항)>

<푸터 (선택사항)>
```

### 이모지 및 타입
- `🎉 init:` - 초기 설정 및 프로젝트 시작
- `✨ feat:` - 새로운 기능 추가
- `🐛 fix:` - 버그 수정
- `📝 docs:` - 문서 수정
- `💄 style:` - 코드 포맷팅, 세미콜론 누락 등
- `♻️ refactor:` - 코드 리팩토링
- `⚡ perf:` - 성능 개선
- `✅ test:` - 테스트 코드 추가/수정
- `🔧 config:` - 설정 파일 수정
- `🗃️ chore:` - 기타 변경사항 (빌드, 패키지 매니저 등)

### 커밋 메시지 예시
```bash
✨ feat: Go 언어 설치 스크립트 추가

- Go 1.21 LTS 설치
- 개발 도구 및 모듈 관리 설정
- HTTP 서버 템플릿 포함

Closes #15
```

```bash
🐛 fix: Node.js 설치 시 권한 오류 해결

NVM 설치 과정에서 발생하는 권한 문제 수정
- ~/.bashrc 파일 권한 확인 로직 추가
- 오류 메시지 개선

Fixes #23
```

## 🔄 풀 리퀘스트 가이드

### PR 생성 전 체크리스트
- [ ] 코드가 프로젝트의 코딩 스타일을 따르는가?
- [ ] 변경사항이 기존 기능을 깨뜨리지 않는가?
- [ ] 새로운 기능에 대한 문서화가 되어 있는가?
- [ ] 테스트를 통과했는가?
- [ ] 커밋 메시지가 규칙에 맞는가?

### PR 템플릿
```markdown
## 📋 변경사항 요약
이 PR에서 변경된 내용을 간단히 설명

## 🎯 관련 이슈
Closes #이슈번호

## 🧪 테스트 환경
- [ ] Ubuntu 22.04
- [ ] CentOS Stream 9
- [ ] Fedora 39

## 📸 스크린샷 (해당하는 경우)
UI 변경사항이 있는 경우 스크린샷 첨부

## ✅ 체크리스트
- [ ] 코딩 스타일 준수
- [ ] 테스트 통과
- [ ] 문서 업데이트
- [ ] 기존 기능 영향 없음
```

### PR 리뷰 과정
1. **자동 체크**: GitHub Actions 체크 통과
2. **코드 리뷰**: 메인테이너가 코드 검토
3. **테스트**: 다양한 환경에서 테스트
4. **머지**: 승인 후 main 브랜치에 병합

## 🏷️ 라벨 시스템

### 이슈 라벨
- `bug` - 버그 리포트
- `enhancement` - 새로운 기능
- `documentation` - 문서 관련
- `good first issue` - 처음 기여하기 좋은 이슈
- `help wanted` - 도움이 필요한 이슈
- `question` - 질문

### 우선순위 라벨
- `priority: high` - 높은 우선순위
- `priority: medium` - 중간 우선순위
- `priority: low` - 낮은 우선순위

## 🎁 인정 및 보상

### 기여자 인정
- README.md의 Contributors 섹션에 이름 추가
- 정기적인 기여자에게는 collaborator 권한 부여

### 기여 통계
GitHub의 Insights > Contributors에서 기여 현황 확인 가능

## 📞 문의 및 도움

- **GitHub Issues**: 버그 리포트 및 기능 제안
- **GitHub Discussions**: 일반적인 질문 및 토론
- **Email**: pabloism0x@gmail.com

## 🙏 감사의 말

여러분의 기여가 이 프로젝트를 더욱 훌륭하게 만듭니다. 
작은 오타 수정부터 새로운 기능 추가까지, 모든 기여를 환영합니다!

**Happy Contributing! 🎉**