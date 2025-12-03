---
name: context-collector
description: 프롬프트에 부족한 정보를 탐지하고 현재 프로젝트 컨텍스트를 동적으로 수집하여 완전한 요구사항 구성. 문제 해결에 필요한 데이터가 부족할 때 사용.
triggers:
  - "구현해줘"
  - "만들어줘"
  - "추가해줘"
  - "개발해줘"
  - "기능"
---

# Context Collector

불완전한 요청 → 현재 프로젝트 동적 분석 → 스킬 라우팅 → 완전한 요구사항

## 핵심 원칙

> **프로젝트 정보를 가정하지 않는다.**
> 모든 컨텍스트는 현재 작업 디렉토리에서 실시간으로 수집한다.
> 적절한 스킬로 라우팅하여 스택별 최적화된 구현을 보장한다.

---

## Phase 1: 프로젝트 동적 탐지

### 1.1 작업 디렉토리 확인

```bash
pwd
ls -la
```

### 1.2 스택 자동 탐지

```bash
# 패키지 매니저 & 의존성
cat package.json 2>/dev/null || cat pom.xml 2>/dev/null || cat pubspec.yaml 2>/dev/null || cat requirements.txt 2>/dev/null

# 설정 파일로 프레임워크 탐지
ls *.config.* tsconfig.json vite.config.* nuxt.config.* angular.json 2>/dev/null

# 디렉토리 구조
ls src/ app/ pages/ components/ 2>/dev/null
```

### 스택 탐지 매트릭스

| 감지 조건 | 탐지 결과 | 필요 스킬 |
|-----------|-----------|-----------|
| `vite.config.*` + `react` | React + Vite | impl-frontend-react |
| `vite.config.*` + `vue` | Vue + Vite | impl-frontend-vue |
| `nuxt.config.*` | Nuxt | impl-frontend-vue |
| `angular.json` | Angular | impl-frontend-angular |
| `pubspec.yaml` | Flutter | impl-mobile-flutter |
| `pom.xml` / `build.gradle` | Spring Boot | impl-backend-spring |
| `package.json` + `@nestjs/core` | NestJS | impl-backend-nestjs |
| `requirements.txt` + `fastapi` | FastAPI | impl-backend-fastapi |
| `requirements.txt` + `django` | Django | impl-backend-django |

### 1.3 프로젝트 구조 스캔

```bash
# 3단계 깊이 (node_modules, .git 제외)
find . -type d -maxdepth 3 -not -path "*/node_modules/*" -not -path "*/.git/*" | head -30

# 주요 파일 확인
find ./src -name "*.tsx" -o -name "*.ts" -o -name "*.vue" -o -name "*.java" 2>/dev/null | head -20
```

---

## Phase 2: 스킬 존재 확인 및 라우팅

### 2.1 스킬 존재 확인

```bash
# 현재 존재하는 impl-* 스킬 목록
ls -d ~/.claude/skills/impl-* 2>/dev/null
```

### 2.2 스킬 라우팅 결정

```markdown
## 스킬 라우팅

### 탐지된 스택
- Frontend: [React/Vue/Angular/...]
- Backend: [Spring/NestJS/...]
- 주요 라이브러리: [목록]

### 필요한 스킬
- `impl-frontend-[framework]`
- `impl-backend-[framework]`

### 스킬 상태
| 필요 스킬 | 존재 여부 | 액션 |
|----------|----------|------|
| impl-frontend-react | O | 사용 |
| impl-backend-spring | X | skill-manager로 생성 |
```

### 2.3 스킬 없을 때 → skill-manager 호출

스킬이 존재하지 않으면 **skill-manager** 스킬을 활성화하여:
1. 새 스킬 생성 제안
2. 사용자 승인 후 템플릿 기반 생성
3. 생성된 스킬로 구현 진행

### 2.4 레퍼런스 동기화 확인

스킬이 존재하면 프로젝트 의존성과 레퍼런스 비교:

