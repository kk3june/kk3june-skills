---
name: refactoring
description: Martin Fowler의 Refactoring 2판과 Clean Code 원칙 기반 체계적 리팩토링. Code Smells 탐지 → 기법 적용 → 테스트 검증 워크플로우.
---

# Refactoring Skill

> "리팩토링은 외부 동작을 바꾸지 않으면서 내부 구조를 개선하는 것이다." — Martin Fowler

## 핵심 원칙

### 리팩토링의 정의
- **행동 보존**: 외부에서 관찰 가능한 동작은 변하지 않음
- **작은 단계**: 각 변경은 "너무 작아서 할 가치가 없어 보일" 정도로 작게
- **테스트 동반**: 매 단계마다 테스트 실행하여 동작 확인
- **버그 보존**: 리팩토링은 버그도 보존한다 (버그 수정은 별도 작업)

### Boy Scout Rule
> "캠프장을 발견했을 때보다 깨끗하게 남겨라"

코드를 읽을 때마다 조금씩 개선한다.

---

## Workflow

### Step 1: 코드 분석 및 Smell 탐지

```bash
# 대상 파일/디렉토리 확인
view [target_path]
```

**references/frontend-fundamentals.md** 로드하여 4가지 기준 체크:

```bash
cat ~/.claude/skills/refactoring/references/frontend-fundamentals.md
```

**references/code-smells.md** 로드하여 Code Smells 체크:

```bash
cat ~/.claude/skills/refactoring/references/code-smells.md
```

### Step 2: Smell 보고서 작성

```markdown
## 🔍 코드 품질 분석 결과

### 파일: `src/components/UserDashboard.tsx`

### Frontend Fundamentals 4가지 기준

| 기준 | 상태 | 이슈 |
|------|------|------|
| 가독성 | 🔴 | 동시에 실행되지 않는 코드가 섞여있음 |
| 예측가능성 | 🟡 | 함수명과 실제 동작 불일치 |
| 응집도 | 🟢 | 관련 코드가 적절히 모여있음 |
| 결합도 | 🔴 | Props Drilling 발생 |

### Code Smells

| Smell | 심각도 | 위치 | 설명 |
|-------|--------|------|------|
| Long Function | 🔴 High | L45-L180 | 135줄, 5개 이상의 책임 |
| Feature Envy | 🟡 Medium | L67-L89 | user 객체 메서드 과다 호출 |
| Primitive Obsession | 🟡 Medium | L23 | status를 string으로 관리 |
| Magic Numbers | 🟢 Low | L56, L78 | 하드코딩된 숫자 |

### 우선순위
1. **Long Function** → Extract Function (가독성 개선)
2. **Props Drilling** → Composition 패턴 (결합도 개선)
3. **Feature Envy** → Move Function
4. **Primitive Obsession** → Replace Primitive with Object
```

### Step 3: 테스트 현황 확인

```bash
# 테스트 파일 존재 확인
ls src/**/*.test.ts src/**/*.test.tsx

# 테스트 실행
npm run test -- --coverage
```

**테스트가 없으면:**
```markdown
⚠️ 테스트가 없습니다. 리팩토링 전 테스트 작성을 권장합니다.

옵션:
1. 테스트 먼저 작성 후 리팩토링 (권장)
2. 작은 범위만 리팩토링하고 수동 검증
3. 리팩토링과 함께 테스트 작성

어떤 방식으로 진행할까요?
```

### Step 4: 리팩토링 계획 수립

```markdown
## 📋 리팩토링 계획

### Phase 1: 안전한 변경 (비파괴적)
- [ ] 변수/함수 이름 개선 (Rename)
- [ ] 매직 넘버 → 상수 추출
- [ ] 타입 정의 추가/개선

### Phase 2: 구조 개선
- [ ] Long Function → Extract Function
- [ ] Feature Envy → Move Function
- [ ] 중복 코드 → Extract & Reuse

### Phase 3: 설계 개선
- [ ] Primitive Obsession → Value Object
- [ ] 조건문 → Polymorphism
- [ ] 의존성 정리

### 영향 범위
- 직접 수정: `UserDashboard.tsx`
- 간접 영향: `UserPage.tsx` (import 변경)
- 테스트 수정: `UserDashboard.test.tsx`

---
이 계획으로 진행할까요? Phase별로 나눠서 진행할까요?
```

### Step 5: 단계별 리팩토링 실행

각 리팩토링마다:

```markdown
### 🔧 리팩토링: Extract Function

**Before:**
```typescript
// src/components/UserDashboard.tsx L45-L65
function UserDashboard() {
  // ... 20줄의 데이터 정규화 로직
  const normalized = data.map(item => ({
    id: item.id,
    name: item.firstName + ' ' + item.lastName,
    // ... 많은 변환 로직
  }));
}
```

**After:**
```typescript
// src/components/UserDashboard.tsx
function UserDashboard() {
  const normalized = normalizeUserData(data);
}

// src/utils/userDataNormalizer.ts (새 파일)
export function normalizeUserData(data: RawUserData[]): NormalizedUser[] {
  return data.map(item => ({
    id: item.id,
    name: formatFullName(item.firstName, item.lastName),
    // ...
  }));
}
```

**검증:**
```bash
npm run test
npm run lint
```
```

### Step 6: 완료 보고

