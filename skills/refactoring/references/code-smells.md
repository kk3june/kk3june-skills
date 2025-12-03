# Code Smells 카탈로그

> Martin Fowler의 Refactoring 2판 + Clean Code 기반
> React + TypeScript 프로젝트에 맞게 정리

## Smell 탐지 체크리스트

### 빠른 스캔 (1분)

```
□ 파일이 300줄 이상인가?
□ 함수가 30줄 이상인가?
□ 들여쓰기가 3단계 이상인가?
□ 주석이 "무엇을 하는지" 설명하고 있는가?
□ 같은 코드가 2번 이상 반복되는가?
□ 매개변수가 3개 이상인가?
□ any 타입이 있는가?
```

---

## 1. Bloaters (비대한 코드)

코드가 너무 커져서 다루기 어려운 경우

### 1.1 Long Function (장황한 함수)

**증상:**
- 함수가 30줄 이상
- 스크롤 없이 함수 전체를 볼 수 없음
- 함수 내 주석으로 섹션 구분

**React 예시:**
```typescript
// ❌ Bad: 100줄짜리 컴포넌트
function UserDashboard() {
  // 데이터 fetching
  const [data, setData] = useState(null);
  useEffect(() => {
    // 20줄의 fetch 로직
  }, []);
  
  // 데이터 정규화
  const normalized = useMemo(() => {
    // 30줄의 변환 로직
  }, [data]);
  
  // 필터링
  const filtered = useMemo(() => {
    // 20줄의 필터 로직
  }, [normalized]);
  
  // 렌더링
  return (
    // 30줄의 JSX
  );
}
```

**리팩토링:**
- Extract Function
- Extract Custom Hook
- Extract Component

```typescript
// ✅ Good: 분리된 관심사
function UserDashboard() {
  const { data, isLoading } = useUserData();
  const normalized = useNormalizedData(data);
  const filtered = useFilteredData(normalized);
  
  if (isLoading) return <Loading />;
  return <UserList users={filtered} />;
}
```

---

### 1.2 Long Parameter List (긴 매개변수 목록)

**증상:**
- 함수 매개변수가 3개 이상
- props가 5개 이상
- 연관된 매개변수가 항상 함께 전달됨

**React 예시:**
```typescript
// ❌ Bad
function UserCard({
  firstName,
  lastName,
  email,
  phone,
  street,
  city,
  country,
  postalCode,
  onEdit,
  onDelete,
  onShare,
}: UserCardProps) { ... }
```

**리팩토링:**
- Introduce Parameter Object
- Preserve Whole Object

```typescript
// ✅ Good: 객체로 그룹화
interface User {
  name: { first: string; last: string };
  contact: { email: string; phone: string };
  address: Address;
}

interface UserCardProps {
  user: User;
  actions: UserCardActions;
}

function UserCard({ user, actions }: UserCardProps) { ... }
```

---

### 1.3 Large Class / God Component (신 컴포넌트)

**증상:**
- 컴포넌트가 300줄 이상
- 10개 이상의 useState
- 5개 이상의 useEffect
- 여러 관심사 혼합 (fetching + 로직 + UI)

**리팩토링:**
- Extract Component
- Extract Custom Hook
- Container/Presentational 분리

---

### 1.4 Primitive Obsession (원시값 집착)

**증상:**
- 상태를 string/number로 관리
- 타입 안전성 부족
- 유효하지 않은 상태 가능

**React 예시:**
```typescript
// ❌ Bad
const [status, setStatus] = useState<string>('pending');
// 'pending', 'loading', 'success', 'error', 'typo가능'

// ❌ Bad
const [price, setPrice] = useState<number>(0);
// 음수? 소수점 처리?
```

**리팩토링:**
- Replace Primitive with Object
- Union Type / Enum