```markdown
## 레퍼런스 동기화 필요 여부

### 프로젝트 의존성
[package.json 등에서 추출]

### 스킬 레퍼런스
[references/libraries.md에서 추출]

### 차이점
- 추가 필요: [프로젝트에 있지만 레퍼런스에 없음]
- 제거 가능: [레퍼런스에 있지만 프로젝트에 없음]

동기화가 필요하면 skill-manager를 호출합니다.
```

---

## Phase 3: 구현 가능성 검증 (Gap 분석)

스택 탐지 완료 후, 요청 기능과 현재 스택 간 **Gap**을 분석한다.

### Gap 체크리스트

```markdown
## 구현 Gap 분석

### 요청 기능
[사용자 요청 기능]

### 현재 스택
[탐지된 스택]

### Gap 유형
- [ ] 라이브러리 부재
- [ ] 프레임워크 미지원
- [ ] 버전 호환성
- [ ] 아키텍처 제약
- [ ] 패턴 미존재
```

### Gap 유형별 대응

#### 1. 라이브러리 부재

```markdown
## 필요한 의존성

요청 기능 구현에 필요한 라이브러리가 없습니다.

| 옵션 | 설명 | 장단점 |
|------|------|--------|
| A. 라이브러리 추가 | `npm install [lib]` | 검증된 솔루션 / 번들 크기 증가 |
| B. 직접 구현 | 필요 기능만 구현 | 가벼움 / 유지보수 부담 |
| C. 대안 기능 | [대안 설명] | 현재 스택 활용 / 기능 제한 |

어떤 방식으로 진행할까요?
```

#### 2. 프레임워크 미지원

```markdown
## 프레임워크 제약

현재 프레임워크에서 해당 기능을 지원하지 않습니다.

- **프레임워크**: [탐지된 프레임워크]
- **요청 기능**: [요청]
- **제약 사유**: [왜 안 되는지]

| 대안 | 설명 |
|------|------|
| A. 유사 기능 대체 | [대안 기능] |
| B. 추가 설정/플러그인 | [필요한 설정] |
| C. 마이그레이션 | [범위] - 큰 작업 |

어떻게 진행할까요?
```

#### 3. 패턴 미존재 (첫 구현)

```markdown
## 새로운 패턴 필요

프로젝트에 유사한 기능/패턴이 없습니다.

| 옵션 | 설명 |
|------|------|
| A. Best Practice 기반 | 공식 문서/권장 패턴으로 새 표준 수립 |
| B. 최소 구현 | 당장 필요한 기능만 간단히 |
| C. 레퍼런스 참조 | 오픈소스 프로젝트 패턴 참고 |

### 권장
새로운 패턴이므로 **Best Practice 기반**으로 구현하고,
이후 유사 기능의 표준으로 활용하는 것을 권장합니다.
```

---

## Phase 4: 요청 유형별 컨텍스트 수집

### 기능 구현 요청

```bash
# 유사 기능 검색
grep -r "[기능키워드]" --include="*.tsx" --include="*.ts" --include="*.vue" -l 2>/dev/null | head -10
```

**수집 항목:**
- 유사 기능 파일 경로
- 컴포넌트/훅 작성 패턴
- 사용 중인 라이브러리
- API 호출 패턴

### 버그/에러 요청

```bash
# 관련 파일
grep -r "[에러키워드]" --include="*.tsx" --include="*.ts" -l 2>/dev/null

# 최근 변경
git log --oneline -5 --name-only 2>/dev/null
```

**수집 항목:**
- 에러 발생 위치
- 관련 코드
- 최근 변경사항

### 리팩토링 요청

```bash
wc -l [대상파일]
grep -c "function\|const.*=.*=>" [대상파일]
```

**수집 항목:**
- 현재 코드 구조
- 복잡도 지표
- 테스트 존재 여부

---

## Phase 5: 패턴 추출

### 동적 패턴 분석

