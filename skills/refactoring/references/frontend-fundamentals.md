# Frontend Fundamentals - 코드 품질 가이드

> 출처: https://frontend-fundamentals.com/code-quality/
> "좋은 프론트엔드 코드는 **변경하기 쉬운** 코드다"

---

## 4가지 핵심 기준

| 기준 | 정의 | 핵심 질문 |
|------|------|----------|
| **가독성** | 코드가 읽기 쉬운 정도 | "한 번에 고려해야 할 맥락이 적은가?" |
| **예측 가능성** | 동작을 예측할 수 있는 정도 | "이름만 보고 동작을 알 수 있는가?" |
| **응집도** | 수정되어야 할 코드가 함께 수정되는 정도 | "관련 코드가 한 곳에 모여있는가?" |
| **결합도** | 코드 수정 시 영향 범위 | "수정 시 다른 곳에 영향이 적은가?" |

**주의**: 4가지 기준을 모두 동시에 충족하기는 어렵다. 상황에 따라 우선순위를 조정해야 한다.

---

## 1. 가독성 (Readability)

### 1.1 맥락 줄이기 - 같이 실행되지 않는 코드 분리

**Before:**
```tsx
function SubmitButton() {
  const isViewer = useRole() === "viewer";

  useEffect(() => {
    if (isViewer) {
      return;
    }
    showButtonAnimation();
  }, [isViewer]);

  return isViewer ? (
    <TextButton disabled>Submit</TextButton>
  ) : (
    <Button type="submit">Submit</Button>
  );
}
```

**문제**: 동시에 실행되지 않는 코드(viewer vs 일반 사용자)가 교차되어 이해하기 어려움

**After:**
```tsx
function SubmitButton() {
  const isViewer = useRole() === "viewer";
  return isViewer ? <ViewerSubmitButton /> : <AdminSubmitButton />;
}

function ViewerSubmitButton() {
  return <TextButton disabled>Submit</TextButton>;
}

function AdminSubmitButton() {
  useEffect(() => {
    showButtonAnimation();
  }, []);
  return <Button type="submit">Submit</Button>;
}
```

**개선**: 분기 로직 단순화, 각 컴포넌트가 하나의 상태만 관리

---

### 1.2 이름 붙이기 - 복잡한 조건에 이름 부여

**Before:**
```typescript
const result = products.filter((product) =>
  product.categories.some(
    (category) =>
      category.id === targetCategory.id &&
      product.prices.some((price) => price >= minPrice && price <= maxPrice)
  )
);
```

**After:**
```typescript
const matchedProducts = products.filter((product) => {
  return product.categories.some((category) => {
    const isSameCategory = category.id === targetCategory.id;
    const isPriceInRange = product.prices.some(
      (price) => price >= minPrice && price <= maxPrice
    );

    return isSameCategory && isPriceInRange;
  });
});
```

**기준**:
- 이름 붙이기 **좋을 때**: 복잡한 로직, 재사용 필요, 단위 테스트 필요
- 이름 붙이기 **불필요할 때**: 간단한 로직, 한 번만 사용

---

## 2. 예측 가능성 (Predictability)

### 2.1 이름 겹치지 않게 관리하기

**Before:**
```typescript
// http.ts
import { http as httpLibrary } from "@some-library/http";

export const http = {
  async get(url: string) {
    const token = await fetchToken();
    return httpLibrary.get(url, {
      headers: { Authorization: `Bearer ${token}` }
    });
  }
};
```

**문제**: `http.get`이 단순 GET으로 보이지만 실제로는 인증 로직이 숨겨져 있음

**After:**
```typescript
// httpService.ts
import { http as httpLibrary } from "@some-library/http";

export const httpService = {
  async getWithAuth(url: string) {
    const token = await fetchToken();
    return httpLibrary.get(url, {
      headers: { Authorization: `Bearer ${token}` }
    });
  }
};
```

**개선**: 객체명(`httpService`)과 메서드명(`getWithAuth`)으로 동작을 명확히 표현

---

### 2.2 숨은 로직 드러내기

**Before:**
```typescript
async function fetchBalance(): Promise<number> {
  const balance = await http.get<number>("...");
  logging.log("balance_fetched");  // 숨겨진 부작용!
  return balance;
}
```

**문제**: 함수 이름과 반환 타입만으로는 로깅이 발생하는지 알 수 없음

**After:**
```typescript
// 함수는 순수하게
async function fetchBalance(): Promise<number> {
  const balance = await http.get<number>("...");
  return balance;
}

// 로깅은 호출부에서 명시적으로
<Button onClick={async () => {
  const balance = await fetchBalance();
  logging.log("balance_fetched");
  await syncBalance(balance);
}}>
  계좌 잔액 갱신하기
</Button>
```

**원칙**: 함수는 이름과 파라미터로 예측 가능한 동작만 수행해야 함

---

## 3. 응집도 (Cohesion)

### 3.1 매직 넘버 없애기

**Before:**
```typescript
async function onLikeClick() {
  await postLike(url);
  await delay(300);  // 300이 뭐지?
  await refetchPostLike();
}
```

**문제**: 300의 의미가 불명확, 애니메이션 변경 시 동기화 안 될 위험

**After:**
```typescript
const ANIMATION_DELAY_MS = 300;

async function onLikeClick() {
  await postLike(url);
  await delay(ANIMATION_DELAY_MS);
  await refetchPostLike();
}
```

**개선**: 상수로 의도를 명확히 하고 유지보수성 향상

---

### 3.2 함께 수정되는 파일을 같은 디렉토리에