```typescript
// ✅ Good
type Status = 'pending' | 'loading' | 'success' | 'error';
const [status, setStatus] = useState<Status>('pending');

// ✅ Good
interface Money {
  amount: number;
  currency: 'KRW' | 'USD';
}
const [price, setPrice] = useState<Money>({ amount: 0, currency: 'KRW' });
```

---

### 1.5 Data Clumps (데이터 뭉치)

**증상:**
- 같은 변수들이 항상 함께 사용됨
- 여러 함수에 동일한 매개변수 그룹 전달

```typescript
// ❌ Bad: 항상 함께 다니는 데이터
function formatAddress(street: string, city: string, country: string) { ... }
function validateAddress(street: string, city: string, country: string) { ... }
function saveAddress(street: string, city: string, country: string) { ... }
```

**리팩토링:**
- Extract Class / Interface

```typescript
// ✅ Good
interface Address {
  street: string;
  city: string;
  country: string;
}

function formatAddress(address: Address) { ... }
function validateAddress(address: Address) { ... }
function saveAddress(address: Address) { ... }
```

---

## 2. Object-Orientation Abusers (객체지향 남용)

### 2.1 Switch Statements (반복되는 조건문)

**증상:**
- 동일한 switch/if-else가 여러 곳에 존재
- 타입에 따라 다른 동작을 여러 곳에서 처리

```typescript
// ❌ Bad: 여러 곳에서 반복
function getIcon(type: string) {
  switch (type) {
    case 'user': return <UserIcon />;
    case 'admin': return <AdminIcon />;
    case 'guest': return <GuestIcon />;
  }
}

function getPermissions(type: string) {
  switch (type) {
    case 'user': return ['read'];
    case 'admin': return ['read', 'write', 'delete'];
    case 'guest': return [];
  }
}
```

**리팩토링:**
- Replace Conditional with Polymorphism
- Strategy Pattern

```typescript
// ✅ Good: 한 곳에서 정의
const USER_TYPES = {
  user: {
    icon: UserIcon,
    permissions: ['read'],
  },
  admin: {
    icon: AdminIcon,
    permissions: ['read', 'write', 'delete'],
  },
  guest: {
    icon: GuestIcon,
    permissions: [],
  },
} as const;

type UserType = keyof typeof USER_TYPES;
```

---

### 2.2 Refused Bequest (거부된 유산)

**증상:**
- 상속받은 메서드를 사용하지 않음
- 부모 컴포넌트의 props를 대부분 무시

**리팩토링:**
- Replace Inheritance with Delegation
- Composition 사용

---

## 3. Change Preventers (변경 방해자)

### 3.1 Divergent Change (발산적 변경)

**증상:**
- 하나의 클래스/컴포넌트가 여러 이유로 변경됨
- "A를 바꾸려면 이 파일, B를 바꾸려면 또 이 파일"

```typescript
// ❌ Bad: 여러 이유로 변경되는 컴포넌트
function UserProfile() {
  // DB 스키마 변경 시 수정
  const { data } = useQuery(...);
  
  // 비즈니스 로직 변경 시 수정
  const displayName = data.firstName + ' ' + data.lastName;
  
  // UI 변경 시 수정
  return <div className="...">{displayName}</div>;
  
  // API 변경 시 수정
  const handleSave = () => api.updateUser(...);
}
```

**리팩토링:**
- Extract Class (관심사별 분리)

---

### 3.2 Shotgun Surgery (산탄총 수술)

**증상:**
- 작은 변경에 여러 파일 수정 필요
- 하나의 개념이 여러 곳에 흩어져 있음

```typescript
// ❌ Bad: 날짜 포맷 변경하려면 10개 파일 수정
// UserCard.tsx
const date = format(user.createdAt, 'yyyy-MM-dd');
// OrderList.tsx
const date = format(order.date, 'yyyy-MM-dd');
// CommentItem.tsx
const date = format(comment.timestamp, 'yyyy-MM-dd');
```

**리팩토링:**
- Move Function (한 곳으로 모으기)

