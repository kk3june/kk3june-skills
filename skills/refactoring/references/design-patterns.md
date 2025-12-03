# 디자인 패턴

> React/TypeScript 환경에서 자주 사용되는 패턴

---

## 생성 패턴 (Creational)

### Factory Pattern

```typescript
// 팩토리 함수
interface Button {
  render(): React.ReactNode;
}

function createButton(type: 'primary' | 'danger' | 'link'): Button {
  switch (type) {
    case 'primary':
      return { render: () => <button className="bg-blue-500">Primary</button> };
    case 'danger':
      return { render: () => <button className="bg-red-500">Danger</button> };
    case 'link':
      return { render: () => <button className="underline">Link</button> };
  }
}

// React에서: 컴포넌트 팩토리
function createFormField(type: 'text' | 'number' | 'email') {
  const Field = ({ name, label }: { name: string; label: string }) => {
    return (
      <div>
        <label>{label}</label>
        <input type={type} name={name} />
      </div>
    );
  };
  Field.displayName = `${type}Field`;
  return Field;
}

const TextField = createFormField('text');
const EmailField = createFormField('email');
```

### Singleton Pattern

```typescript
// 클래스 싱글톤
class ApiClient {
  private static instance: ApiClient;
  private constructor() {}

  static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  fetch(url: string) { /* ... */ }
}

// React에서: Context + Provider
const ApiClientContext = createContext<ApiClient | null>(null);

function ApiClientProvider({ children }: { children: React.ReactNode }) {
  const client = useMemo(() => new ApiClient(), []);
  return (
    <ApiClientContext.Provider value={client}>
      {children}
    </ApiClientContext.Provider>
  );
}
```

### Builder Pattern

```typescript
// 복잡한 객체 생성
class QueryBuilder {
  private query: QueryConfig = { filters: [], sort: null, limit: 10 };

  where(field: string, value: any) {
    this.query.filters.push({ field, value });
    return this;
  }

  orderBy(field: string, direction: 'asc' | 'desc') {
    this.query.sort = { field, direction };
    return this;
  }

  take(limit: number) {
    this.query.limit = limit;
    return this;
  }

  build(): QueryConfig {
    return { ...this.query };
  }
}

// 사용
const query = new QueryBuilder()
  .where('status', 'active')
  .where('role', 'admin')
  .orderBy('createdAt', 'desc')
  .take(20)
  .build();
```

---

## 구조 패턴 (Structural)

### Adapter Pattern

```typescript
// 외부 라이브러리 래핑
interface Logger {
  info(message: string): void;
  error(message: string): void;
}

// 외부 라이브러리 (변경 불가)
class ThirdPartyLogger {
  writeLog(level: string, msg: string) {
    console.log(`[${level}] ${msg}`);
  }
}

// 어댑터
class LoggerAdapter implements Logger {
  constructor(private thirdParty: ThirdPartyLogger) {}

  info(message: string) {
    this.thirdParty.writeLog('INFO', message);
  }

  error(message: string) {
    this.thirdParty.writeLog('ERROR', message);
  }
}

// 사용
const logger: Logger = new LoggerAdapter(new ThirdPartyLogger());
logger.info('Hello');
```

### Composite Pattern

```typescript
// 트리 구조
interface MenuItem {
  render(): React.ReactNode;
}

class SimpleMenuItem implements MenuItem {
  constructor(private label: string, private onClick: () => void) {}

  render() {
    return <button onClick={this.onClick}>{this.label}</button>;
  }
}

class MenuGroup implements MenuItem {
  private items: MenuItem[] = [];

  constructor(private label: string) {}

  add(item: MenuItem) {
    this.items.push(item);
  }

  render() {
    return (
      <div>
        <span>{this.label}</span>
        <div>{this.items.map((item, i) => <div key={i}>{item.render()}</div>)}</div>
      </div>
    );
  }
}
```

### Decorator Pattern

```typescript
// 함수 데코레이터
function withLogging<T extends (...args: any[]) => any>(fn: T): T {
  return ((...args: Parameters<T>) => {
    console.log(`Calling ${fn.name} with`, args);
    const result = fn(...args);
    console.log(`Result:`, result);
    return result;
  }) as T;
}

const add = (a: number, b: number) => a + b;
const loggedAdd = withLogging(add);

// React HOC (High Order Component)
function withAuth<P extends object>(Component: React.ComponentType<P>) {
  return function AuthenticatedComponent(props: P) {
    const { user, isLoading } = useAuth();

    if (isLoading) return <Loading />;
    if (!user) return <Navigate to="/login" />;

    return <Component {...props} />;
  };
}

const ProtectedDashboard = withAuth(Dashboard);
```

---

## 행동 패턴 (Behavioral)

### Strategy Pattern

```typescript
// 전략 인터페이스
interface SortStrategy<T> {
  sort(items: T[]): T[];
}

class NameSortStrategy implements SortStrategy<User> {
  sort(users: User[]) {
    return [...users].sort((a, b) => a.name.localeCompare(b.name));
  }
}

class DateSortStrategy implements SortStrategy<User> {
  sort(users: User[]) {
    return [...users].sort((a, b) =>
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  }
}

// 컨텍스트
class UserSorter {
  constructor(private strategy: SortStrategy<User>) {}

  setStrategy(strategy: SortStrategy<User>) {
    this.strategy = strategy;
  }

  sort(users: User[]) {
    return this.strategy.sort(users);
  }
}

// React에서
function UserList({ sortBy }: { sortBy: 'name' | 'date' }) {
  const users = useUsers();

  const sortedUsers = useMemo(() => {
    const strategy = sortBy === 'name'
      ? new NameSortStrategy()
      : new DateSortStrategy();
    return strategy.sort(users);
  }, [users, sortBy]);

  return <ul>{sortedUsers.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

### Observer Pattern

```typescript
// Subject
class EventEmitter<T> {
  private listeners: ((data: T) => void)[] = [];

