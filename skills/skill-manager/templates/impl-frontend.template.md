---
name: impl-frontend-{{FRAMEWORK}}
description: {{FRAMEWORK_FULL_NAME}} 환경에서 공식 문서 기반 Best Practice로 기능 구현. 기존 프로젝트 패턴을 우선하되 최신 권장 사항 적용.
version: 1.0.0
created: {{DATE}}
last_sync: {{DATE}}
stack:
  - {{FRAMEWORK}}
  - typescript
libraries: {{LIBRARIES}}
---

# Implementation: Frontend {{FRAMEWORK_FULL_NAME}}

공식 문서 기반 Best Practice + 기존 프로젝트 패턴 = 고품질 코드

## 핵심 원칙

> **"기존 프로젝트 코드가 곧 컨벤션이다."**
> 공식 문서 Best Practice를 참고하되, 프로젝트 일관성을 우선한다.
> 명백한 안티패턴만 개선을 제안한다.

---

## Phase 1: 환경 감지 및 레퍼런스 로드

### 환경 감지

```bash
# 프레임워크 버전 확인
cat package.json | grep "{{FRAMEWORK}}"

# 설정 파일 확인
ls {{CONFIG_FILES}} 2>/dev/null
```

### 레퍼런스 로드

| 환경 | 로드할 레퍼런스 |
|------|-----------------|
| {{FRAMEWORK}} | `references/{{FRAMEWORK}}.md` + `references/libraries.md` |

---

## Phase 2: 기존 패턴 분석

### 프로젝트 패턴 추출

```bash
# 컴포넌트 패턴
find src/components -name "*.{{EXT}}" -type f | head -3 | xargs head -40

# 훅/컴포저블 패턴
find src/hooks src/composables -name "*.{{EXT}}" -type f 2>/dev/null | head -2 | xargs head -40

# API 패턴
find src/api src/services -name "*.{{EXT}}" -type f 2>/dev/null | head -2 | xargs head -40
```

### 패턴 비교

```markdown
## 패턴 분석 결과

### 프로젝트 패턴 vs Best Practice

| 항목 | 프로젝트 | Best Practice | 판단 |
|------|----------|---------------|------|
| 컴포넌트 선언 | [현재] | [권장] | 유지/개선 |
| 상태 관리 | [현재] | [권장] | 유지/개선 |
| 스타일링 | [현재] | [권장] | 유지/개선 |

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
| 3 | 상태/훅 | `src/hooks/` 또는 `src/composables/` |
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
- [ ] 기존 상태 관리 패턴 준수
- [ ] 기존 API 호출 패턴 준수
- [ ] 네이밍 컨벤션 일치

### Best Practice
- [ ] 성능 최적화 고려
- [ ] 접근성 고려 (필요시)
- [ ] 반응형 고려 (필요시)
```

---

## Phase 4: 코드 출력

### 파일 생성 형식

```markdown
### 파일: `[전체 경로]`

```{{LANG}}
// 전체 파일 내용
// import 문 완전 포함
// 부분 스니펫 X
```
```

### 기존 파일 수정 형식

```markdown
### 파일: `[경로]`

**추가:**
```{{LANG}}
// 추가할 코드
```

**수정:**
```{{LANG}}
// Before:
[기존 코드]

// After:
[수정된 코드]
```
```

---

## Phase 5: 검증

### 자동 검증

```bash
# TypeScript 체크
npx tsc --noEmit

# Lint 체크
npm run lint 2>/dev/null || npx eslint [생성파일]

# 빌드 체크
npm run build 2>/dev/null
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
```{{LANG}}
import { [구현된것] } from '[경로]';
```

### 다음 단계 (선택)
- [ ] 테스트 작성
- [ ] 관련 컴포넌트에 통합
- [ ] 리팩토링 적용 (refactoring 스킬)
```

---

## 레퍼런스 참조 방법

### 공식 문서 기반 구현 시

```markdown
## Best Practice 적용

### 출처
[공식 문서 URL]

### 적용 내용
[적용한 패턴 설명]
```

### 프로젝트 패턴과 충돌 시

```markdown
## 패턴 충돌

### 현재 프로젝트
[프로젝트 패턴]

### Best Practice
[권장 패턴]

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
- 탐지된 스택
- 프로젝트 구조
- 기존 패턴
- 요구사항

### refactoring으로 전달
구현 완료 후 품질 개선이 필요하면:
- 생성된 파일 경로
- 개선 필요 사항