```typescript
// ✅ Good: 한 곳에서 관리
// lib/dateFormat.ts
export const formatDate = (date: Date) => format(date, 'yyyy-MM-dd');
export const formatDateTime = (date: Date) => format(date, 'yyyy-MM-dd HH:mm');
```

---

## 4. Dispensables (불필요한 것들)

### 4.1 Comments (주석)

**증상:**
- 코드가 하는 일을 설명하는 주석
- 주석 없이는 이해 불가능한 코드

```typescript
// ❌ Bad: 주석이 필요한 코드
// 사용자가 프리미엄이고 3개월 이상 가입했으면 할인 적용
if (user.type === 'premium' && daysSince(user.joinedAt) > 90) {
  price = price * 0.8;
}
```

**리팩토링:**
- Extract Function (의도를 이름으로)
- Introduce Explaining Variable

```typescript
// ✅ Good: 코드가 스스로 설명
const isLoyalPremiumUser = user.isPremium && user.membershipDays > 90;
const LOYALTY_DISCOUNT = 0.8;

if (isLoyalPremiumUser) {
  price = price * LOYALTY_DISCOUNT;
}
```

**좋은 주석:**
- WHY (왜 이렇게 했는지)
- TODO/FIXME
- 복잡한 알고리즘 설명
- 외부 API 제약사항

---

### 4.2 Duplicate Code (중복 코드)

**증상:**
- 동일/유사한 코드가 2번 이상 존재
- Copy-Paste 프로그래밍

**리팩토링:**
- Extract Function
- Extract Component
- Pull Up Method (공통 부모로)

---

### 4.3 Dead Code (죽은 코드)

**증상:**
- 사용되지 않는 변수/함수/컴포넌트
- 도달 불가능한 코드
- 주석 처리된 오래된 코드

```typescript
// ❌ Bad
function UserCard() {
  const unusedVariable = 'never used';
  
  // const oldImplementation = () => { ... }
  
  if (false) {
    // 절대 실행되지 않는 코드
  }
}
```

**리팩토링:**
- 삭제 (Git에 히스토리 있음)

---

### 4.4 Speculative Generality (추측성 일반화)

**증상:**
- "언젠가 필요할 것 같아서" 만든 추상화
- 사용되지 않는 매개변수/인터페이스
- 단 한 곳에서만 사용되는 추상 클래스

```typescript
// ❌ Bad: 과도한 추상화
interface GenericDataProcessor<T, R, E> {
  process(data: T): R;
  handleError(error: E): void;
  // ... 실제로는 하나의 타입만 사용
}
```

**리팩토링:**
- Collapse Hierarchy
- Inline Function/Class
- Remove Dead Code

---

## 5. Couplers (결합도 문제)

### 5.1 Feature Envy (기능 욕심)

**증상:**
- 다른 객체의 데이터를 과도하게 사용
- 자신의 데이터보다 다른 객체 데이터 더 많이 접근

```typescript
// ❌ Bad: user 객체에 대한 Feature Envy
function calculateShipping(order: Order) {
  const user = order.user;
  const address = user.address;
  const country = address.country;
  const city = address.city;
  const postalCode = address.postalCode;
  
  // user.address에 대한 로직이 여기에...
  if (country === 'KR' && city === 'Seoul') {
    return postalCode.startsWith('0') ? 3000 : 5000;
  }
}
```

**리팩토링:**
- Move Function (데이터가 있는 곳으로)

```typescript
// ✅ Good: Address에서 계산
interface Address {
  country: string;
  city: string;
  postalCode: string;
  calculateShippingCost(): number;
}
```

---

### 5.2 Inappropriate Intimacy (부적절한 친밀)

**증상:**
- 두 클래스가 서로의 private 멤버에 과도하게 접근
- 양방향 의존성

**리팩토링:**
- Move Function
- Extract Class (중개자)
- Hide Delegate

---

