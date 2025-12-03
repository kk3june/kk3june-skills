# 리팩토링 기법 카탈로그

> Martin Fowler의 Refactoring 2판 기반
> React + TypeScript 예시 포함

## 기법 선택 가이드

| Smell | 권장 기법 |
|-------|----------|
| Long Function | Extract Function, Extract Variable |
| Duplicate Code | Extract Function, Pull Up Method |
| Long Parameter List | Introduce Parameter Object |
| Feature Envy | Move Function |
| Data Clumps | Extract Class |
| Primitive Obsession | Replace Primitive with Object |
| Switch Statements | Replace Conditional with Polymorphism |
| Divergent Change | Split Phase, Extract Class |
| Shotgun Surgery | Move Function, Inline Class |
| Comments | Extract Function, Rename |

---

## 1. 기본 리팩토링 (Most Common)

### 1.1 Extract Function (함수 추출)

**동기:** 코드 조각에 이름을 붙여 의도를 명확히

**Mechanics:**
1. 새 함수 생성, 의도를 드러내는 이름
2. 추출할 코드를 새 함수로 복사
3. 지역 변수 참조 확인 → 매개변수로
4. 원래 코드를 함수 호출로 대체
5. 테스트

**Before:**
```typescript
function printOwing(invoice: Invoice) {
  let outstanding = 0;
  
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
  
  // calculate outstanding
  for (const order of invoice.orders) {
    outstanding += order.amount;
  }
  
  // print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

**After:**
```typescript
function printOwing(invoice: Invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}

function printBanner() {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
}

function calculateOutstanding(invoice: Invoice): number {
  return invoice.orders.reduce((sum, order) => sum + order.amount, 0);
}

function printDetails(invoice: Invoice, outstanding: number) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

**React 적용:**
```typescript
// Before
function UserDashboard({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    setLoading(true);
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [userId]);
  
  // ... 렌더링
}

// After: Custom Hook으로 추출
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);
  
  return { user, loading };
}

function UserDashboard({ userId }: Props) {
  const { user, loading } = useUser(userId);
  // ... 렌더링
}
```

---

### 1.2 Inline Function (함수 인라인)

**동기:** 함수 본문이 이름만큼 명확할 때, 과도한 위임 제거

**Mechanics:**
1. 다형성 여부 확인 (override 있으면 중단)
2. 호출부를 함수 본문으로 대체
3. 테스트
4. 함수 정의 삭제

**Before:**
```typescript
function getRating(driver: Driver): number {
  return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver: Driver): boolean {
  return driver.lateDeliveries > 5;
}
```

**After:**
```typescript
function getRating(driver: Driver): number {
  return driver.lateDeliveries > 5 ? 2 : 1;
}
```

---

### 1.3 Extract Variable (변수 추출)

**동기:** 복잡한 표현식에 이름을 붙여 의도 명확히

**Before:**
```typescript
return (
  order.quantity * order.itemPrice -
  Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
  Math.min(order.quantity * order.itemPrice * 0.1, 100)
);
```

**After:**
```typescript
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);

return basePrice - quantityDiscount + shipping;
```

**React 적용:**
```typescript
// Before
<button
  disabled={!form.isValid || form.isSubmitting || user.role !== 'admin'}
  className={form.isSubmitting ? 'opacity-50' : ''}
>

// After
const canSubmit = form.isValid && !form.isSubmitting && user.role === 'admin';
const buttonStyle = form.isSubmitting ? 'opacity-50' : '';

<button disabled={!canSubmit} className={buttonStyle}>
```

---

### 1.4 Rename Variable / Function

**동기:** 좋은 이름이 코드를 설명함

**원칙:**
- 의도를 드러내는 이름
- 약어 피하기 (문맥상 명확할 때만)
- 일관된 어휘 사용

**Before:**
```typescript
const a = height * width;
function calc(qty: number, p: number) { return qty * p; }
const d = new Date() - startDate;
```

**After:**
```typescript
const area = height * width;
function calculateTotal(quantity: number, price: number) { return quantity * price; }
const elapsedDays = differenceInDays(new Date(), startDate);
```

**React 네이밍 컨벤션:**
```typescript
// 컴포넌트: PascalCase, 명사
function UserProfileCard() { }

// 훅: use + 동사/명사
function useUserData() { }
function useFetch() { }

// 핸들러: handle + 이벤트
const handleClick = () => { };
const handleSubmit = () => { };

// Boolean: is/has/can/should 접두어
const isLoading = true;
const hasError = false;
const canEdit = user.role === 'admin';
```

