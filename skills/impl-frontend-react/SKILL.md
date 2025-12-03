---
name: impl-frontend-react
description: React/Vite 환경에서 공식 문서 기반 Best Practice로 기능 구현. 기존 프로젝트 패턴을 우선하되 최신 권장 사항 적용.
---

# Implementation: Frontend React

공식 문서 기반 Best Practice + 기존 프로젝트 패턴 = 고품질 코드

## 핵심 원칙

> **"기존 프로젝트 코드가 곧 컨벤션이다."**
> 프로젝트 패턴을 우선하고, 없으면 BP를 따른다.
> 안티패턴은 개선을 제안하고, 좋은 패턴은 축적한다.

### 개선 사이클

```
구현 → 검증 → 평가 → 축적 → 더 나은 구현
         ↑__________________________|
```

---

## Phase 1: 환경 감지 및 레퍼런스 로드

### 환경 감지

```bash
# React + Vite 확인
ls vite.config.* 2>/dev/null && cat package.json | grep -q '"react"' && echo "REACT_VITE"
```

### 레퍼런스 로드

```bash
# 레퍼런스 로드
cat ~/.claude/skills/impl-frontend-react/references/react-19.md
cat ~/.claude/skills/impl-frontend-react/references/libraries.md
```

---

## Phase 2: 기존 패턴 분석

### 프로젝트 패턴 추출

```bash
# 최근 수정된 컴포넌트
find src/components -name "*.tsx" -type f | head -3 | xargs head -40

# 훅 패턴
find src/hooks -name "*.ts" -type f | head -2 | xargs head -40

# API 패턴
find src/api src/services -name "*.ts" -type f 2>/dev/null | head -2 | xargs head -40
```

### 패턴 비교

```markdown
## 패턴 분석 결과

### 프로젝트 패턴 vs Best Practice

| 항목 | 프로젝트 | Best Practice | 판단 |
|------|----------|---------------|------|
| 컴포넌트 선언 | [현재] | function | 유지/개선 |
| Props 타입 | [현재] | interface | 유지/개선 |
| 상태 관리 | [현재] | React Query | 유지/개선 |

### 결정
- 유지: [프로젝트 패턴 따름]
- 개선 제안: [안티패턴인 경우만]
```

---

## Phase 3: 구현

### 구현 순서

| 순서 | 대상 | 위치 |
|------|------|------|
| 1 | 타입 정의 | `src/types/[도메인].ts` |
| 2 | API/서비스 | `src/api/` 또는 `src/services/` |
| 3 | 커스텀 훅 | `src/hooks/use[기능].ts` |
| 4 | 컴포넌트 | `src/components/[도메인]/` |
| 5 | 페이지 | `src/pages/` 또는 `src/app/` |

**위치는 프로젝트 실제 구조에 맞게 조정**

### 구현 체크리스트

```markdown
## 구현 체크리스트

### 필수
- [ ] TypeScript 타입 완전 정의
- [ ] 에러 처리 포함
- [ ] 로딩 상태 처리
- [ ] import 문 완전 포함

### 패턴 일관성
- [ ] 기존 컴포넌트와 동일한 선언 방식
- [ ] 기존 훅과 동일한 반환 형태
- [ ] 기존 API 호출 패턴 준수
- [ ] 네이밍 컨벤션 일치

### Best Practice
- [ ] 불필요한 리렌더링 방지
- [ ] 적절한 메모이제이션
- [ ] 접근성 고려 (aria, semantic HTML)
```

---

## Phase 4: 코드 출력

### 파일 생성 형식

```markdown
### 파일: `[전체 경로]`

```typescript
// 전체 파일 내용
// import 문 완전 포함
// 부분 스니펫 X
```
```

### 기존 파일 수정 형식

```markdown
### 파일: `[경로]`

**추가:**
```typescript
// 추가할 코드
```

**수정:**
```typescript
// Before:
[기존 코드]

// After:
[수정된 코드]
```
```

### 복수 파일 시

```markdown
## 생성/수정 파일 목록

1. `src/types/user.ts` — 타입 정의
2. `src/api/user.ts` — API 클라이언트
3. `src/hooks/useUser.ts` — 커스텀 훅
4. `src/components/user/UserCard.tsx` — 컴포넌트
```

---

## Phase 5: 검증

### 자동 검증

```bash
# TypeScript 체크
npx tsc --noEmit

# Lint 체크
npm run lint 2>/dev/null || npx eslint [생성파일]

# 테스트 (있으면)
npm run test 2>/dev/null
```

### 검증 보고

```markdown
## 구현 완료

### 검증 결과
- TypeScript: 에러 없음
- Lint: 통과
- 기존 패턴 준수: 확인

### 생성된 파일
1. `[경로]` — [역할]

### 사용 방법
```typescript
import { [구현된것] } from '[경로]';
```

### 다음 단계 (선택)
- [ ] 테스트 작성
- [ ] 관련 컴포넌트에 통합
- [ ] 리팩토링 적용 (refactoring 스킬)
```

---

## Phase 6: 패턴 축적 (스킬 개선)

### 평가 기준

구현 완료 후 다음을 체크:

```markdown
## 패턴 평가

이번 구현에서 좋은 패턴이 나왔는가?

- [ ] 재사용 가치가 있는 패턴인가?
- [ ] 프로젝트에 처음 도입된 패턴인가?
- [ ] 기존 BP보다 나은 방식인가?
- [ ] 다른 기능에도 적용 가능한가?

2개 이상 해당 → 축적 고려
```

### 축적 프로세스

```markdown
## 패턴 축적 제안

### 발견된 패턴
- 패턴명: [예: Optimistic Update with Rollback]
- 파일: `src/hooks/useOptimisticMutation.ts`
- 용도: [언제 사용하면 좋은지]

### 코드
```typescript
// 핵심 코드 예시
```

### 적용 예시
- `src/features/cart/useUpdateCart.ts`

---
이 패턴을 `references/best-practices.md`에 추가할까요? (Y/N)
```

### 축적 시 업데이트

```bash
# best-practices.md의 "추가된 패턴" 섹션에 추가
# 형식:
### [패턴명]
- 발견 일자: YYYY-MM-DD
- 출처: [파일 경로]

#### 용도
[설명]

#### 코드
```typescript
// 예시
```
```

### 축적하지 않을 때

- 프로젝트 특화 패턴 (범용성 없음)
- 이미 BP에 있는 패턴
- 임시 해결책 (추후 개선 필요)

---

## 레퍼런스 참조 방법

### 공식 문서 기반 구현 시

```markdown
## Best Practice 적용

### 출처
[공식 문서 URL]

### 적용 내용
[적용한 패턴 설명]

### 코드
```typescript
// 공식 문서 권장 패턴
```
```

### 프로젝트 패턴과 충돌 시

```markdown
## 패턴 충돌

### 현재 프로젝트
```typescript
// 프로젝트 패턴
```

### Best Practice
```typescript
// 권장 패턴
```

### 결정
**프로젝트 패턴 유지** (일관성 우선)

또는

**Best Practice 적용 권장**
- 이유: [안티패턴 설명]
- 영향: [변경 범위]

어떻게 진행할까요?
```

---

## 연계 스킬

### context-collector에서 받는 정보
- 탐지된 스택 (React + Vite)
- 프로젝트 구조
- 기존 패턴
- 요구사항

### refactoring으로 전달
구현 완료 후 품질 개선이 필요하면:
- 생성된 파일 경로
- 개선 필요 사항