```bash
# 컴포넌트 패턴
find src/components -name "*.tsx" -o -name "*.vue" | head -1 | xargs head -30

# 훅/컴포저블 패턴
find src/hooks src/composables -name "*.ts" 2>/dev/null | head -1 | xargs head -30

# API 패턴
find src/api src/services -name "*.ts" 2>/dev/null | head -1 | xargs head -30
```

### 패턴 분석 출력

```markdown
## 프로젝트 패턴 분석

### 컴포넌트 패턴
- 선언 방식: [function / arrow / class]
- Props: [interface / type / props define]
- 스타일링: [Tailwind / CSS Modules / Styled / etc.]

### 상태 관리 패턴
- 로컬: [useState / ref / reactive]
- 서버: [React Query / SWR / Vue Query]
- 전역: [Context / Zustand / Pinia / Redux]

### API 패턴
- 클라이언트: [fetch / axios / ky]
- 구조: [함수 / 클래스 / 훅]
```

---

## Phase 6: 부족 정보 질문 (최소화)

### 질문 원칙

1. **자동 수집 가능 → 질문 안 함**
2. **추론 가능 → "~로 가정했는데 맞나요?" 형태**
3. **불확실 → 구체적 선택지 제시**

### 질문 예시

```markdown
## 추가 확인 필요

프로젝트 분석 결과:
- 스택: [자동 탐지됨]
- 구조: [자동 탐지됨]
- 패턴: [자동 탐지됨]
- API 스펙: [확인 필요]

### 질문
백엔드 API 스펙이 있나요?
- [ ] 있음 (공유 부탁)
- [ ] 없음 (프론트 먼저 구현)
- [ ] 직접 구현 예정
```

---

## Phase 7: 완전한 컨텍스트 문서 출력

```markdown
# [요청 기능] 구현 컨텍스트

## 프로젝트 정보 (자동 탐지)
- **경로**: [pwd]
- **스택**: [탐지 결과]
- **구조**: [디렉토리 구조]

## 스킬 라우팅
- **사용 스킬**: impl-frontend-[framework]
- **레퍼런스 상태**: 동기화됨 / 동기화 필요

## 기존 패턴 (프로젝트 코드 기반)

### 참조할 파일
| 파일 | 참조 이유 |
|------|-----------|
| [경로] | [패턴 설명] |

### 추출된 컨벤션
- 컴포넌트: [패턴]
- 훅: [패턴]
- API: [패턴]

## 구현 계획

### 생성할 파일
```
[프로젝트 구조에 맞는 경로]
```

### 기능 요구사항
1. [요구사항 1]
2. [요구사항 2]

### 의존성
- 기존: [재사용]
- 신규: [새로 생성]
- API: [엔드포인트]

## Gap 분석 결과
- [Gap 있으면 표시]
- [없으면 "Gap 없음, 바로 구현 가능"]

---
이 컨텍스트로 구현을 시작할까요?
```

---

## 세션 내 컨텍스트 캐싱

프로젝트 전환 없이 연속 작업 시:

```markdown
## 이전 수집 컨텍스트 (캐싱)
- Stack: [유지]
- 패턴: [유지]
- 스킬: [유지]

## 이번 요청
- 추가 수집: [새 정보만]
```

---

## 스킬 흐름도

```
사용자 요청
    ↓
context-collector (Phase 1-2)
    ├── 스택 탐지
    └── 스킬 존재 확인
            ↓
    ┌───────┴───────┐
    ↓               ↓
스킬 있음       스킬 없음
    ↓               ↓
레퍼런스 확인   skill-manager
    ↓               ↓
    └───────┬───────┘
            ↓
context-collector (Phase 3-7)
    ├── Gap 분석
    ├── 컨텍스트 수집
    └── 컨텍스트 출력
            ↓
    스택에 따라 분기:
    ├── React + Vite → impl-frontend-react
    ├── Vue/Nuxt → impl-frontend-vue
    ├── Spring → impl-backend-spring
    └── ...
            ↓
    필요시 → refactoring
            ↓
    완성된 고품질 코드
```