---

### 1.5 Change Function Declaration (함수 선언 변경)

**동기:** 더 나은 인터페이스, 매개변수 조정

**간단한 절차:**
1. 함수 본문에서 새 매개변수 참조 추가
2. 함수 선언 변경
3. 호출부 모두 수정
4. 테스트

**마이그레이션 절차 (호출부 많을 때):**
1. 함수 본문을 새 함수로 추출
2. 원래 함수를 래퍼로 변환
3. 호출부를 하나씩 새 함수로 변경
4. 원래 함수 삭제

**Before:**
```typescript
function circum(radius: number): number {
  return 2 * Math.PI * radius;
}
```

**After:**
```typescript
function circumference(radius: number): number {
  return 2 * Math.PI * radius;
}
```

---

## 2. 캡슐화 (Encapsulation)

### 2.1 Encapsulate Variable (변수 캡슐화)

**동기:** 데이터 접근을 함수로 감싸 변경점 통제

**Before:**
```typescript
// 전역 또는 모듈 레벨
export let defaultOwner = { firstName: "Martin", lastName: "Fowler" };
```

**After:**
```typescript
let defaultOwnerData = { firstName: "Martin", lastName: "Fowler" };

export function defaultOwner() {
  return { ...defaultOwnerData };  // 복사본 반환
}

export function setDefaultOwner(owner: Owner) {
  defaultOwnerData = owner;
}
```

**React 적용 (Context):**
```typescript
// Before: 직접 접근
export let appConfig = { theme: 'dark' };

// After: Context로 캡슐화
const ConfigContext = createContext<Config | null>(null);

export function useConfig() {
  const config = useContext(ConfigContext);
  if (!config) throw new Error('ConfigProvider required');
  return config;
}
```

---

### 2.2 Encapsulate Collection (컬렉션 캡슐화)

**동기:** 컬렉션 직접 수정 방지, 변경 추적 가능

**Before:**
```typescript
class Person {
  courses: Course[] = [];
  
  get courses() { return this.courses; }
  set courses(courses: Course[]) { this.courses = courses; }
}

// 외부에서 직접 수정 가능
person.courses.push(newCourse);  // 위험!
```

**After:**
```typescript
class Person {
  private _courses: Course[] = [];
  
  get courses() { return [...this._courses]; }  // 복사본 반환
  
  addCourse(course: Course) {
    this._courses.push(course);
  }
  
  removeCourse(course: Course) {
    const index = this._courses.indexOf(course);
    if (index > -1) this._courses.splice(index, 1);
  }
}
```

**React 적용:**
```typescript
// Before
const [items, setItems] = useState<Item[]>([]);
items.push(newItem);  // 직접 mutation - 리렌더 안됨!

// After
const [items, setItems] = useState<Item[]>([]);

const addItem = (item: Item) => {
  setItems(prev => [...prev, item]);
};

const removeItem = (id: string) => {
  setItems(prev => prev.filter(item => item.id !== id));
};
```

---

### 2.3 Replace Primitive with Object (원시값을 객체로)

**동기:** 원시값에 동작 추가, 유효성 보장

**Before:**
```typescript
// 전화번호가 그냥 string
const phone = "010-1234-5678";

// 유효성? 포맷팅? 각 사용처에서...
if (!phone.match(/^\d{3}-\d{4}-\d{4}$/)) { ... }
const formatted = phone.replace(/-/g, '');
```

**After:**
```typescript
class PhoneNumber {
  private readonly value: string;
  
  constructor(value: string) {
    if (!this.isValid(value)) {
      throw new Error('Invalid phone number');
    }
    this.value = value;
  }
  
  private isValid(value: string): boolean {
    return /^\d{3}-\d{4}-\d{4}$/.test(value);
  }
  
  get formatted(): string {
    return this.value;
  }
  
  get numbersOnly(): string {
    return this.value.replace(/-/g, '');
  }
  
  equals(other: PhoneNumber): boolean {
    return this.value === other.value;
  }
}
```

**TypeScript Branded Type 대안:**
```typescript
// 런타임 오버헤드 없이 타입 안전성
type PhoneNumber = string & { readonly brand: unique symbol };

function createPhoneNumber(value: string): PhoneNumber {
  if (!/^\d{3}-\d{4}-\d{4}$/.test(value)) {
    throw new Error('Invalid phone number');
  }
  return value as PhoneNumber;
}
```

