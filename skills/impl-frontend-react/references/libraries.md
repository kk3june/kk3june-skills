# 프론트엔드 라이브러리 Best Practices

---

## Tailwind CSS

> 공식 문서: https://tailwindcss.com/docs

### 기본 패턴

```typescript
// 조건부 클래스
import clsx from 'clsx';  // 또는 cn from @/lib/utils

function Button({ variant, disabled }: ButtonProps) {
  return (
    <button
      className={clsx(
        'px-4 py-2 rounded font-medium',
        variant === 'primary' && 'bg-blue-500 text-white',
        variant === 'secondary' && 'bg-gray-200 text-gray-800',
        disabled && 'opacity-50 cursor-not-allowed'
      )}
    >
      Click
    </button>
  );
}
```

### 반응형

```typescript
<div className="
  w-full          // 기본 (모바일)
  md:w-1/2        // 768px 이상
  lg:w-1/3        // 1024px 이상
  xl:w-1/4        // 1280px 이상
">
```

### 다크 모드

```typescript
<div className="bg-white dark:bg-gray-900">
  <p className="text-gray-900 dark:text-white">
    다크 모드 지원
  </p>
</div>
```

### 커스텀 유틸리티 (cn 함수)

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// 사용
<div className={cn(
  'p-4 rounded',
  isActive && 'bg-blue-500',
  className  // 외부에서 받은 클래스
)} />
```

---

## Shadcn/ui

> 공식 문서: https://ui.shadcn.com

### 컴포넌트 사용

```typescript
// 설치된 컴포넌트 import
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';

function Example() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">열기</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>제목</DialogTitle>
        </DialogHeader>
        <Input placeholder="입력..." />
      </DialogContent>
    </Dialog>
  );
}
```

### Button 변형

```typescript
<Button>기본</Button>
<Button variant="secondary">보조</Button>
<Button variant="outline">외곽선</Button>
<Button variant="ghost">고스트</Button>
<Button variant="link">링크</Button>
<Button variant="destructive">삭제</Button>
<Button size="sm">작은</Button>
<Button size="lg">큰</Button>
<Button disabled>비활성</Button>
```

### Form 컴포넌트

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';

function MyForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>이메일</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">제출</Button>
      </form>
    </Form>
  );
}
```

---

## React Hook Form

> 공식 문서: https://react-hook-form.com

### 기본 사용

```typescript
import { useForm, SubmitHandler } from 'react-hook-form';

interface FormData {
  email: string;
  password: string;
}

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
    watch,
    setValue,
  } = useForm<FormData>();

  const onSubmit: SubmitHandler<FormData> = async (data) => {
    await login(data);
    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email', {
          required: '이메일을 입력하세요',
          pattern: {
            value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
            message: '유효한 이메일을 입력하세요',
          },
        })}
      />
      {errors.email && <span>{errors.email.message}</span>}

      <input
        type="password"
        {...register('password', {
          required: '비밀번호를 입력하세요',
          minLength: {
            value: 8,
            message: '8자 이상 입력하세요',
          },
        })}
      />
      {errors.password && <span>{errors.password.message}</span>}

      <button disabled={isSubmitting}>
        {isSubmitting ? '로딩...' : '로그인'}
      </button>
    </form>
  );
}
```

### watch로 값 추적

```typescript
const password = watch('password');
const allValues = watch();  // 전체 폼 값
```

---

## Zod

> 공식 문서: https://zod.dev

### 스키마 정의

```typescript
import { z } from 'zod';

// 기본 스키마
const userSchema = z.object({
  name: z.string().min(2, '2자 이상 입력하세요'),
  email: z.string().email('유효한 이메일을 입력하세요'),
  age: z.number().min(0).max(120).optional(),
  role: z.enum(['admin', 'user', 'guest']),
});

// 타입 추출
type User = z.infer<typeof userSchema>;
```

### 검증

```typescript
// 검증 (에러 시 throw)
const user = userSchema.parse(data);

// 안전한 검증
const result = userSchema.safeParse(data);
if (result.success) {
  console.log(result.data);
} else {
  console.log(result.error.errors);
}
```

### react-hook-form과 통합

```typescript
import { zodResolver } from '@hookform/resolvers/zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

type FormData = z.infer<typeof schema>;

function Form() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      email: '',
      password: '',
    },
  });
}
```

### 고급 스키마

```typescript
// 조건부 필드
const schema = z.object({
  type: z.enum(['personal', 'business']),
  companyName: z.string().optional(),
}).refine(
  (data) => data.type !== 'business' || data.companyName,
  { message: '회사명을 입력하세요', path: ['companyName'] }
);

// 변환
const schema = z.string().transform((val) => val.toLowerCase());

// 배열
const schema = z.array(z.string()).min(1, '최소 1개 필요');

// Union
const schema = z.union([z.string(), z.number()]);
```

---

## Lucide React (아이콘)

> 공식 문서: https://lucide.dev

```typescript
import { Search, User, Settings, ChevronRight } from 'lucide-react';

function Example() {
  return (
    <div>
      <Search className="w-4 h-4" />
      <User size={24} color="blue" />
      <Settings className="w-6 h-6 text-gray-500" />
      <ChevronRight strokeWidth={1.5} />
    </div>
  );
}
```

---

## Axios

> 공식 문서: https://axios-http.com

### 인스턴스 설정

```typescript
// lib/axios.ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 요청 인터셉터
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 응답 인터셉터
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // 로그아웃 처리
    }
    return Promise.reject(error);
  }
);
```

### 사용

```typescript
// API 함수
export const userApi = {
  getAll: () => api.get<User[]>('/users'),
  getById: (id: string) => api.get<User>(`/users/${id}`),
  create: (data: CreateUserDto) => api.post<User>('/users', data),
  update: (id: string, data: UpdateUserDto) => api.patch<User>(`/users/${id}`, data),
  delete: (id: string) => api.delete(`/users/${id}`),
};
```

