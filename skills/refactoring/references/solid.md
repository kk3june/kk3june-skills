# SOLID 원칙

> 출처: Robert C. Martin

---

## S - Single Responsibility Principle (단일 책임 원칙)

> 클래스는 단 하나의 변경 이유만 가져야 한다.

### 위반 예시

```typescript
// 나쁨 - 여러 책임
class UserService {
  createUser(data: UserData) { /* 사용자 생성 */ }
  sendEmail(user: User, message: string) { /* 이메일 전송 */ }
  generateReport(user: User) { /* PDF 보고서 생성 */ }
  validateUserData(data: UserData) { /* 데이터 검증 */ }
}
```

### 적용 예시

```typescript
// 좋음 - 책임 분리
class UserService {
  constructor(
    private userRepository: UserRepository,
    private validator: UserValidator
  ) {}

  createUser(data: UserData): User {
    this.validator.validate(data);
    return this.userRepository.save(data);
  }
}

class EmailService {
  sendEmail(to: string, message: string) { /* 이메일 전송 */ }
}

class ReportGenerator {
  generateUserReport(user: User): PDF { /* PDF 생성 */ }
}
```

### React 컴포넌트에서

```typescript
// 나쁨 - 여러 책임
function UserDashboard() {
  // 데이터 페칭
  const [user, setUser] = useState(null);
  useEffect(() => { fetchUser().then(setUser); }, []);

  // 폼 상태 관리
  const [formData, setFormData] = useState({});

  // 유효성 검증 로직
  const validate = () => { /* ... */ };

  // 렌더링
  return ( /* ... */ );
}

// 좋음 - 책임 분리
function UserDashboard() {
  const { user, isLoading } = useUser();  // 데이터 페칭 훅
  const { formData, handleChange } = useUserForm();  // 폼 훅

  if (isLoading) return <Loading />;
  return <UserView user={user} formData={formData} />;
}
```

---

## O - Open/Closed Principle (개방/폐쇄 원칙)

> 소프트웨어 요소는 확장에는 열려 있고, 수정에는 닫혀 있어야 한다.

### 위반 예시

```typescript
// 나쁨 - 새 타입 추가 시 수정 필요
class AreaCalculator {
  calculateArea(shape: Shape): number {
    if (shape.type === 'rectangle') {
      return shape.width * shape.height;
    } else if (shape.type === 'circle') {
      return Math.PI * shape.radius ** 2;
    } else if (shape.type === 'triangle') {
      // 새 도형 추가할 때마다 수정 필요
      return (shape.base * shape.height) / 2;
    }
  }
}
```

### 적용 예시

```typescript
// 좋음 - 확장 가능
interface Shape {
  calculateArea(): number;
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  calculateArea(): number {
    return this.width * this.height;
  }
}

class Circle implements Shape {
  constructor(private radius: number) {}
  calculateArea(): number {
    return Math.PI * this.radius ** 2;
  }
}

// 새 도형 추가 - 기존 코드 수정 없음
class Triangle implements Shape {
  constructor(private base: number, private height: number) {}
  calculateArea(): number {
    return (this.base * this.height) / 2;
  }
}

class AreaCalculator {
  calculateArea(shape: Shape): number {
    return shape.calculateArea();
  }
}
```

### React에서

```typescript
// 나쁨 - 타입별 분기
function Button({ type, children }) {
  if (type === 'primary') {
    return <button className="bg-blue-500">{children}</button>;
  } else if (type === 'danger') {
    return <button className="bg-red-500">{children}</button>;
  }
  // 새 타입 추가 시 수정 필요
}

// 좋음 - 변형 컴포넌트
const buttonVariants = {
  primary: 'bg-blue-500 text-white',
  danger: 'bg-red-500 text-white',
  secondary: 'bg-gray-200 text-gray-800',  // 쉽게 추가
};

function Button({ variant = 'primary', children, className }) {
  return (
    <button className={cn(buttonVariants[variant], className)}>
      {children}
    </button>
  );
}
```

---

## L - Liskov Substitution Principle (리스코프 치환 원칙)

> 서브타입은 기반 타입을 완전히 대체할 수 있어야 한다.

### 위반 예시

```typescript
// 나쁨 - 정사각형은 직사각형이 아니다
class Rectangle {
  constructor(protected width: number, protected height: number) {}

  setWidth(width: number) { this.width = width; }
  setHeight(height: number) { this.height = height; }
  getArea(): number { return this.width * this.height; }
}

class Square extends Rectangle {
  setWidth(width: number) {
    this.width = width;
    this.height = width;  // 문제! 예상치 못한 동작
  }
  setHeight(height: number) {
    this.width = height;
    this.height = height;
  }
}

// 클라이언트 코드
function resize(rect: Rectangle) {
  rect.setWidth(5);
  rect.setHeight(10);
  console.log(rect.getArea());  // Rectangle: 50, Square: 100 (!!)
}
```

### 적용 예시

```typescript
// 좋음 - 공통 인터페이스
interface Shape {
  getArea(): number;
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  getArea(): number { return this.width * this.height; }
}

class Square implements Shape {
  constructor(private side: number) {}
  getArea(): number { return this.side ** 2; }
}
```

### React에서