  subscribe(listener: (data: T) => void) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  emit(data: T) {
    this.listeners.forEach(listener => listener(data));
  }
}

// React에서: Custom Hook
function useEventEmitter<T>() {
  const emitterRef = useRef(new EventEmitter<T>());
  return emitterRef.current;
}

function useSubscription<T>(emitter: EventEmitter<T>, callback: (data: T) => void) {
  useEffect(() => {
    return emitter.subscribe(callback);
  }, [emitter, callback]);
}
```

### Command Pattern

```typescript
// 명령 인터페이스
interface Command {
  execute(): void;
  undo(): void;
}

class AddTextCommand implements Command {
  constructor(
    private editor: Editor,
    private text: string,
    private position: number
  ) {}

  execute() {
    this.editor.insertAt(this.position, this.text);
  }

  undo() {
    this.editor.deleteAt(this.position, this.text.length);
  }
}

// 커맨드 관리자
class CommandManager {
  private history: Command[] = [];
  private position = -1;

  execute(command: Command) {
    command.execute();
    this.history = this.history.slice(0, this.position + 1);
    this.history.push(command);
    this.position++;
  }

  undo() {
    if (this.position >= 0) {
      this.history[this.position].undo();
      this.position--;
    }
  }

  redo() {
    if (this.position < this.history.length - 1) {
      this.position++;
      this.history[this.position].execute();
    }
  }
}
```

---

## React 특화 패턴

### Compound Components

```typescript
// 컴파운드 컴포넌트
interface TabsContextType {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextType | null>(null);

function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

function TabList({ children }: { children: React.ReactNode }) {
  return <div className="tab-list">{children}</div>;
}

function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab must be within Tabs');

  return (
    <button
      className={context.activeTab === id ? 'active' : ''}
      onClick={() => context.setActiveTab(id)}
    >
      {children}
    </button>
  );
}

function TabPanel({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabPanel must be within Tabs');

  if (context.activeTab !== id) return null;
  return <div className="tab-panel">{children}</div>;
}

// 조합
Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panel = TabPanel;

// 사용
<Tabs defaultTab="tab1">
  <Tabs.List>
    <Tabs.Tab id="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab id="tab2">Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel id="tab1">Content 1</Tabs.Panel>
  <Tabs.Panel id="tab2">Content 2</Tabs.Panel>
</Tabs>
```

### Render Props

```typescript
// 렌더 프롭 패턴
interface MousePosition {
  x: number;
  y: number;
}

function MouseTracker({ render }: { render: (pos: MousePosition) => React.ReactNode }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);

  return <>{render(position)}</>;
}

// 사용
<MouseTracker
  render={({ x, y }) => (
    <div>
      Mouse: {x}, {y}
    </div>
  )}
/>
```

### Custom Hook Extraction

```typescript
// 로직 추출 전
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    fetchUser(userId)
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
  }, [userId]);

  if (isLoading) return <Loading />;
  if (error) return <Error error={error} />;
  return <div>{user?.name}</div>;
}

// 로직 추출 후
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    fetchUser(userId)
      .then(data => { if (!cancelled) setUser(data); })
      .catch(err => { if (!cancelled) setError(err); })
      .finally(() => { if (!cancelled) setIsLoading(false); });

    return () => { cancelled = true; };
  }, [userId]);

  return { user, isLoading, error };
}

function UserProfile({ userId }: { userId: string }) {
  const { user, isLoading, error } = useUser(userId);

  if (isLoading) return <Loading />;
  if (error) return <Error error={error} />;
  return <div>{user?.name}</div>;
}
```

### Container/Presentational

```typescript
// Presentational (순수 UI)
interface UserListViewProps {
  users: User[];
  onSelectUser: (user: User) => void;
}

function UserListView({ users, onSelectUser }: UserListViewProps) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id} onClick={() => onSelectUser(user)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}

// Container (로직)
function UserListContainer() {
  const { users, isLoading } = useUsers();
  const navigate = useNavigate();

  const handleSelectUser = (user: User) => {
    navigate(`/users/${user.id}`);
  };

  if (isLoading) return <Loading />;

  return <UserListView users={users} onSelectUser={handleSelectUser} />;
}
```

### Controlled vs Uncontrolled

```typescript
// Controlled - 상태를 외부에서 관리
interface ControlledInputProps {
  value: string;
  onChange: (value: string) => void;
}

function ControlledInput({ value, onChange }: ControlledInputProps) {
  return (
    <input
      value={value}
      onChange={e => onChange(e.target.value)}
    />
  );
}

// Uncontrolled - 내부 상태 사용
function UncontrolledInput({ defaultValue }: { defaultValue?: string }) {
  const inputRef = useRef<HTMLInputElement>(null);

  const getValue = () => inputRef.current?.value;

  return <input ref={inputRef} defaultValue={defaultValue} />;
}

// 둘 다 지원
interface FlexibleInputProps {
  value?: string;
  defaultValue?: string;
  onChange?: (value: string) => void;
}

function FlexibleInput({ value, defaultValue, onChange }: FlexibleInputProps) {
  const isControlled = value !== undefined;

  if (isControlled) {
    return <input value={value} onChange={e => onChange?.(e.target.value)} />;
  }

  return <input defaultValue={defaultValue} />;
}
```
