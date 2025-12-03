# kk3june-skills

사용자 요청 시 각 SKILL.md의 `triggers` 필드를 확인하여 적절한 스킬을 활성화한다.

## 스킬 활성화 방법

1. 사용자 요청에서 키워드 탐지
2. `~/.claude/skills/*/SKILL.md`의 triggers 필드와 매칭
3. 매칭된 스킬의 SKILL.md 로드
4. 스킬에 정의된 Phase 순서대로 진행

## 스킬 목록

| 스킬 | 트리거 예시 |
|------|------------|
| context-collector | "구현해줘", "만들어줘", "기능" |
| skill-manager | "스킬 생성", "레퍼런스 동기화" |
| impl-frontend-react | context-collector가 React/Vite 탐지 시 자동 |
| refactoring | "리팩토링", "개선", "정리", "품질" |

## 스킬 위치

```
~/.claude/skills/
├── context-collector/SKILL.md   # triggers 정의됨
├── skill-manager/SKILL.md       # triggers 정의됨
├── impl-frontend-react/SKILL.md # auto trigger
└── refactoring/SKILL.md         # triggers 정의됨
```
