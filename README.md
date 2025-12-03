# kk3june Skills

Claude Code를 위한 프론트엔드 개발 스킬 모음입니다.

프로젝트 코드 기반 구현 + Best Practice fallback + 자기 개선 시스템으로 일관성 있고 품질 높은 코드를 생성합니다.

---

## 핵심 철학

> **"프로젝트 코드가 곧 레퍼런스다."**
>
> 일관된 패턴이 있으면 따르고, 없으면 Best Practice로 구현한다.
> 안티패턴은 개선을 제안하고, 좋은 패턴은 축적한다.

```
구현 → 검증 → 평가 → 축적 → 더 나은 구현
         ↑__________________________|
```

---

## 빠른 설치

```bash
# 1. Repository 클론
git clone https://github.com/kk3june/kk3june-skills.git

# 2. 설치 스크립트 실행
cd kk3june-skills
./install.sh
```

또는 수동 설치:

```bash
cp -r skills/* ~/.claude/skills/
```

---

## 스킬 목록

| 스킬 | 설명 | 용도 |
|------|------|------|
| **context-collector** | 프로젝트 스택 탐지 및 스킬 라우팅 | 구현 요청 시 자동 실행 |
| **skill-manager** | 스킬 생성/동기화 관리 | 새 스택 프로젝트, 레퍼런스 업데이트 |
| **impl-frontend-react** | React/Vite 구현 | React 기반 기능 구현 |
| **refactoring** | 코드 품질 개선 (Fowler + Frontend Fundamentals) | 리팩토링 요청 시 |

---

## 스킬 흐름

```
사용자 요청
    ↓
context-collector (스택 탐지)
    ↓
skill-manager (스킬/레퍼런스 확인)
    ↓
impl-frontend-react
    ├── Phase 1: 환경 감지
    ├── Phase 2: 프로젝트 패턴 분석
    ├── Phase 3: 구현
    ├── Phase 4: 코드 출력
    ├── Phase 5: 검증
    └── Phase 6: 패턴 축적 (자기 개선)
    ↓
refactoring (필요 시)
```

---

## 상세 설명

### 1. context-collector

프로젝트 스택을 자동 탐지하고 적절한 스킬로 라우팅합니다.

**탐지 항목:**
- 프레임워크 (React, Vue 등)
- 빌드 도구 (Vite, Webpack 등)
- 주요 라이브러리 (Tailwind, Shadcn, React Hook Form 등)

**스택 탐지 매트릭스:**

| 감지 조건 | 탐지 결과 | 라우팅 스킬 |
|-----------|-----------|-------------|
| `vite.config.*` + `react` | React + Vite | impl-frontend-react |
| `vite.config.*` + `vue` | Vue + Vite | impl-frontend-vue |

---

### 2. skill-manager

스킬의 생성과 레퍼런스 동기화를 관리합니다.

**주요 기능:**
- 프로젝트 스택에 맞는 스킬 존재 확인
- 없으면 새 스킬 생성 제안
- 기존 스킬의 레퍼런스를 프로젝트 의존성과 동기화

**스킬 네이밍 컨벤션:**
```
impl-{layer}-{framework}

예시:
- impl-frontend-react
- impl-frontend-vue
- impl-backend-spring
```

---

### 3. impl-frontend-react

React/Vite 환경에서 기능을 구현합니다.

**핵심 원칙:**
```
프로젝트 패턴 우선 → BP fallback → 안티패턴 체크 → 패턴 축적
```

**레퍼런스 구조:**
```
impl-frontend-react/
├── SKILL.md
└── references/
    ├── best-practices.md   # 핵심 패턴 (fallback용)
    ├── anti-patterns.md    # 피해야 할 것
    ├── sources.md          # 검증된 외부 링크
    ├── react-19.md         # React 문법 가이드
    └── libraries.md        # 라이브러리 레퍼런스
```

**자기 개선 시스템:**
- 구현 완료 후 좋은 패턴 평가
- 재사용 가치 있으면 best-practices.md에 축적
- 다음 구현 시 참조 가능

---

### 4. refactoring

Martin Fowler의 Refactoring 2판 + Frontend Fundamentals 기반으로 코드 품질을 개선합니다.

**4가지 품질 기준 (Frontend Fundamentals):**

| 기준 | 설명 |
|------|------|
| 가독성 | 한 번에 고려할 맥락이 적은가? |
| 예측가능성 | 이름만 보고 동작을 알 수 있는가? |
| 응집도 | 관련 코드가 한 곳에 모여있는가? |
| 결합도 | 수정 시 다른 곳에 영향이 적은가? |

**워크플로우:**
1. Code Smell 분석
2. Frontend Fundamentals 4가지 기준 체크
3. 리팩토링 계획 수립
4. 단계별 실행 (테스트 동반)
5. 완료 보고

---

## 폴더 구조

```
kk3june-skills/
├── README.md
├── install.sh
└── skills/
    ├── context-collector/
    │   └── SKILL.md
    ├── skill-manager/
    │   ├── SKILL.md
    │   └── templates/
    │       ├── impl-frontend.template.md
    │       └── impl-backend.template.md
    ├── impl-frontend-react/
    │   ├── SKILL.md
    │   └── references/
    │       ├── best-practices.md
    │       ├── anti-patterns.md
    │       ├── sources.md
    │       ├── react-19.md
    │       └── libraries.md
    └── refactoring/
        ├── SKILL.md
        └── references/
            ├── frontend-fundamentals.md
            ├── code-smells.md
            ├── techniques.md
            ├── react-patterns.md
            ├── clean-code.md
            ├── solid.md
            └── design-patterns.md
```

---

## 확장

### 새 스킬 추가 (예: Vue)

Vue 프로젝트 시작 시 skill-manager가 자동으로 제안:

```
impl-frontend-vue 스킬이 없습니다.
생성할까요? (Y/N)
```

생성 시:
1. impl-frontend-react 구조 복제
2. Vue 특화 레퍼런스로 교체
3. 프로젝트 의존성 기반 libraries.md 생성

---

## 사용 예시

### 기능 구현

```
User: 로그인 기능 구현해줘

Claude:
1. [context-collector] React + Vite 프로젝트 탐지
2. [impl-frontend-react]
   - 프로젝트 패턴 분석: src/hooks/useAuth.ts 발견
   - 기존 패턴 따라 구현
3. 코드 생성 완료
```

### 리팩토링

```
User: 이 컴포넌트 리팩토링해줘

Claude:
1. [refactoring]
   - Frontend Fundamentals 4가지 기준 체크
   - Code Smell 분석: Props Drilling 발견
   - 개선 방안: Composition 패턴 적용
2. 리팩토링 완료
```

---

## 기여

새로운 스킬이나 레퍼런스 개선 환영합니다:

1. Fork
2. 스킬 추가/수정
3. Pull Request

---

## 라이선스

MIT License

---

## 참고 자료

- [Frontend Fundamentals](https://frontend-fundamentals.com) - 토스 프론트엔드 코드 품질 가이드
- [Bulletproof React](https://github.com/alan2207/bulletproof-react) - React 아키텍처 가이드
- [Refactoring 2nd Edition](https://refactoring.com) - Martin Fowler
