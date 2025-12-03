# Best Practices - 핵심 패턴

> 프로젝트에 전례가 없을 때 참조하는 핵심 패턴
> 사용하면서 좋은 패턴 발견 시 추가

---

## 1. 컴포넌트 분리 기준

### 분리해야 할 때
- 재사용이 필요할 때
- 파일이 200줄 이상일 때
- 하나의 컴포넌트가 여러 책임을 가질 때
- 테스트가 어려울 때

### 분리 방법
```tsx
// Before: 모든 것이 한 곳에
function UserPage() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  // ... 200줄의 로직
}

// After: 책임별 분리
function UserPage() {
  return (
    <UserProvider>
      <UserProfile />
      <UserPosts />
    </UserProvider>
  );
}
```

---

## 2. 상태 관리 선택 기준

| 상태 유형 | 권장 방식 | 예시 |
|-----------|-----------|------|
| 컴포넌트 로컬 | useState | 폼 입력, 토글 |
| 복잡한 로컬 | useReducer | 다단계 폼 |
| 서버 데이터 | React Query | API 응답 |
| 전역 UI | Context | 테마, 모달 |
| 복잡한 전역 | Zustand | 장바구니, 인증 |

### 선택 플로우차트
```
서버 데이터인가?
├─ Yes → React Query / SWR
└─ No → 여러 컴포넌트에서 필요한가?
         ├─ No → useState / useReducer
         └─ Yes → 자주 변경되는가?
                  ├─ Yes → Zustand
                  └─ No → Context
```

---

## 3. API 호출 패턴

### 기본 구조
```typescript
// api/user.ts
const API_BASE = import.meta.env.VITE_API_URL;

export const userApi = {
  getAll: () =>
    axios.get<User[]>(`${API_BASE}/users`).then(res => res.data),

  getById: (id: string) =>
    axios.get<User>(`${API_BASE}/users/${id}`).then(res => res.data),

  create: (data: CreateUserDto) =>
    axios.post<User>(`${API_BASE}/users`, data).then(res => res.data),
};
```

### 훅으로 래핑
```typescript
// hooks/useUser.ts
export function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    userApi.getById(id)
      .then(data => !cancelled && setUser(data))
      .catch(err => !cancelled && setError(err))
      .finally(() => !cancelled && setIsLoading(false));

    return () => { cancelled = true; };
  }, [id]);

  return { user, isLoading, error };
}
```

---

## 4. 에러 처리 패턴

### API 에러 처리
```typescript
// utils/error.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public code?: string
  ) {
    super(message);
  }
}

// 사용
try {
  await userApi.create(data);
} catch (error) {
  if (error instanceof ApiError) {
    if (error.status === 401) {
      // 인증 에러 처리
    } else if (error.status === 422) {
      // 유효성 검증 에러 처리
    }
  }
  throw error;
}
```

### 컴포넌트 에러 처리
```tsx
function UserProfile({ userId }: { userId: string }) {
  const { user, isLoading, error } = useUser(userId);

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;

  return <div>{user.name}</div>;
}
```

---

## 5. 타입 정의 패턴

### 엔티티 타입
```typescript
// types/user.ts
export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

// DTO
export interface CreateUserDto {
  email: string;
  name: string;
}

export interface UpdateUserDto {
  name?: string;
}
```

### Props 타입
```typescript
// interface 사용 (확장 가능)
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  onClick?: () => void;
}

// 기존 HTML 속성 확장
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
}
```

### 제네릭 활용
```typescript
// 재사용 가능한 API 응답 타입
interface ApiResponse<T> {
  data: T;
  meta: {
    total: number;
    page: number;
  };
}

// 사용
const response: ApiResponse<User[]> = await userApi.getAll();
```

---

## 6. 폴더 구조

### Feature 기반 (권장)
```
src/
├── features/
│   ├── user/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api.ts
│   │   ├── types.ts
│   │   └── index.ts
│   └── post/
│       └── ...
├── shared/
│   ├── components/
│   ├── hooks/
│   └── utils/
└── app/
    └── routes/
```

### 장점
- 관련 코드가 한 곳에 (높은 응집도)
- 기능별 독립적 개발/삭제 가능
- import 경로가 명확

---

## 추가된 패턴

> 프로젝트에서 발견/생성된 좋은 패턴을 여기에 추가

<!--
### 패턴명
- 발견 일자:
- 파일:
- 설명:

```typescript
// 코드 예시
```
-->
