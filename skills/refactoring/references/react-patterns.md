# React 리팩토링 패턴

> React 19 + TypeScript + Vite 스택 기반
> shadcn/ui, react-hook-form, zod, Tailwind v4 패턴 포함

## 컴포넌트 리팩토링

### 1. God Component 분해

**Smell:** 300줄 이상, 10+ useState, 5+ useEffect

**Before:**
```typescript
function UserDashboard() {
  // 10개의 상태
  const [user, setUser] = useState(null);
  const [orders, setOrders] = useState([]);
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('orders');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState('date');
  const [filterStatus, setFilterStatus] = useState('all');
  const [page, setPage] = useState(1);
  
  // 5개의 useEffect
  useEffect(() => { /* fetch user */ }, []);
  useEffect(() => { /* fetch orders */ }, [user, page, sortBy]);
  useEffect(() => { /* fetch notifications */ }, []);
  useEffect(() => { /* WebSocket connection */ }, []);
  useEffect(() => { /* Analytics */ }, [activeTab]);
  
  // 200줄의 렌더링 로직
  return (
    <div>
      {/* 탭 네비게이션 */}
      {/* 검색 및 필터 */}
      {/* 주문 목록 */}
      {/* 알림 목록 */}
      {/* 페이지네이션 */}
    </div>
  );
}
```

**After: Custom Hooks + 컴포넌트 분리**
```typescript
// hooks/useUser.ts
function useUser() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchUser().then(setUser).finally(() => setLoading(false));
  }, []);
  
  return { user, loading };
}

// hooks/useOrders.ts
function useOrders(userId: string, options: OrderOptions) {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    if (!userId) return;
    fetchOrders(userId, options)
      .then(setOrders)
      .finally(() => setLoading(false));
  }, [userId, options.page, options.sortBy]);
  
  return { orders, loading };
}

// hooks/useNotifications.ts
function useNotifications() { /* ... */ }

// components/UserDashboard.tsx
function UserDashboard() {
  const { user, loading: userLoading } = useUser();
  const [activeTab, setActiveTab] = useState<Tab>('orders');
  
  if (userLoading) return <DashboardSkeleton />;
  if (!user) return <NotFound />;
  
  return (
    <div className="space-y-6">
      <UserHeader user={user} />
      <TabNavigation active={activeTab} onChange={setActiveTab} />
      <TabContent tab={activeTab} userId={user.id} />
    </div>
  );
}

// components/TabContent.tsx
function TabContent({ tab, userId }: TabContentProps) {
  switch (tab) {
    case 'orders':
      return <OrdersTab userId={userId} />;
    case 'notifications':
      return <NotificationsTab userId={userId} />;
    default:
      return null;
  }
}

// components/OrdersTab.tsx
function OrdersTab({ userId }: { userId: string }) {
  const [options, setOptions] = useState<OrderOptions>(defaultOptions);
  const { orders, loading } = useOrders(userId, options);
  
  return (
    <div>
      <OrderFilters options={options} onChange={setOptions} />
      <OrderList orders={orders} loading={loading} />
      <Pagination
        page={options.page}
        onChange={page => setOptions(prev => ({ ...prev, page }))}
      />
    </div>
  );
}
```

---

### 2. Prop Drilling 해결

**Smell:** props가 3단계 이상 전달

**Before:**
```typescript
<App user={user} theme={theme} locale={locale}>
  <Layout user={user} theme={theme}>
    <Header user={user} />
    <Main theme={theme}>
      <Sidebar user={user} theme={theme}>
        <UserInfo user={user} />  // 여기서만 사용
      </Sidebar>
      <Content theme={theme} locale={locale}>
        <Article locale={locale}>
          <ArticleBody locale={locale} />  // 여기서만 사용
        </Article>
      </Content>
    </Main>
  </Layout>
</App>
```

**Solution 1: Context (전역적 데이터)**
```typescript
// contexts/UserContext.tsx
const UserContext = createContext<User | null>(null);

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  
  useEffect(() => {
    fetchCurrentUser().then(setUser);
  }, []);
  
  return (
    <UserContext.Provider value={user}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const user = useContext(UserContext);
  if (user === undefined) {
    throw new Error('useUser must be within UserProvider');
  }
  return user;
}

// 사용
function UserInfo() {
  const user = useUser();  // 직접 접근
  return <div>{user?.name}</div>;
}
```

