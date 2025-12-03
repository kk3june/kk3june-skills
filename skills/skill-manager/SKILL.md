---
name: skill-manager
description: 프로젝트 스택에 맞는 impl-* 스킬의 존재 여부를 확인하고, 없으면 생성을 제안하며, 기존 스킬의 레퍼런스를 프로젝트 의존성과 동기화한다.
---

# Skill Manager

프로젝트 스택 기반 동적 스킬 관리 시스템

## 핵심 원칙

> **프로젝트 코드가 곧 레퍼런스다.**
> 일관된 패턴이 있으면 따르고, 없으면 Best Practice로 구현한다.
> 리팩토링으로 패턴이 바뀌면, 다음 작업부터 새 패턴을 따른다.

### 품질 공식

```
코드 품질 = 프로젝트 분석 (일관성) + BP 레퍼런스 (정확성) + 리팩토링 (개선)
```

---

## Phase 1: 스킬 존재 확인

### 스킬 네이밍 컨벤션

```
impl-{layer}-{framework}

예시:
- impl-frontend-react    (React + Vite)
- impl-frontend-vue      (Vue/Nuxt)
- impl-backend-spring    (Spring Boot)
- impl-backend-nestjs    (NestJS)
```

### 스킬 존재 확인

```bash
# 현재 존재하는 impl-* 스킬 목록
ls -d ~/.claude/skills/impl-* 2>/dev/null
```

### 스택 → 스킬 매핑

| 감지된 스택 | 필요한 스킬 |
|-------------|-------------|
| React + Vite | impl-frontend-react |
| Vue + Vite | impl-frontend-vue |
| Nuxt | impl-frontend-vue |
| Spring Boot | impl-backend-spring |
| NestJS | impl-backend-nestjs |
| Express | impl-backend-express |
| Django | impl-backend-django |
| FastAPI | impl-backend-fastapi |

### 프레임워크 공식 문서 URL 매핑

| 프레임워크 | 공식 문서 URL | 핵심 페이지 |
|-----------|--------------|------------|
| React | https://react.dev | /learn, /reference |
| Vue | https://vuejs.org/guide | /essentials, /components |
| Nuxt | https://nuxt.com/docs | /guide, /api |
| Angular | https://angular.dev | /guide, /api |
| Svelte | https://svelte.dev/docs | /kit |
| Spring Boot | https://spring.io/guides | /projects/spring-boot |
| NestJS | https://docs.nestjs.com | /fundamentals, /techniques |
| Express | https://expressjs.com | /guide, /api |
| Django | https://docs.djangoproject.com | /topics, /ref |
| FastAPI | https://fastapi.tiangolo.com | /tutorial, /advanced |

### 주요 라이브러리 문서 URL 매핑

| 라이브러리 | 공식 문서 URL |
|-----------|--------------|
| TypeScript | https://www.typescriptlang.org/docs |
| Tailwind CSS | https://tailwindcss.com/docs |
| Shadcn/ui | https://ui.shadcn.com/docs |
| React Hook Form | https://react-hook-form.com/docs |
| Zod | https://zod.dev |
| TanStack Query | https://tanstack.com/query/latest/docs |
| Zustand | https://zustand-demo.pmnd.rs |
| Axios | https://axios-http.com/docs |
| React Router | https://reactrouter.com/en/main |
| Pinia | https://pinia.vuejs.org |
| Prisma | https://www.prisma.io/docs |
| Drizzle | https://orm.drizzle.team/docs |

---

## Phase 2: 스킬 생성 제안

### 스킬이 없을 때

```markdown
## 스킬 생성 제안

현재 프로젝트 스택: **[감지된 스택]**
필요한 스킬: **impl-{layer}-{framework}**

해당 스킬이 존재하지 않습니다.

### 생성할 스킬 구조
```
~/.claude/skills/impl-{layer}-{framework}/
├── SKILL.md
└── references/
    ├── {framework}.md      # 프레임워크 공식 문서 기반
    └── libraries.md        # 프로젝트 사용 라이브러리
```

### 포함될 레퍼런스
프로젝트 의존성 분석 결과:
- 프레임워크: [감지된 프레임워크]
- 주요 라이브러리: [감지된 라이브러리들]

스킬을 생성할까요? (Y/N)
```

### 템플릿 기반 생성