---

## 3. 기능 이동 (Moving Features)

### 3.1 Move Function (함수 이동)

**동기:** 함수를 적절한 모듈/클래스로 이동

**판단 기준:**
- 어떤 데이터를 가장 많이 참조하는가?
- 어떤 컨텍스트에서 가장 자주 호출되는가?
- 함께 변경되는 것은 무엇인가?

**Before:**
```typescript
// utils/calculate.ts
function calculateShippingCost(order: Order): number {
  const address = order.customer.address;
  const country = address.country;
  const city = address.city;
  // address에 대한 로직...
}
```

**After:**
```typescript
// models/Address.ts
class Address {
  calculateShippingCost(): number {
    // this.country, this.city 사용
  }
}
```

---

### 3.2 Move Field (필드 이동)

**동기:** 필드를 더 적절한 위치로

**Before:**
```typescript
interface Customer {
  name: string;
  discountRate: number;  // 실제로는 계약 관련
}

interface CustomerContract {
  startDate: Date;
}
```

**After:**
```typescript
interface Customer {
  name: string;
  contract: CustomerContract;
}

interface CustomerContract {
  startDate: Date;
  discountRate: number;
}
```

---

### 3.3 Split Phase (단계 쪼개기)

**동기:** 서로 다른 두 가지 일을 하는 코드 분리

**Before:**
```typescript
function priceOrder(product: Product, quantity: number, shippingMethod: ShippingMethod) {
  const basePrice = product.basePrice * quantity;
  const discount = Math.max(quantity - 500, 0) * product.basePrice * 0.05;
  const shippingPerCase = (basePrice > 1000) 
    ? shippingMethod.discountedFee 
    : shippingMethod.feePerCase;
  const shippingCost = quantity * shippingPerCase;
  const price = basePrice - discount + shippingCost;
  return price;
}
```

**After:**
```typescript
function priceOrder(product: Product, quantity: number, shippingMethod: ShippingMethod) {
  const priceData = calculatePricingData(product, quantity);
  return applyShipping(priceData, shippingMethod);
}

function calculatePricingData(product: Product, quantity: number) {
  const basePrice = product.basePrice * quantity;
  const discount = Math.max(quantity - 500, 0) * product.basePrice * 0.05;
  return { basePrice, quantity, discount };
}

function applyShipping(priceData: PriceData, shippingMethod: ShippingMethod) {
  const shippingPerCase = (priceData.basePrice > 1000) 
    ? shippingMethod.discountedFee 
    : shippingMethod.feePerCase;
  const shippingCost = priceData.quantity * shippingPerCase;
  return priceData.basePrice - priceData.discount + shippingCost;
}
```

---

## 4. 조건문 단순화 (Simplifying Conditionals)

### 4.1 Decompose Conditional (조건문 분해)

**Before:**
```typescript
if (date.isBefore(plan.summerStart) || date.isAfter(plan.summerEnd)) {
  charge = quantity * plan.winterRate + plan.winterServiceCharge;
} else {
  charge = quantity * plan.summerRate;
}
```

**After:**
```typescript
if (isSummer(date, plan)) {
  charge = summerCharge(quantity, plan);
} else {
  charge = winterCharge(quantity, plan);
}

function isSummer(date: Date, plan: Plan): boolean {
  return !date.isBefore(plan.summerStart) && !date.isAfter(plan.summerEnd);
}

function summerCharge(quantity: number, plan: Plan): number {
  return quantity * plan.summerRate;
}

function winterCharge(quantity: number, plan: Plan): number {
  return quantity * plan.winterRate + plan.winterServiceCharge;
}
```

---

### 4.2 Consolidate Conditional Expression (조건식 통합)

**Before:**
```typescript
function disabilityAmount(employee: Employee): number {
  if (employee.seniority < 2) return 0;
  if (employee.monthsDisabled > 12) return 0;
  if (employee.isPartTime) return 0;
  // 계산...
}
```

**After:**
```typescript
function disabilityAmount(employee: Employee): number {
  if (isNotEligibleForDisability(employee)) return 0;
  // 계산...
}

function isNotEligibleForDisability(employee: Employee): boolean {
  return employee.seniority < 2 
    || employee.monthsDisabled > 12 
    || employee.isPartTime;
}
```