**Solution 2: Composition (구조적 해결)**
```typescript
// Before: props 전달
<Sidebar user={user}>
  <UserInfo user={user} />
</Sidebar>

// After: children으로 전달
function App() {
  const user = useUser();
  
  return (
    <Layout>
      <Sidebar>
        <UserInfo user={user} />  {/* 여기서 직접 주입 */}
      </Sidebar>
      <Content>
        <Article />
      </Content>
    </Layout>
  );
}

// Sidebar는 user를 몰라도 됨
function Sidebar({ children }: { children: ReactNode }) {
  return <aside className="w-64">{children}</aside>;
}
```

---

### 3. Conditional Rendering 정리

**Smell:** 복잡한 조건부 렌더링, 중첩된 삼항 연산자

**Before:**
```typescript
function UserProfile({ userId }: Props) {
  const { user, loading, error } = useUser(userId);
  
  return (
    <div>
      {loading ? (
        <Spinner />
      ) : error ? (
        <ErrorMessage error={error} />
      ) : user ? (
        user.isAdmin ? (
          <AdminProfile user={user} />
        ) : user.isPremium ? (
          <PremiumProfile user={user} />
        ) : (
          <BasicProfile user={user} />
        )
      ) : (
        <NotFound />
      )}
    </div>
  );
}
```

**After: Early Return + 컴포넌트 분리**
```typescript
function UserProfile({ userId }: Props) {
  const { user, loading, error } = useUser(userId);
  
  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;
  
  return <ProfileView user={user} />;
}

// 프로필 타입별 분기는 별도 컴포넌트
function ProfileView({ user }: { user: User }) {
  const ProfileComponent = getProfileComponent(user);
  return <ProfileComponent user={user} />;
}

function getProfileComponent(user: User) {
  if (user.isAdmin) return AdminProfile;
  if (user.isPremium) return PremiumProfile;
  return BasicProfile;
}
```

---

### 4. 반복되는 Form 패턴

**Smell:** 폼마다 동일한 보일러플레이트

**Before:**
```typescript
// LoginForm.tsx - 50줄
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const validate = () => {
    const newErrors = {};
    if (!email) newErrors.email = '이메일 필수';
    if (!email.includes('@')) newErrors.email = '유효하지 않은 이메일';
    if (!password) newErrors.password = '비밀번호 필수';
    if (password.length < 8) newErrors.password = '8자 이상';
    return newErrors;
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    const newErrors = validate();
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setIsSubmitting(true);
    try {
      await login({ email, password });
    } finally {
      setIsSubmitting(false);
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      {errors.email && <span>{errors.email}</span>}
      {/* ... */}
    </form>
  );
}
```

**After: react-hook-form + zod**
```typescript
// schemas/auth.ts
import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('유효하지 않은 이메일'),
  password: z.string().min(8, '8자 이상 입력하세요'),
});

export type LoginFormData = z.infer<typeof loginSchema>;

// components/LoginForm.tsx - 깔끔한 20줄
function LoginForm({ onSubmit }: { onSubmit: (data: LoginFormData) => Promise<void> }) {
  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });
  
  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
      <FormField
        control={form.control}
        name="email"
        render={({ field }) => (
          <FormItem>
            <FormLabel>이메일</FormLabel>
            <FormControl>
              <Input type="email" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="password"
        render={({ field }) => (
          <FormItem>
            <FormLabel>비밀번호</FormLabel>
            <FormControl>
              <Input type="password" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <Button type="submit" disabled={form.formState.isSubmitting}>
        {form.formState.isSubmitting ? '로그인 중...' : '로그인'}
      </Button>
    </form>
  );
}
```

---

## Hook 리팩토링

### 1. useEffect 정리

**Smell:** 하나의 useEffect에 여러 관심사

**Before:**
```typescript
useEffect(() => {
  // 1. 데이터 fetching
  fetchUser(id).then(setUser);
  
  // 2. 페이지 뷰 추적
  analytics.trackPageView('user-profile');
  
  // 3. WebSocket 연결
  const ws = new WebSocket(WS_URL);
  ws.onmessage = handleMessage;
  
  // 4. 타이틀 변경
  document.title = `User ${id}`;
  
  return () => ws.close();
}, [id]);
```

**After: 관심사별 분리**
```typescript
// 1. 데이터 fetching
const { user } = useUser(id);

// 2. 페이지 뷰 추적
useEffect(() => {
  analytics.trackPageView('user-profile');
}, []);

// 3. WebSocket - Custom Hook
const { messages } = useUserWebSocket(id);

// 4. 타이틀 - Custom Hook
useDocumentTitle(`User ${id}`);
```