```
# Bad: 기능별 분리
src/
├── components/
│   └── UserProfile.tsx
├── hooks/
│   └── useUserProfile.ts
├── types/
│   └── userProfile.ts
└── utils/
    └── userProfileFormatter.ts

# Good: 도메인별 응집
src/
└── features/
    └── user-profile/
        ├── UserProfile.tsx
        ├── useUserProfile.ts
        ├── types.ts
        └── formatter.ts
```

---

## 4. 결합도 (Coupling)

### 4.1 책임을 하나씩 관리하기

**Before:**
```typescript
// 페이지 전체의 모든 쿼리 파라미터를 한 번에 관리
export function usePageState() {
  const [query, setQuery] = useQueryParams({
    cardId: NumberParam,
    statementId: NumberParam,
    dateFrom: DateParam,
    dateTo: DateParam,
    statusList: ArrayParam
  });

  return useMemo(() => ({
    values: { /* 5개의 상태 */ },
    controls: { /* 5개의 setter */ }
  }), [query, setQuery]);
}
```

**문제**: 광범위한 책임, 수정 시 영향 범위 확대

**After:**
```typescript
// 각 파라미터별로 분리
export function useCardIdQueryParam() {
  const [cardId, _setCardId] = useQueryParam("cardId", NumberParam);

  const setCardId = useCallback((cardId: number) => {
    _setCardId({ cardId }, "replaceIn");
  }, []);

  return [cardId ?? undefined, setCardId] as const;
}

// useStatementIdQueryParam, useDateRangeQueryParam 등 별도 훅으로 분리
```

---

### 4.2 Props Drilling 제거하기

**Before:**
```tsx
function ItemEditModal({ open, items, recommendedItems, onConfirm, onClose }) {
  const [keyword, setKeyword] = useState("");

  return (
    <Modal open={open} onClose={onClose}>
      <ItemEditBody
        items={items}
        keyword={keyword}
        onKeywordChange={setKeyword}
        recommendedItems={recommendedItems}
        onConfirm={onConfirm}
        onClose={onClose}
      />
    </Modal>
  );
}
```

**해결책 A: Composition 패턴**
```tsx
function ItemEditModal({ open, items, recommendedItems, onConfirm, onClose }) {
  const [keyword, setKeyword] = useState("");

  return (
    <Modal open={open} onClose={onClose}>
      <ItemEditBody keyword={keyword} onKeywordChange={setKeyword} onClose={onClose}>
        <ItemEditList
          keyword={keyword}
          items={items}
          recommendedItems={recommendedItems}
          onConfirm={onConfirm}
        />
      </ItemEditBody>
    </Modal>
  );
}

function ItemEditBody({ children, keyword, onKeywordChange, onClose }) {
  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Input value={keyword} onChange={(e) => onKeywordChange(e.target.value)} />
        <Button onClick={onClose}>닫기</Button>
      </div>
      {children}
    </>
  );
}
```

**해결책 B: Context API** (더 깊은 트리에서)
```tsx
function ItemEditModal({ open, onConfirm, onClose }) {
  const [keyword, setKeyword] = useState("");

  return (
    <ItemEditModalProvider items={...} recommendedItems={...}>
      <Modal open={open} onClose={onClose}>
        <ItemEditBody keyword={keyword} onKeywordChange={setKeyword} onClose={onClose}>
          <ItemEditList keyword={keyword} onConfirm={onConfirm} />
        </ItemEditBody>
      </Modal>
    </ItemEditModalProvider>
  );
}

function ItemEditList({ keyword, onConfirm }) {
  const { items, recommendedItems } = useItemEditModalContext();
  // ...
}
```

**우선순위**: Composition 먼저 시도 → Context는 최후의 방법

---

### 4.3 중복 코드 허용하기

> "잘못된 추상화보다 중복이 낫다" — Sandi Metz

```typescript
// Bad: 억지 추상화
function processEntity(entity: User | Product | Order) {
  if (entity.type === 'user') { /* ... */ }
  else if (entity.type === 'product') { /* ... */ }
  else { /* ... */ }
}

// Good: 명확한 분리 (중복 허용)
function processUser(user: User) { /* ... */ }
function processProduct(product: Product) { /* ... */ }
function processOrder(order: Order) { /* ... */ }
```

---

## 적용 체크리스트

### 가독성 체크
- [ ] 동시에 실행되지 않는 코드가 분리되어 있는가?
- [ ] 복잡한 조건에 의미 있는 이름이 붙어있는가?
- [ ] 코드가 위에서 아래로 자연스럽게 읽히는가?

### 예측 가능성 체크
- [ ] 함수/변수 이름이 다른 것과 겹치지 않는가?
- [ ] 같은 종류의 함수는 반환 타입이 통일되어 있는가?
- [ ] 숨은 부작용(로깅, 상태 변경 등) 없이 명시적인가?

### 응집도 체크
- [ ] 함께 수정되어야 할 코드가 한 곳에 모여있는가?
- [ ] 매직 넘버가 상수로 추출되어 있는가?
- [ ] 관련 파일이 같은 디렉토리에 있는가?

### 결합도 체크
- [ ] 각 모듈/훅의 책임이 명확히 분리되어 있는가?
- [ ] Props Drilling이 발생하지 않는가?
- [ ] 불필요한 추상화로 결합도가 높아지지 않았는가?

---

## 기준 간 충돌 시 우선순위

1. **버그 위험** → 응집도 우선 (함께 수정되어야 할 코드가 분리되면 버그)
2. **팀 협업** → 예측 가능성 우선 (다른 개발자가 이해하기 쉽게)
3. **빠른 개발** → 가독성 우선 (코드 파악 시간 단축)
4. **유지보수** → 결합도 우선 (수정 영향 범위 최소화)

---

## 참고
- GitHub: https://github.com/toss/frontend-fundamentals
- 토스 프론트엔드 챕터에서 제작
