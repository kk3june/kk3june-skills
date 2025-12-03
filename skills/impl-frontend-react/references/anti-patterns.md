# Anti-Patterns - 피해야 할 것

> 프로젝트 패턴이 있어도 아래에 해당하면 BP 권장
> 출처: Frontend Fundamentals, Bulletproof React

---

## 1. Props Drilling (3단계 이상)

### 문제
```tsx
// Parent → Child → GrandChild → GreatGrandChild로 props 전달
function App() {
  const [user, setUser] = useState(null);
  return <Parent user={user} setUser={setUser} />;
}

function Parent({ user, setUser }) {
  return <Child user={user} setUser={setUser} />;
}

function Child({ user, setUser }) {
  return <GrandChild user={user} setUser={setUser} />;
}
```

### 해결책
```tsx
// Option 1: Composition
function App() {
  const [user, setUser] = useState(null);
  return (
    <Parent>
      <Child>
        <GrandChild user={user} setUser={setUser} />
      </Child>
    </Parent>
  );
}

// Option 2: Context
const UserContext = createContext(null);

function App() {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Parent />
    </UserContext.Provider>
  );
}
```

---

## 2. useEffect 남용

### 문제: 파생 상태를 useEffect로 계산
```tsx
// Bad
function FilteredList({ items, filter }) {
  const [filteredItems, setFilteredItems] = useState([]);

  useEffect(() => {
    setFilteredItems(items.filter(item => item.type === filter));
  }, [items, filter]);

  return <List items={filteredItems} />;
}
```

### 해결책
```tsx
// Good: 렌더링 중 계산
function FilteredList({ items, filter }) {
  const filteredItems = items.filter(item => item.type === filter);
  return <List items={filteredItems} />;
}

// 비용이 크면 useMemo
function FilteredList({ items, filter }) {
  const filteredItems = useMemo(
    () => items.filter(item => item.type === filter),
    [items, filter]
  );
  return <List items={filteredItems} />;
}
```

### 문제: props 변경을 useEffect로 동기화
```tsx
// Bad
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    setUser(null); // props 변경 시 리셋
  }, [userId]);
}
```

### 해결책
```tsx
// Good: key로 컴포넌트 리셋
<UserProfile key={userId} userId={userId} />
```

---

## 3. 과도한 추상화

### 문제: 억지 DRY
```tsx
// Bad: 다른 용도인데 억지로 합침
function EntityCard({ entity, type }) {
  if (type === 'user') {
    return <div>{entity.name} - {entity.email}</div>;
  } else if (type === 'product') {
    return <div>{entity.title} - ${entity.price}</div>;
  } else if (type === 'order') {
    return <div>Order #{entity.id}</div>;
  }
}
```

### 해결책
```tsx
// Good: 분리 (중복 허용)
function UserCard({ user }) {
  return <div>{user.name} - {user.email}</div>;
}

function ProductCard({ product }) {
  return <div>{product.title} - ${product.price}</div>;
}

function OrderCard({ order }) {
  return <div>Order #{order.id}</div>;
}
```

> "잘못된 추상화보다 중복이 낫다" — Sandi Metz

---

## 4. God Component

### 문제: 하나의 컴포넌트가 모든 것을 처리
```tsx
// Bad: 500줄짜리 컴포넌트
function Dashboard() {
  const [users, setUsers] = useState([]);
  const [posts, setPosts] = useState([]);
  const [comments, setComments] = useState([]);
  const [isUserModalOpen, setIsUserModalOpen] = useState(false);
  const [isPostModalOpen, setIsPostModalOpen] = useState(false);
  // ... 수백 줄의 로직과 렌더링
}
```

### 해결책
```tsx
// Good: 책임별 분리
function Dashboard() {
  return (
    <DashboardLayout>
      <UserSection />
      <PostSection />
      <CommentSection />
    </DashboardLayout>
  );
}
```

---

## 5. 동시에 실행되지 않는 코드 혼합

### 문제
```tsx
function SubmitButton() {
  const isViewer = useRole() === 'viewer';

  useEffect(() => {
    if (isViewer) return;
    showAnimation();
  }, [isViewer]);

  return isViewer ? (
    <TextButton disabled>Submit</TextButton>
  ) : (
    <Button type="submit">Submit</Button>
  );
}
```

### 해결책
```tsx
function SubmitButton() {
  const isViewer = useRole() === 'viewer';
  return isViewer ? <ViewerButton /> : <AdminButton />;
}

function ViewerButton() {
  return <TextButton disabled>Submit</TextButton>;
}

function AdminButton() {
  useEffect(() => { showAnimation(); }, []);
  return <Button type="submit">Submit</Button>;
}
```

---

## 6. 숨은 로직

### 문제: 함수명과 실제 동작 불일치
```tsx
// Bad: fetchUser인데 로깅도 함
async function fetchUser(id: string) {
  const user = await api.get(`/users/${id}`);
  analytics.log('user_fetched', { id }); // 숨겨진 부작용
  return user;
}
```

### 해결책
```tsx
// Good: 함수는 이름대로만
async function fetchUser(id: string) {
  return api.get(`/users/${id}`);
}

// 호출부에서 명시적으로
const user = await fetchUser(id);
analytics.log('user_fetched', { id });
```

---

## 7. 매직 넘버/스트링

### 문제
```tsx
// Bad
await delay(300); // 300이 뭐지?

if (status === 'P') { ... } // P가 뭐지?

if (items.length > 10) { ... } // 왜 10?
```

### 해결책
```tsx
// Good
const ANIMATION_DELAY_MS = 300;
await delay(ANIMATION_DELAY_MS);

const STATUS = {
  PENDING: 'P',
  COMPLETED: 'C',
} as const;
if (status === STATUS.PENDING) { ... }

const MAX_VISIBLE_ITEMS = 10;
if (items.length > MAX_VISIBLE_ITEMS) { ... }
```

---

## 8. 이름 겹침

### 문제
```tsx
// Bad: 라이브러리와 같은 이름인데 다른 동작
import { http } from './http'; // 커스텀 래퍼

export const http = {
  get: (url) => {
    // 인증 헤더 자동 추가 (숨겨진 동작)
    return originalHttp.get(url, { headers: authHeader });
  }
};
```

### 해결책
```tsx
// Good: 다른 이름으로 구분
export const httpService = {
  getWithAuth: (url) => {
    return http.get(url, { headers: authHeader });
  }
};
```

---

## 체크리스트

코드 리뷰 시 확인:

- [ ] Props가 3단계 이상 전달되지 않는가?
- [ ] useEffect가 파생 상태 계산에 사용되지 않는가?
- [ ] 컴포넌트가 200줄을 넘지 않는가?
- [ ] 함수명과 실제 동작이 일치하는가?
- [ ] 매직 넘버가 상수로 추출되어 있는가?
- [ ] 불필요한 추상화가 없는가?
