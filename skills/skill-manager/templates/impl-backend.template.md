---
name: impl-backend-{{FRAMEWORK}}
description: {{FRAMEWORK_FULL_NAME}} 환경에서 공식 문서 기반 Best Practice로 API/서비스 구현. 기존 프로젝트 패턴을 우선하되 최신 권장 사항 적용.
version: 1.0.0
created: {{DATE}}
last_sync: {{DATE}}
stack:
  - {{FRAMEWORK}}
  - {{LANGUAGE}}
libraries: {{LIBRARIES}}
---

# Implementation: Backend {{FRAMEWORK_FULL_NAME}}

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
{{VERSION_CHECK_COMMAND}}

# 설정 파일 확인
ls {{CONFIG_FILES}} 2>/dev/null

# 프로젝트 구조 확인
ls -la src/ 2>/dev/null || ls -la app/ 2>/dev/null
```

### 레퍼런스 로드

| 환경 | 로드할 레퍼런스 |
|------|-----------------|
| {{FRAMEWORK}} | `references/{{FRAMEWORK}}.md` + `references/libraries.md` |

---

## Phase 2: 기존 패턴 분석

### 프로젝트 패턴 추출

```bash
# Controller/Route 패턴
find . -name "*Controller*" -o -name "*Route*" | head -3 | xargs head -40

# Service 패턴
find . -name "*Service*" | head -3 | xargs head -40

# Repository/DAO 패턴
find . -name "*Repository*" -o -name "*Dao*" | head -2 | xargs head -40
```

### 아키텍처 패턴 확인

```markdown
## 아키텍처 분석

### 레이어 구조
- [ ] Controller - Service - Repository (3-tier)
- [ ] Hexagonal / Clean Architecture
- [ ] CQRS
- [ ] 기타: [설명]

### API 스타일
- [ ] REST
- [ ] GraphQL
- [ ] gRPC
- [ ] 기타: [설명]

### 데이터베이스
- [ ] ORM: [ORM 이름]
- [ ] Query Builder
- [ ] Raw SQL
```

---

## Phase 3: 구현

### 구현 순서

| 순서 | 대상 | 위치 |
|------|------|------|
| 1 | Entity/Model | `src/entities/` 또는 `src/models/` |
| 2 | DTO (요청/응답) | `src/dto/` |
| 3 | Repository | `src/repositories/` |
| 4 | Service | `src/services/` |
| 5 | Controller | `src/controllers/` |
| 6 | Route 등록 | 프레임워크별 상이 |

**위치는 프로젝트 실제 구조에 맞게 조정**

### 구현 체크리스트

```markdown
## 구현 체크리스트

### 필수
- [ ] 타입/스키마 완전 정의
- [ ] 입력 유효성 검증
- [ ] 에러 처리 (적절한 HTTP 상태 코드)
- [ ] 로깅 포함
- [ ] import/의존성 완전 포함

### 패턴 일관성
- [ ] 기존 레이어 구조 준수
- [ ] 기존 네이밍 컨벤션 준수
- [ ] 기존 에러 처리 패턴 준수
- [ ] 기존 응답 포맷 준수

### Best Practice
- [ ] 비즈니스 로직은 Service에
- [ ] 트랜잭션 관리
- [ ] 적절한 캐싱 (필요시)
- [ ] 보안 고려 (인증/인가)
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

### API 엔드포인트 문서

```markdown
## API 엔드포인트

### [HTTP Method] /api/[경로]

**설명:** [기능 설명]

**요청:**
```json
{
  "field": "type"
}
```

**응답:**
```json
{
  "field": "type"
}
```

**에러 응답:**
| 상태 코드 | 설명 |
|----------|------|
| 400 | 잘못된 요청 |
| 401 | 인증 필요 |
| 404 | 리소스 없음 |
| 500 | 서버 에러 |
```

---

## Phase 5: 검증

### 자동 검증

```bash
# 타입 체크 (언어별)
{{TYPE_CHECK_COMMAND}}

# Lint 체크
{{LINT_COMMAND}}

# 빌드 체크
{{BUILD_COMMAND}}

# 테스트 (있으면)
{{TEST_COMMAND}}
```

### 검증 보고

```markdown
## 구현 완료

### 검증 결과
- 타입 체크: 에러 없음
- Lint: 통과
- 빌드: 성공
- 기존 패턴 준수: 확인

### 생성된 파일
1. `[경로]` — [역할]

### API 엔드포인트
| Method | Path | 설명 |
|--------|------|------|
| POST | /api/users | 사용자 생성 |

### 다음 단계 (선택)
- [ ] 테스트 작성
- [ ] API 문서화 (Swagger 등)
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