```bash
# Frontend 스킬 템플릿
cat ~/.claude/skills/skill-manager/templates/impl-frontend.template.md

# Backend 스킬 템플릿
cat ~/.claude/skills/skill-manager/templates/impl-backend.template.md
```

---

## Phase 3: 레퍼런스 동기화

### 동기화 필요 여부 확인

```markdown
## 레퍼런스 동기화 검사

### 프로젝트 의존성
| 라이브러리 | 버전 | 레퍼런스 존재 |
|------------|------|--------------|
| react | 19.0.0 | O |
| tailwindcss | 4.0.0 | O |
| @tanstack/react-query | 5.x | X (추가 필요) |
| axios | 1.x | X (추가 필요) |

### 레퍼런스에만 존재 (프로젝트 미사용)
- redux (제거 가능)
- styled-components (제거 가능)

### 권장 액션
1. 추가: react-query, axios 레퍼런스
2. 제거: redux, styled-components 레퍼런스
3. 업데이트: tailwindcss v3 → v4

동기화를 진행할까요?
```

### 동기화 수행

```markdown
## 동기화 수행

### 1. 레퍼런스 추가
`references/libraries.md`에 다음 섹션 추가:
- React Query (TanStack Query)
- Axios

### 2. 레퍼런스 제거
`references/libraries.md`에서 다음 섹션 제거:
- Redux
- Styled Components

### 3. 버전 업데이트
`references/libraries.md`의 Tailwind CSS 섹션을 v4 기준으로 업데이트

진행할까요?
```

---

## Phase 4: 스킬 생성 실행

### Step 1: 디렉토리 구조 생성

```bash
# 디렉토리 생성
mkdir -p ~/.claude/skills/impl-frontend-{framework}/references
```

### Step 2: SKILL.md 생성 (템플릿 기반)

```bash
# 템플릿 로드
cat ~/.claude/skills/skill-manager/templates/impl-frontend.template.md

# 변수 치환하여 SKILL.md 생성
# {{FRAMEWORK}} → vue
# {{FRAMEWORK_FULL_NAME}} → Vue 3
# {{DATE}} → 현재 날짜
# {{LIBRARIES}} → 프로젝트 dependencies에서 추출
```

### Step 3: 최소 BP 레퍼런스 생성

**references/ 구조:**

```
references/
├── best-practices.md   # 핵심 패턴 (10개 이내)
├── anti-patterns.md    # 피해야 할 것
└── sources.md          # 검증된 외부 소스 링크
```

**best-practices.md 초기 내용:**
1. 컴포넌트 분리 기준
2. 상태 관리 선택 기준
3. API 호출 패턴
4. 에러 처리 패턴
5. 타입 정의 패턴

**anti-patterns.md:**
- Props Drilling
- useEffect 남용
- 과도한 추상화
- 등등

**sources.md:**
- 공식 문서 URL
- 검증된 가이드 (Bulletproof React, Frontend Fundamentals 등)
- 참고할 오픈소스 프로젝트

### Step 4: 생성 결과 검증

```markdown
## 스킬 생성 완료

### 생성된 파일
| 파일 | 내용 | 상태 |
|------|------|------|
| SKILL.md | 스킬 워크플로우 | ✅ |
| references/{framework}.md | 프레임워크 가이드 | ✅ |
| references/libraries.md | 라이브러리 레퍼런스 | ✅ |

### 수집된 레퍼런스 요약
- 프레임워크: {framework} v{version}
- 라이브러리: {count}개
  - {lib1}, {lib2}, {lib3}...

### 품질 체크
- [ ] 프레임워크 핵심 패턴 포함
- [ ] 프로젝트 사용 라이브러리 전체 포함
- [ ] 코드 예시 포함
- [ ] 최신 버전 기준

### 다음 단계
1. 생성된 레퍼런스 파일 검토
2. 프로젝트 특화 패턴 추가 (선택)
3. 구현 요청 시 해당 스킬 자동 사용

이제 `impl-frontend-{framework}` 스킬을 사용할 수 있습니다.
```

---

## Phase 5: 구현 시 워크플로우

### 프로젝트 분석 우선 원칙