```markdown
## ✅ 리팩토링 완료

### 변경 요약
| 항목 | Before | After |
|------|--------|-------|
| 파일 수 | 1 | 3 |
| 최대 함수 길이 | 135줄 | 25줄 |
| 테스트 커버리지 | 45% | 78% |
| Smell 개수 | 4 | 0 |

### 변경된 파일
1. `src/components/UserDashboard.tsx` — 구조 개선
2. `src/utils/userDataNormalizer.ts` — 새 파일
3. `src/types/user.ts` — 타입 추가

### 다음 단계 (선택)
- [ ] 유사한 다른 컴포넌트에 동일 패턴 적용
- [ ] 추가 테스트 작성
- [ ] 문서화
```

---

## 리팩토링 원칙

### 1. 작은 단계로 진행

❌ **나쁨**: 여러 리팩토링을 한 번에
```
- 함수 추출 + 이름 변경 + 파일 이동 + 타입 변경
```

✅ **좋음**: 하나씩 순차적으로
```
1. 함수 추출 → 테스트 → 커밋
2. 이름 변경 → 테스트 → 커밋
3. 파일 이동 → 테스트 → 커밋
```

### 2. 테스트가 통과할 때만 다음 단계

```
리팩토링 → 테스트 실행 → 
  ├─ 통과 → 커밋 → 다음 리팩토링
  └─ 실패 → 되돌리기 → 더 작은 단계로 재시도
```

### 3. 리팩토링과 기능 변경 분리

```
❌ "리팩토링하면서 버그도 수정할게요"
✅ "먼저 리팩토링하고, 별도 커밋으로 버그 수정합니다"
```

### 4. 의미 있는 커밋 메시지

```
refactor: Extract normalizeUserData from UserDashboard
refactor: Move user types to dedicated file
refactor: Replace magic numbers with constants
```

---

## SOLID 원칙 체크리스트

리팩토링 시 SOLID 위반 여부 확인:

### S - Single Responsibility (단일 책임)
- [ ] 클래스/함수가 하나의 이유로만 변경되는가?
- [ ] "이 함수는 무엇을 하는가?"를 한 문장으로 설명 가능한가?

### O - Open/Closed (개방/폐쇄)
- [ ] 새 기능 추가 시 기존 코드 수정 없이 확장 가능한가?
- [ ] switch/case가 여러 곳에 중복되어 있지 않은가?

### L - Liskov Substitution (리스코프 치환)
- [ ] 자식 클래스가 부모 클래스를 완전히 대체할 수 있는가?
- [ ] 상속 구조가 "is-a" 관계를 만족하는가?

### I - Interface Segregation (인터페이스 분리)
- [ ] 인터페이스가 너무 크지 않은가?
- [ ] 사용하지 않는 메서드를 구현하도록 강제하지 않는가?

### D - Dependency Inversion (의존성 역전)
- [ ] 고수준 모듈이 저수준 모듈에 직접 의존하지 않는가?
- [ ] 추상화에 의존하고 있는가?

---

## React 특화 리팩토링

**references/react-patterns.md** 참조:

```bash
cat ~/.claude/skills/refactoring/references/react-patterns.md
```

### 주요 패턴

| Smell | 리팩토링 | 결과 |
|-------|----------|------|
| Prop Drilling | Context 또는 Composition | 깔끔한 데이터 흐름 |
| God Component | Container/Presentational 분리 | 단일 책임 |
| Inline Handlers | Custom Hook 추출 | 재사용성 |
| Duplicate Fetching | Custom Hook + Cache | 성능 개선 |
| Complex Conditionals | 컴포넌트 분리 | 가독성 |

---

## 안전망: 테스트 전략

### 리팩토링 전 최소 테스트

```typescript
// 1. 스냅샷 테스트 (UI 변경 감지)
it('renders correctly', () => {
  const { container } = render(<UserDashboard />);
  expect(container).toMatchSnapshot();
});

// 2. 핵심 동작 테스트
it('displays user data', async () => {
  render(<UserDashboard />);
  expect(await screen.findByText('John Doe')).toBeInTheDocument();
});

// 3. 인터랙션 테스트
it('handles user click', async () => {
  const onSelect = vi.fn();
  render(<UserDashboard onSelect={onSelect} />);
  await userEvent.click(screen.getByRole('button'));
  expect(onSelect).toHaveBeenCalled();
});
```

### 테스트 커버리지 목표

| 리팩토링 규모 | 최소 커버리지 |
|---------------|---------------|
| 단일 함수 | 해당 함수 100% |
| 컴포넌트 구조 변경 | 컴포넌트 80% |
| 모듈 분리 | 관련 모듈 70% |
| 아키텍처 변경 | 전체 60% |

---

## 참조 문서

- `references/frontend-fundamentals.md` — **프론트엔드 코드 품질 4가지 기준** (가독성, 예측가능성, 응집도, 결합도)
- `references/code-smells.md` — Code Smells 카탈로그
- `references/techniques.md` — 리팩토링 기법
- `references/react-patterns.md` — React 특화 패턴
- `references/clean-code.md` — Clean Code 원칙
- `references/solid.md` — SOLID 원칙
- `references/design-patterns.md` — 디자인 패턴

---

## 주의사항

### 리팩토링하지 말아야 할 때

1. **데드라인 직전**: 리팩토링은 장기 투자
2. **완전히 재작성이 나을 때**: 레거시가 너무 심하면 새로 작성
3. **이해하지 못한 코드**: 먼저 이해하고 리팩토링
4. **테스트 없이 큰 변경**: 작은 범위만 또는 테스트 먼저

### 리팩토링해야 할 때

1. **기능 추가 전**: "이 코드에 기능 추가하기 어렵네"
2. **버그 수정 전**: "이 코드 구조 때문에 버그가 생겼네"
3. **코드 리뷰 중**: "이 부분 개선하면 좋겠네"
4. **코드 이해 중**: "이해하려고 정리하는 김에"