---

### 4.3 Replace Conditional with Polymorphism (다형성으로 조건문 대체)

**Before:**
```typescript
function plumage(bird: Bird): string {
  switch (bird.type) {
    case 'EuropeanSwallow':
      return 'average';
    case 'AfricanSwallow':
      return bird.numberOfCoconuts > 2 ? 'tired' : 'average';
    case 'NorwegianBlueParrot':
      return bird.voltage > 100 ? 'scorched' : 'beautiful';
    default:
      return 'unknown';
  }
}
```

**After:**
```typescript
interface Bird {
  plumage(): string;
}

class EuropeanSwallow implements Bird {
  plumage() { return 'average'; }
}

class AfricanSwallow implements Bird {
  constructor(private numberOfCoconuts: number) {}
  plumage() { return this.numberOfCoconuts > 2 ? 'tired' : 'average'; }
}

class NorwegianBlueParrot implements Bird {
  constructor(private voltage: number) {}
  plumage() { return this.voltage > 100 ? 'scorched' : 'beautiful'; }
}
```

**React 컴포넌트 적용:**
```typescript
// Before: switch로 렌더링
function Notification({ type, message }) {
  switch (type) {
    case 'success': return <SuccessNotification message={message} />;
    case 'error': return <ErrorNotification message={message} />;
    case 'warning': return <WarningNotification message={message} />;
  }
}

// After: 컴포넌트 매핑
const NOTIFICATION_COMPONENTS = {
  success: SuccessNotification,
  error: ErrorNotification,
  warning: WarningNotification,
} as const;

function Notification({ type, message }: NotificationProps) {
  const Component = NOTIFICATION_COMPONENTS[type];
  return <Component message={message} />;
}
```

---

### 4.4 Replace Nested Conditional with Guard Clauses (중첩 조건문을 보호 구문으로)

**Before:**
```typescript
function getPayAmount(employee: Employee): number {
  let result: number;
  if (employee.isSeparated) {
    result = { amount: 0, reason: 'SEP' };
  } else {
    if (employee.isRetired) {
      result = { amount: 0, reason: 'RET' };
    } else {
      // 복잡한 계산...
      result = computeAmount();
    }
  }
  return result;
}
```

**After:**
```typescript
function getPayAmount(employee: Employee): number {
  if (employee.isSeparated) return { amount: 0, reason: 'SEP' };
  if (employee.isRetired) return { amount: 0, reason: 'RET' };
  
  return computeAmount();
}
```

---

## 5. API 리팩토링

### 5.1 Introduce Parameter Object (매개변수 객체 도입)

**Before:**
```typescript
function amountInvoiced(startDate: Date, endDate: Date) { ... }
function amountReceived(startDate: Date, endDate: Date) { ... }
function amountOverdue(startDate: Date, endDate: Date) { ... }
```

**After:**
```typescript
interface DateRange {
  start: Date;
  end: Date;
}

function amountInvoiced(range: DateRange) { ... }
function amountReceived(range: DateRange) { ... }
function amountOverdue(range: DateRange) { ... }
```

---

### 5.2 Remove Flag Argument (플래그 인수 제거)

**Before:**
```typescript
function setDimension(name: string, value: number, isMetric: boolean) {
  if (isMetric) {
    // 미터 단위 처리
  } else {
    // 인치 단위 처리
  }
}

// 호출부
setDimension('height', 180, true);
setDimension('width', 72, false);  // true? false?
```

**After:**
```typescript
function setDimensionInMetric(name: string, value: number) { ... }
function setDimensionInInches(name: string, value: number) { ... }

// 호출부
setDimensionInMetric('height', 180);
setDimensionInInches('width', 72);
```

---

### 5.3 Preserve Whole Object (객체 통째로 넘기기)

**Before:**
```typescript
const low = room.daysTempRange.low;
const high = room.daysTempRange.high;
if (plan.withinRange(low, high)) { ... }
```

**After:**
```typescript
if (plan.withinRange(room.daysTempRange)) { ... }
```

---

## 적용 우선순위

### 1순위: 가독성 개선 (저위험)
- Rename Variable/Function
- Extract Variable
- Decompose Conditional

### 2순위: 중복 제거 (중위험)
- Extract Function
- Extract Class
- Pull Up Method

### 3순위: 구조 개선 (고위험)
- Move Function
- Split Phase
- Replace Conditional with Polymorphism
