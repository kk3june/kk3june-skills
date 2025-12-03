# React 19 Best Practices

> 공식 문서: https://react.dev
> 버전: React 19 (2024)

---

## 컴포넌트 선언

### 권장 패턴

```typescript
// 함수 선언식 (권장)
function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div onClick={() => onSelect(user.id)}>
      {user.name}
    </div>
  );
}

// Props 타입은 interface로
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
}
```

### children 처리

```typescript
interface ContainerProps {
  children: React.ReactNode;  // 가장 범용적
  title?: string;
}

function Container({ children, title }: ContainerProps) {
  return (
    <section>
      {title && <h2>{title}</h2>}
      {children}
    </section>
  );
}
```

---

## 훅 사용법

### useState

```typescript
// 타입 추론 활용
const [count, setCount] = useState(0);

// 복잡한 타입은 명시
const [user, setUser] = useState<User | null>(null);

// 함수형 업데이트 (이전 상태 기반)
setCount(prev => prev + 1);
```

### useEffect

```typescript
// 의존성 배열 명확히
useEffect(() => {
  const subscription = subscribe(id);
  return () => subscription.unsubscribe();
}, [id]);  // id 변경 시에만 재실행

// 빈 배열 = 마운트/언마운트
useEffect(() => {
  console.log('mounted');
  return () => console.log('unmounted');
}, []);
```

### useCallback / useMemo

```typescript
// useCallback: 함수 메모이제이션
const handleClick = useCallback((id: string) => {
  setSelected(id);
}, []);  // 의존성 없으면 함수 재생성 안 함

// useMemo: 값 메모이제이션
const sortedList = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name));
}, [items]);  // items 변경 시에만 재계산
```

### 메모이제이션 기준

```markdown
사용해야 할 때:
- 자식 컴포넌트에 함수/객체 전달 시
- 비용이 큰 계산
- 참조 동등성이 중요할 때 (useEffect 의존성 등)

사용하지 않아도 될 때:
- 단순한 값
- 컴포넌트 내부에서만 사용
- 렌더링마다 달라져야 하는 값
```

---

## 커스텀 훅

### 작성 패턴

```typescript
// 네이밍: use + 기능명
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      try {
        setIsLoading(true);
        const data = await getUser(userId);
        if (!cancelled) {
          setUser(data);
        }
      } catch (e) {
        if (!cancelled) {
          setError(e as Error);
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    }

    fetchUser();
    return () => { cancelled = true; };
  }, [userId]);

  return { user, isLoading, error };
}
```

### 반환 형태

```typescript
// 객체 반환 (권장) - 명확한 네이밍
return { user, isLoading, error, refetch };

// 배열 반환 - 이름 변경이 필요할 때
return [value, setValue] as const;
```

---

## React 19 신규 기능

### use() 훅

```typescript
// Promise를 직접 읽기
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);  // Suspense와 함께 사용
  return <div>{user.name}</div>;
}

// Context 읽기 (useContext 대체 가능)
function Theme() {
  const theme = use(ThemeContext);
  return <div className={theme}></div>;
}
```

### ref를 prop으로 전달

```typescript
// React 19: forwardRef 없이 ref 전달 가능
function Input({ ref, ...props }: { ref?: React.Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}
```

### Context를 직접 렌더링

```typescript
// React 19: Provider 없이 Context 렌더링
const ThemeContext = createContext('light');

function App() {
  return (
    <ThemeContext value="dark">
      <Page />
    </ThemeContext>
  );
}
```

---

## 상태 관리

### 판단 기준

```markdown
| 상태 유형 | 권장 방식 |
|-----------|-----------|
| 컴포넌트 로컬 UI | useState |
| 복잡한 로컬 로직 | useReducer |
| 서버 데이터 | React Query / SWR |
| 전역 UI (테마 등) | Context |
| 복잡한 전역 | Zustand / Jotai |
```

### Context 사용

```typescript
// Context 생성
const UserContext = createContext<User | null>(null);

// Provider
function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  return (
    <UserContext.Provider value={user}>
      {children}
    </UserContext.Provider>
  );
}

// 사용
function useUserContext() {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUserContext must be within UserProvider');
  }
  return context;
}
```

---

## 성능 최적화

### 리렌더링 방지

```typescript
// React.memo로 컴포넌트 메모이제이션
const UserCard = memo(function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
});

// 커스텀 비교 함수
const UserCard = memo(
  function UserCard({ user }: { user: User }) {
    return <div>{user.name}</div>;
  },
  (prev, next) => prev.user.id === next.user.id
);
```

### 상태 분리

```typescript
// 나쁨: 하나의 큰 상태
const [state, setState] = useState({ user, posts, comments });

// 좋음: 관련 상태 분리
const [user, setUser] = useState<User | null>(null);
const [posts, setPosts] = useState<Post[]>([]);
```

---

## 에러 처리

### Error Boundary

```typescript
// 클래스 컴포넌트로 구현 필요
class ErrorBoundary extends Component<
  { children: ReactNode; fallback: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error(error, info);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// 사용
<ErrorBoundary fallback={<div>문제가 발생했습니다</div>}>
  <UserProfile />
</ErrorBoundary>
```

---

## 폼 처리

### react-hook-form + zod

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('유효한 이메일을 입력하세요'),
  password: z.string().min(8, '8자 이상 입력하세요'),
});

type FormData = z.infer<typeof schema>;

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}

      <button disabled={isSubmitting}>
        {isSubmitting ? '로딩...' : '로그인'}
      </button>
    </form>
  );
}
```

---

## 접근성

### 기본 원칙

```typescript
// 시맨틱 HTML 사용
<button>클릭</button>  // O
<div onClick={...}>클릭</div>  // X

// aria 속성
<button aria-label="닫기" aria-pressed={isOpen}>
  <CloseIcon />
</button>

// 키보드 접근성
<div
  role="button"
  tabIndex={0}
  onKeyDown={(e) => e.key === 'Enter' && onClick()}
>
```