```typescript
// 인터페이스 준수
interface ButtonProps {
  onClick?: () => void;
  disabled?: boolean;
  children: React.ReactNode;
}

// 기본 버튼
function Button({ onClick, disabled, children }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{children}</button>;
}

// 링크처럼 보이는 버튼 - 같은 인터페이스
function LinkButton({ onClick, disabled, children }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="underline text-blue-500"
    >
      {children}
    </button>
  );
}

// 부모 컴포넌트에서 교체 가능
function Parent({ useLinkStyle }: { useLinkStyle: boolean }) {
  const ButtonComponent = useLinkStyle ? LinkButton : Button;
  return <ButtonComponent onClick={() => {}}>Click</ButtonComponent>;
}
```

---

## I - Interface Segregation Principle (인터페이스 분리 원칙)

> 클라이언트는 자신이 사용하지 않는 메서드에 의존하지 않아야 한다.

### 위반 예시

```typescript
// 나쁨 - 뚱뚱한 인터페이스
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

class Human implements Worker {
  work() { /* ... */ }
  eat() { /* ... */ }
  sleep() { /* ... */ }
}

class Robot implements Worker {
  work() { /* ... */ }
  eat() { throw new Error('Robots do not eat'); }  // 불필요
  sleep() { throw new Error('Robots do not sleep'); }  // 불필요
}
```

### 적용 예시

```typescript
// 좋음 - 분리된 인터페이스
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

interface Sleepable {
  sleep(): void;
}

class Human implements Workable, Eatable, Sleepable {
  work() { /* ... */ }
  eat() { /* ... */ }
  sleep() { /* ... */ }
}

class Robot implements Workable {
  work() { /* ... */ }
}
```

### React Props에서

```typescript
// 나쁨 - 모든 props를 하나의 인터페이스에
interface UserCardProps {
  user: User;
  onEdit: () => void;
  onDelete: () => void;
  onShare: () => void;
  isAdmin: boolean;
  showActions: boolean;
  // ... 계속 늘어남
}

// 좋음 - 필요한 것만
interface UserInfoProps {
  user: User;
}

interface UserActionsProps {
  onEdit: () => void;
  onDelete: () => void;
}

function UserInfo({ user }: UserInfoProps) {
  return <div>{user.name}</div>;
}

function UserActions({ onEdit, onDelete }: UserActionsProps) {
  return (
    <>
      <button onClick={onEdit}>Edit</button>
      <button onClick={onDelete}>Delete</button>
    </>
  );
}

function UserCard({ user, onEdit, onDelete }: UserInfoProps & UserActionsProps) {
  return (
    <div>
      <UserInfo user={user} />
      <UserActions onEdit={onEdit} onDelete={onDelete} />
    </div>
  );
}
```

---

## D - Dependency Inversion Principle (의존성 역전 원칙)

> 고수준 모듈은 저수준 모듈에 의존하면 안 된다. 둘 다 추상화에 의존해야 한다.

### 위반 예시

```typescript
// 나쁨 - 고수준이 저수준에 의존
class MySQLDatabase {
  save(data: any) { /* MySQL 저장 */ }
}

class UserService {
  private database = new MySQLDatabase();  // 직접 의존

  saveUser(user: User) {
    this.database.save(user);  // MySQL에 강결합
  }
}
```

### 적용 예시

```typescript
// 좋음 - 추상화에 의존
interface Database {
  save(data: any): void;
}

class MySQLDatabase implements Database {
  save(data: any) { /* MySQL 저장 */ }
}

class MongoDatabase implements Database {
  save(data: any) { /* Mongo 저장 */ }
}

class UserService {
  constructor(private database: Database) {}  // 추상화에 의존

  saveUser(user: User) {
    this.database.save(user);  // 어떤 DB든 교체 가능
  }
}

// 사용
const mysqlService = new UserService(new MySQLDatabase());
const mongoService = new UserService(new MongoDatabase());
```

### React에서

```typescript
// 나쁨 - 직접 의존
function UserList() {
  const users = useFetchUsers();  // 특정 페칭 로직에 의존
  return users.map(u => <div>{u.name}</div>);
}

// 좋음 - 추상화에 의존
interface UserListProps {
  users: User[];
}

function UserList({ users }: UserListProps) {
  return users.map(u => <div key={u.id}>{u.name}</div>);
}

// 컨테이너에서 주입
function UserListContainer() {
  const users = useFetchUsers();  // 여기서 페칭
  return <UserList users={users} />;  // 데이터 주입
}

// 테스트 가능
function TestUserList() {
  const mockUsers = [{ id: '1', name: 'Test' }];
  return <UserList users={mockUsers} />;
}
```

### Context로 의존성 주입

```typescript
// 서비스 인터페이스
interface AuthService {
  login(email: string, password: string): Promise<User>;
  logout(): Promise<void>;
}

// Context 생성
const AuthServiceContext = createContext<AuthService | null>(null);

// Provider
function AuthServiceProvider({ children, service }: {
  children: React.ReactNode;
  service: AuthService;
}) {
  return (
    <AuthServiceContext.Provider value={service}>
      {children}
    </AuthServiceContext.Provider>
  );
}

// 사용하는 훅
function useAuthService() {
  const service = useContext(AuthServiceContext);
  if (!service) throw new Error('AuthServiceProvider required');
  return service;
}

// 컴포넌트는 구체 구현을 모름
function LoginButton() {
  const authService = useAuthService();
  return <button onClick={() => authService.login(email, pw)}>Login</button>;
}
```