### 5.3 Message Chains (메시지 체인)

**증상:**
- `a.b().c().d().e()` 형태의 긴 체인
- 중간 객체 변경 시 전체 체인 영향

```typescript
// ❌ Bad
const managerName = order.customer.company.manager.name;
```

**리팩토링:**
- Hide Delegate
- Extract Function

```typescript
// ✅ Good
const managerName = order.getManagerName();
// 또는
const managerName = getOrderManagerName(order);
```

---

### 5.4 Middle Man (중개자)

**증상:**
- 클래스가 대부분의 작업을 다른 클래스에 위임
- 단순 pass-through 함수만 존재

```typescript
// ❌ Bad: 그냥 전달만 하는 컴포넌트
function UserSection({ userId }: { userId: string }) {
  return <UserProfile userId={userId} />;
}
```

**리팩토링:**
- Remove Middle Man
- Inline Function

---

## React 특화 Smells

### R1. Prop Drilling

**증상:**
- props가 여러 단계를 거쳐 전달
- 중간 컴포넌트가 사용하지 않는 props 전달

```typescript
// ❌ Bad
<App user={user}>
  <Layout user={user}>
    <Sidebar user={user}>
      <UserInfo user={user} />  // 실제 사용
```

**리팩토링:**
- Context API
- Composition (children)
- State Management Library

---

### R2. God Hook

**증상:**
- 하나의 custom hook이 너무 많은 일을 함
- 반환 값이 5개 이상

```typescript
// ❌ Bad
const {
  user, setUser,
  orders, setOrders,
  loading, error,
  fetchUser, updateUser,
  fetchOrders, createOrder,
  // ...
} = useUserDashboard();
```

**리팩토링:**
- 관심사별 hook 분리

```typescript
// ✅ Good
const { user, isLoading: userLoading } = useUser(id);
const { orders, isLoading: ordersLoading } = useUserOrders(id);
const { updateUser } = useUpdateUser();
```

---

### R3. Inline Handler Chaos

**증상:**
- JSX 내 복잡한 인라인 핸들러
- 렌더링마다 새 함수 생성

```typescript
// ❌ Bad
<button onClick={() => {
  setLoading(true);
  api.save(data).then(() => {
    setLoading(false);
    toast.success('저장됨');
    router.push('/');
  }).catch(err => {
    setLoading(false);
    toast.error(err.message);
  });
}}>
```

**리팩토링:**
- Extract Function
- useCallback

```typescript
// ✅ Good
const handleSave = useCallback(async () => {
  await saveData();
}, [saveData]);

<button onClick={handleSave}>
```

---

### R4. useEffect Soup

**증상:**
- 하나의 useEffect에 여러 관심사
- 의존성 배열 관리 어려움

```typescript
// ❌ Bad
useEffect(() => {
  fetchUser(id);
  trackPageView();
  subscribeToUpdates(id);
  return () => unsubscribe();
}, [id]);
```

**리팩토링:**
- useEffect 분리
- Custom Hook 추출

```typescript
// ✅ Good
useEffect(() => { fetchUser(id); }, [id]);
useEffect(() => { trackPageView(); }, []);
useSubscription(id);
```

---

## Smell 심각도 가이드

| 심각도 | 설명 | 조치 |
|--------|------|------|
| 🔴 Critical | 버그 원인, 유지보수 불가 | 즉시 리팩토링 |
| 🟠 High | 확장성 저하, 테스트 어려움 | 다음 스프린트 내 |
| 🟡 Medium | 가독성 저하, 중복 | 기능 작업 시 함께 |
| 🟢 Low | 컨벤션 위반, 경미한 문제 | 여유 있을 때 |

---

## 자동 탐지 도구

```bash
# ESLint로 탐지 가능한 Smells
npm run lint

# 복잡도 분석
npx complexity-report src/

# 중복 코드 탐지
npx jscpd src/

# 의존성 분석
npx madge --circular src/
```