---

## dnd-kit (드래그 앤 드롭)

> 공식 문서: https://dndkit.com

### 기본 설정

```typescript
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';

function SortableList() {
  const [items, setItems] = useState(['1', '2', '3']);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      setItems((items) => {
        const oldIndex = items.indexOf(active.id as string);
        const newIndex = items.indexOf(over.id as string);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragEnd={handleDragEnd}
    >
      <SortableContext items={items} strategy={verticalListSortingStrategy}>
        {items.map((id) => (
          <SortableItem key={id} id={id} />
        ))}
      </SortableContext>
    </DndContext>
  );
}
```

### Sortable Item

```typescript
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

function SortableItem({ id }: { id: string }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners}>
      Item {id}
    </div>
  );
}
```

### 드래그 핸들 분리

```typescript
function SortableItem({ id }: { id: string }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id });

  return (
    <div ref={setNodeRef} style={{ transform: CSS.Transform.toString(transform), transition }}>
      {/* 드래그 핸들만 드래그 가능 */}
      <button {...attributes} {...listeners}>
        <GripVertical className="w-4 h-4" />
      </button>
      <span>Item {id}</span>
    </div>
  );
}
```

---

## date-fns (날짜 처리)

> 공식 문서: https://date-fns.org

### 포맷팅

```typescript
import { format, formatDistance, formatRelative } from 'date-fns';
import { ko } from 'date-fns/locale';

// 기본 포맷
format(new Date(), 'yyyy-MM-dd');  // "2024-12-03"
format(new Date(), 'yyyy년 M월 d일');  // "2024년 12월 3일"
format(new Date(), 'HH:mm:ss');  // "14:30:00"

// 한국어 로케일
format(new Date(), 'PPP', { locale: ko });  // "2024년 12월 3일"
format(new Date(), 'EEEE', { locale: ko });  // "화요일"

// 상대 시간
formatDistance(new Date(), new Date(2024, 11, 1), { locale: ko });  // "2일 후"
formatRelative(new Date(), new Date(), { locale: ko });  // "오늘 오후 2:30"
```

### 날짜 계산

```typescript
import {
  addDays,
  subDays,
  addMonths,
  startOfMonth,
  endOfMonth,
  differenceInDays,
  isAfter,
  isBefore,
  isWithinInterval,
} from 'date-fns';

// 날짜 더하기/빼기
addDays(new Date(), 7);  // 7일 후
subDays(new Date(), 7);  // 7일 전
addMonths(new Date(), 1);  // 1달 후

// 월의 시작/끝
startOfMonth(new Date());  // 이번 달 1일
endOfMonth(new Date());  // 이번 달 마지막 날

// 차이 계산
differenceInDays(new Date(2024, 11, 25), new Date());  // 크리스마스까지 남은 일수

// 비교
isAfter(new Date(), someDate);
isBefore(new Date(), someDate);
isWithinInterval(new Date(), { start: startDate, end: endDate });
```

### 파싱

```typescript
import { parse, parseISO } from 'date-fns';

// ISO 문자열 파싱
parseISO('2024-12-03');  // Date 객체

// 커스텀 포맷 파싱
parse('2024년 12월 3일', 'yyyy년 M월 d일', new Date());
```

---

## React Router DOM

> 공식 문서: https://reactrouter.com

### 라우터 설정 (v7)

```typescript
// main.tsx
import { BrowserRouter } from 'react-router-dom';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
);
```

### 라우트 정의

```typescript
import { Routes, Route, Navigate } from 'react-router-dom';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/users" element={<UserList />} />
      <Route path="/users/:id" element={<UserDetail />} />
      <Route path="/dashboard/*" element={<Dashboard />} />
      <Route path="/login" element={<Login />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
```

### 중첩 라우트

```typescript
function Dashboard() {
  return (
    <div>
      <Sidebar />
      <Routes>
        <Route index element={<DashboardHome />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="settings" element={<Settings />} />
      </Routes>
    </div>
  );
}
```

### 네비게이션

```typescript
import { Link, NavLink, useNavigate } from 'react-router-dom';

// Link
<Link to="/users">Users</Link>
<Link to={`/users/${id}`}>상세</Link>

// NavLink (활성 상태 스타일링)
<NavLink
  to="/users"
  className={({ isActive }) => isActive ? 'text-blue-500' : ''}
>
  Users
</NavLink>

// 프로그래매틱 네비게이션
function Component() {
  const navigate = useNavigate();

  const handleClick = () => {
    navigate('/users');
    navigate(-1);  // 뒤로가기
    navigate('/login', { replace: true });  // 히스토리 대체
    navigate('/users', { state: { from: 'home' } });  // state 전달
  };
}
```

### URL 파라미터

```typescript
import { useParams, useSearchParams } from 'react-router-dom';

function UserDetail() {
  // /users/:id
  const { id } = useParams<{ id: string }>();

  // /users?page=1&sort=name
  const [searchParams, setSearchParams] = useSearchParams();
  const page = searchParams.get('page');

  const handlePageChange = (newPage: number) => {
    setSearchParams({ page: String(newPage) });
  };

  return <div>User {id}</div>;
}
```

### Protected Route

```typescript
import { Navigate, useLocation } from 'react-router-dom';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const location = useLocation();

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}

// 사용
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  }
/>
```

### Location State

```typescript
import { useLocation } from 'react-router-dom';

function Login() {
  const location = useLocation();
  const from = location.state?.from?.pathname || '/';

  const handleLogin = async () => {
    await login();
    navigate(from, { replace: true });
  };
}
```