**Custom Hooks:**
```typescript
// hooks/useDocumentTitle.ts
function useDocumentTitle(title: string) {
  useEffect(() => {
    const prevTitle = document.title;
    document.title = title;
    return () => { document.title = prevTitle; };
  }, [title]);
}

// hooks/useUserWebSocket.ts
function useUserWebSocket(userId: string) {
  const [messages, setMessages] = useState<Message[]>([]);
  
  useEffect(() => {
    const ws = new WebSocket(`${WS_URL}?userId=${userId}`);
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      setMessages(prev => [...prev, message]);
    };
    
    return () => ws.close();
  }, [userId]);
  
  return { messages };
}
```

---

### 2. 중복 데이터 Fetching Hook

**Smell:** 여러 컴포넌트에서 동일한 fetch 로직

**Before:**
```typescript
// UserProfile.tsx
function UserProfile({ id }) {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch(`/api/users/${id}`).then(r => r.json()).then(setUser);
  }, [id]);
}

// UserSettings.tsx
function UserSettings({ id }) {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch(`/api/users/${id}`).then(r => r.json()).then(setUser);
  }, [id]);
}

// UserOrders.tsx - 같은 패턴 반복...
```

**After: 재사용 가능한 Hook**
```typescript
// hooks/useUser.ts
interface UseUserOptions {
  enabled?: boolean;
}

function useUser(id: string | undefined, options: UseUserOptions = {}) {
  const { enabled = true } = options;
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    if (!id || !enabled) return;
    
    let cancelled = false;
    setIsLoading(true);
    
    fetchUser(id)
      .then(data => {
        if (!cancelled) setUser(data);
      })
      .catch(err => {
        if (!cancelled) setError(err);
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    
    return () => { cancelled = true; };
  }, [id, enabled]);
  
  return { user, isLoading, error };
}

// 사용
function UserProfile({ id }) {
  const { user, isLoading } = useUser(id);
  // ...
}
```

**고급: Generic Fetch Hook**
```typescript
// hooks/useFetch.ts
interface UseFetchResult<T> {
  data: T | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}

function useFetch<T>(
  fetcher: () => Promise<T>,
  deps: unknown[]
): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  const fetch = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await fetcher();
      setData(result);
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Unknown error'));
    } finally {
      setIsLoading(false);
    }
  }, deps);
  
  useEffect(() => {
    fetch();
  }, [fetch]);
  
  return { data, isLoading, error, refetch: fetch };
}

// 사용
const { data: user } = useFetch(() => fetchUser(id), [id]);
const { data: orders } = useFetch(() => fetchOrders(userId), [userId]);
```

---

## 타입 리팩토링

### 1. any 제거

**Smell:** any 타입 사용

**Before:**
```typescript
function processData(data: any) {
  return data.items.map((item: any) => ({
    id: item.id,
    name: item.name,
  }));
}

const [response, setResponse] = useState<any>(null);
```

**After: 명시적 타입**
```typescript
interface DataResponse {
  items: Array<{
    id: string;
    name: string;
    // 알려지지 않은 추가 필드도 있을 수 있음
  }>;
}

interface ProcessedItem {
  id: string;
  name: string;
}

function processData(data: DataResponse): ProcessedItem[] {
  return data.items.map(item => ({
    id: item.id,
    name: item.name,
  }));
}

// unknown은 any보다 안전
const [response, setResponse] = useState<DataResponse | null>(null);
```

---

### 2. Union Type 활용

**Smell:** string 타입으로 상태 관리

**Before:**
```typescript
const [status, setStatus] = useState<string>('idle');
// 'idle', 'loading', 'success', 'error', '오타가능'

if (status === 'laoding') { }  // 오타 감지 안됨
```

**After: Union Type**
```typescript
type Status = 'idle' | 'loading' | 'success' | 'error';

const [status, setStatus] = useState<Status>('idle');

if (status === 'laoding') { }  // TS 에러!
```

**Discriminated Union (API 응답):**
```typescript
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function UserProfile() {
  const [state, setState] = useState<AsyncState<User>>({ status: 'idle' });
  
  // 타입 가드 자동 적용
  if (state.status === 'success') {
    return <div>{state.data.name}</div>;  // state.data 타입 안전
  }
  
  if (state.status === 'error') {
    return <div>{state.error.message}</div>;  // state.error 타입 안전
  }
}
```

---

### 3. Props 타입 개선

**Before:**
```typescript
interface ButtonProps {
  variant?: string;
  size?: string;
  disabled?: boolean;
  onClick?: Function;
  children: any;
}
```

