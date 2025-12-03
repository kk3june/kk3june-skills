# Skill Auto-Trigger Rules

사용자 요청 패턴에 따라 적절한 스킬을 자동으로 활성화한다.

## 트리거 매트릭스

| 요청 패턴 | 활성화 스킬 |
|----------|------------|
| "구현해줘", "만들어줘", "추가해줘" | context-collector → impl-frontend-* |
| "리팩토링", "개선", "정리", "클린업" | refactoring |
| "코드 스멜", "안티패턴", "품질" | refactoring |
| "새 프로젝트", "스킬 생성", "레퍼런스 동기화" | skill-manager |

## 스킬 활성화 방법

요청이 위 패턴에 해당하면:

```
1. 해당 스킬의 SKILL.md 읽기
2. 필요한 references/ 파일 로드
3. 스킬에 정의된 Phase 순서대로 진행
```

## 스킬 위치

```
~/.claude/skills/
├── context-collector/SKILL.md
├── skill-manager/SKILL.md
├── impl-frontend-react/SKILL.md
└── refactoring/SKILL.md
```

## 예시

### 리팩토링 요청
```
User: "이 컴포넌트 개선할 부분 있어?"

→ refactoring 스킬 활성화
→ ~/.claude/skills/refactoring/SKILL.md 읽기
→ Phase 1: Code Smell 분석
→ Phase 2: Frontend Fundamentals 4가지 기준 체크
→ ...
```

### 기능 구현 요청
```
User: "로그인 기능 구현해줘"

→ context-collector 스킬 활성화
→ 스택 탐지 (React + Vite)
→ impl-frontend-react 스킬로 라우팅
→ Phase별 구현 진행
```