```
구현 요청
    ↓
프로젝트 코드 분석 (Grep/Glob)
    ↓
┌─────────────────┬─────────────────┐
│ 일관된 패턴 있음  │ 일관된 패턴 없음  │
└────────┬────────┴────────┬────────┘
         ↓                  ↓
    패턴 품질 체크       BP 레퍼런스 참조
         │                  │
    ┌────┴────┐            │
    ↓         ↓            │
  양호     안티패턴          │
   │         │             │
   ↓         ↓             ↓
 따라감   BP 권장      BP대로 구현
   │         │             │
   └────┬────┴─────────────┘
        ↓
     코드 생성
        ↓
   (리팩토링 시 패턴 갱신)
        ↓
    다음 작업은 새 패턴 기반
```

### Step 1: 유사 코드 탐색

```bash
# 컴포넌트 패턴 찾기
find src/components -name "*.tsx" | head -3 | xargs head -50

# 훅 패턴 찾기
find src/hooks -name "*.ts" | head -2 | xargs head -40

# API 호출 패턴 찾기
grep -r "axios\|fetch\|useMutation\|useQuery" src/ -l | head -3
```

### Step 2: 패턴 유무 판단

```markdown
## 패턴 분석 결과

### 컴포넌트 패턴
- [ ] 존재함 → 파일: `src/components/Button.tsx`
- [ ] 없음 → BP 참조

### 상태 관리 패턴
- [ ] 존재함 → 파일: `src/hooks/useAuth.ts`
- [ ] 없음 → BP 참조

### API 호출 패턴
- [ ] 존재함 → 파일: `src/api/user.ts`
- [ ] 없음 → BP 참조
```

### Step 3: 안티패턴 체크

프로젝트 패턴이 있어도 안티패턴이면 BP 권장:

```markdown
## 안티패턴 감지

발견된 패턴: Props를 5단계 이상 전달
→ 안티패턴: Props Drilling

**권장:** Context 또는 Composition 패턴 사용
**참조:** references/anti-patterns.md

기존 패턴을 따를까요, BP를 적용할까요?
```

### Step 4: BP 축적 (선택)

좋은 패턴 발견/생성 시:

```markdown
## BP 추가 제안

방금 구현한 패턴이 좋아 보입니다:
- 패턴명: Optimistic Update with Error Rollback
- 파일: `src/hooks/useOptimisticMutation.ts`

references/best-practices.md에 추가할까요? (Y/N)
```

---

## 스킬 메타데이터

### 스킬 버전 관리

각 스킬의 SKILL.md에 메타데이터 포함:

```yaml
---
name: impl-frontend-react
description: React + Vite 환경 구현 스킬
version: 1.0.0
created: 2024-12-03
last_sync: 2024-12-03
stack:
  - react
  - vite
  - typescript
libraries:
  - tailwindcss
  - shadcn/ui
  - react-hook-form
  - zod
  - tanstack-query
---
```

### 동기화 히스토리

```markdown
## 동기화 로그

| 날짜 | 액션 | 상세 |
|------|------|------|
| 2024-12-03 | 생성 | 초기 스킬 생성 |
| 2024-12-10 | 추가 | react-query 레퍼런스 |
| 2024-12-15 | 제거 | axios (fetch로 대체) |
```

---

## 연계

### context-collector → skill-manager

```markdown
context-collector에서 스택 탐지 완료 후:

1. skill-manager로 스킬 확인 요청
2. 스킬 존재 → impl-* 스킬로 이동
3. 스킬 부재 → 생성 제안
4. 레퍼런스 구버전 → 동기화 제안
```

### skill-manager → impl-* 스킬

```markdown
스킬 생성/동기화 완료 후:

1. 해당 impl-* 스킬 활성화
2. 레퍼런스 로드
3. 구현 진행
```

---

## 주의사항

### 자동 생성 제한

- 스킬/레퍼런스 생성/수정은 **항상 사용자 승인 후** 진행
- 삭제는 더 신중하게 (확인 2회)

### 레퍼런스 품질

- 자동 생성 레퍼런스는 **공식 문서 WebFetch 기반**
- 수집 실패 시 사용자에게 알리고 수동 보강 요청
- 수집 성공 시에도 **사용자 검토 권장**
- 프로젝트 특화 패턴은 사용하면서 점진적으로 추가

### 스킬 통합/분리 기준

```markdown
통합 권장:
- React + Vite → impl-frontend-react (하나로)
- Vue + Nuxt → impl-frontend-vue (하나로)

분리 권장:
- React Native → impl-mobile-react-native (별도)
- Flutter → impl-mobile-flutter (별도)
- Electron → impl-desktop-electron (별도)
```