**After:**
```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  children: React.ReactNode;
}

// CVA로 변형 관리 (shadcn 패턴)
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium',
  {
    variants: {
      variant: {
        primary: 'bg-primary text-primary-foreground',
        secondary: 'bg-secondary text-secondary-foreground',
        outline: 'border border-input',
        ghost: 'hover:bg-accent',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4',
        lg: 'h-12 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}
```

---

## 성능 리팩토링

### 1. 불필요한 리렌더링 방지

**Smell:** 부모 렌더링 시 모든 자식 리렌더링

**Before:**
```typescript
function ParentComponent() {
  const [count, setCount] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  
  return (
    <div>
      <Counter count={count} onIncrement={() => setCount(c => c + 1)} />
      <ItemList items={items} />  {/* count 변경 시에도 리렌더링 */}
    </div>
  );
}
```

**After: memo + useCallback**
```typescript
function ParentComponent() {
  const [count, setCount] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  
  const handleIncrement = useCallback(() => {
    setCount(c => c + 1);
  }, []);
  
  return (
    <div>
      <Counter count={count} onIncrement={handleIncrement} />
      <MemoizedItemList items={items} />
    </div>
  );
}

const MemoizedItemList = memo(ItemList);
```

---

### 2. 비용이 큰 계산 최적화

**Smell:** 매 렌더링마다 비싼 계산 수행

**Before:**
```typescript
function ProductList({ products, filters }) {
  // 매 렌더링마다 실행
  const filtered = products
    .filter(p => p.category === filters.category)
    .filter(p => p.price >= filters.minPrice)
    .sort((a, b) => a.price - b.price);
  
  return <List items={filtered} />;
}
```

**After: useMemo**
```typescript
function ProductList({ products, filters }) {
  const filtered = useMemo(() => {
    return products
      .filter(p => p.category === filters.category)
      .filter(p => p.price >= filters.minPrice)
      .sort((a, b) => a.price - b.price);
  }, [products, filters.category, filters.minPrice]);
  
  return <List items={filtered} />;
}
```

---

## FSD 마이그레이션 가이드

### 기존 구조 → FSD

**Before (일반적인 구조):**
```
src/
├── components/
│   ├── Button.tsx
│   ├── UserCard.tsx
│   └── OrderList.tsx
├── hooks/
│   └── useUser.ts
├── pages/
│   ├── Home.tsx
│   └── Profile.tsx
├── services/
│   └── api.ts
└── utils/
    └── format.ts
```

**After (FSD):**
```
src/
├── app/                    # 앱 초기화, 라우터, 프로바이더
│   ├── providers/
│   ├── routes/
│   └── App.tsx
├── pages/                  # 페이지 컴포넌트
│   ├── home/
│   │   ├── ui/
│   │   └── index.ts
│   └── profile/
│       ├── ui/
│       └── index.ts
├── widgets/                # 독립적인 큰 UI 블록
│   └── user-card/
│       ├── ui/
│       └── index.ts
├── features/               # 사용자 기능 (로그인, 좋아요 등)
│   └── auth/
│       ├── ui/
│       ├── model/
│       ├── api/
│       └── index.ts
├── entities/               # 비즈니스 엔티티 (User, Order 등)
│   ├── user/
│   │   ├── ui/
│   │   ├── model/
│   │   ├── api/
│   │   └── index.ts
│   └── order/
└── shared/                 # 공유 유틸리티
    ├── ui/                 # 기본 UI 컴포넌트
    ├── lib/                # 유틸리티 함수
    ├── api/                # API 클라이언트
    └── config/
```

**마이그레이션 단계:**
1. shared/ 먼저 구성 (Button, Input 등 기본 UI)
2. entities/ 도메인 엔티티 분리
3. features/ 기능별 분리
4. widgets/ 큰 UI 블록 분리
5. pages/ 페이지 재구성
6. app/ 초기화 로직 정리

---

## 체크리스트

### 컴포넌트 리팩토링 체크
- [ ] 300줄 이하인가?
- [ ] useState 5개 이하인가?
- [ ] useEffect 3개 이하인가?
- [ ] props 5개 이하인가?
- [ ] 단일 책임을 가지는가?

### Hook 리팩토링 체크
- [ ] 반환값 3개 이하인가?
- [ ] 하나의 관심사만 다루는가?
- [ ] 테스트 가능한가?

### 타입 리팩토링 체크
- [ ] any 타입 없는가?
- [ ] Union Type 활용했는가?
- [ ] Props 타입 명확한가?
