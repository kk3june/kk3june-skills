# Clean Code 원칙

> 출처: Robert C. Martin "Clean Code"

---

## 의미 있는 이름

### 의도를 분명히 밝혀라

```typescript
// 나쁨
const d = 86400;
const list1 = users.filter(u => u.s === 'A');

// 좋음
const SECONDS_IN_DAY = 86400;
const activeUsers = users.filter(user => user.status === 'ACTIVE');
```

### 그릇된 정보를 피하라

```typescript
// 나쁨 - 실제 List가 아닌데 List라고 명명
const accountList = new Set<Account>();

// 좋음
const accounts = new Set<Account>();
const accountGroup = new Set<Account>();
```

### 의미 있게 구분하라

```typescript
// 나쁨 - 불용어(noise word) 사용
function getActiveAccountInfo() {}
function getActiveAccountData() {}

// 좋음
function getActiveAccount() {}
```

### 발음하기 쉬운 이름

```typescript
// 나쁨
const genymdhms = new Date();
const modymdhms = new Date();

// 좋음
const generationTimestamp = new Date();
const modificationTimestamp = new Date();
```

### 검색하기 쉬운 이름

```typescript
// 나쁨 - 매직 넘버
if (user.type === 5) {}

// 좋음
const ADMIN_USER_TYPE = 5;
if (user.type === ADMIN_USER_TYPE) {}
```

### 클래스/컴포넌트 이름

```markdown
- 명사나 명사구 사용: User, Account, AddressParser
- Manager, Processor, Data, Info 같은 불용어 피하기
- 동사 사용 금지
```

### 메서드/함수 이름

```markdown
- 동사나 동사구 사용: getUser, deleteAccount, save
- 접근자: get + 명사
- 변경자: set + 명사
- 조건자: is, has, can + 형용사/명사
```

---

## 함수

### 작게 만들어라

```typescript
// 나쁨 - 너무 긴 함수
function processOrder(order: Order) {
  // 검증 로직 20줄
  // 할인 계산 30줄
  // 재고 확인 25줄
  // 결제 처리 40줄
  // 알림 발송 15줄
}

// 좋음 - 작은 함수들로 분리
function processOrder(order: Order) {
  validateOrder(order);
  const discount = calculateDiscount(order);
  checkInventory(order);
  processPayment(order, discount);
  sendNotification(order);
}
```

### 한 가지만 해라

```markdown
함수는 한 가지를 해야 한다.
그 한 가지를 잘 해야 한다.
그 한 가지만을 해야 한다.
```

### 함수 당 추상화 수준은 하나로

```typescript
// 나쁨 - 추상화 수준이 섞임
function renderPage(page: Page) {
  const html = page.getHtml();              // 높은 추상화
  const encoding = 'UTF-8';                  // 낮은 추상화
  document.write(`<html>${html}</html>`);   // 중간 추상화
}

// 좋음 - 같은 추상화 수준
function renderPage(page: Page) {
  const html = buildPageHtml(page);
  const output = formatOutput(html);
  writeToDom(output);
}
```

### 서술적인 이름 사용

```typescript
// 나쁨
function calc(a: number, b: number) {}

// 좋음
function calculateMonthlyInterest(principal: number, rate: number) {}
```

### 함수 인수

```markdown
이상적인 인수 개수:
- 0개 (niladic): 가장 좋음
- 1개 (monadic): 좋음
- 2개 (dyadic): 괜찮음
- 3개 (triadic): 피할 것
- 4개 이상: 특별한 이유 필요
```

```typescript
// 나쁨 - 인수가 많음
function createUser(name: string, email: string, age: number, role: string) {}

// 좋음 - 객체로 묶기
interface CreateUserDto {
  name: string;
  email: string;
  age: number;
  role: string;
}
function createUser(dto: CreateUserDto) {}
```

### 부수 효과를 일으키지 마라

```typescript
// 나쁨 - 이름과 다른 부수 효과
function checkPassword(userName: string, password: string): boolean {
  const user = UserGateway.findByName(userName);
  if (user) {
    if (user.password === encrypt(password)) {
      Session.initialize();  // 부수 효과!
      return true;
    }
  }
  return false;
}

// 좋음 - 명확한 이름 또는 분리
function checkPasswordAndInitializeSession(userName: string, password: string) {
  if (checkPassword(userName, password)) {
    initializeSession();
  }
}
```

### 명령과 조회를 분리하라

```typescript
// 나쁨 - 명령과 조회가 혼합
function set(attribute: string, value: string): boolean {
  // 값을 설정하고 성공 여부를 반환
}

// 혼란스러운 사용
if (set('username', 'bob')) {}

// 좋음 - 분리
function attributeExists(attribute: string): boolean {}
function setAttribute(attribute: string, value: string): void {}

// 명확한 사용
if (attributeExists('username')) {
  setAttribute('username', 'bob');
}
```

---

## 주석

### 주석은 나쁜 코드를 보완하지 못한다

```typescript
// 나쁨 - 주석으로 나쁜 코드 설명
// 직원에게 복지 혜택을 받을 자격이 있는지 검사
if ((e.flags & HOURLY_FLAG) && (e.age > 65)) {}

// 좋음 - 코드로 표현
if (employee.isEligibleForBenefits()) {}
```

### 좋은 주석

```typescript
// 법적인 주석
// Copyright (c) 2024 Company. All rights reserved.

// 정보를 제공하는 주석
// 형식: kk:mm:ss EEE, MMM dd, yyyy
const timeMatcher = /\d{2}:\d{2}:\d{2} \w+, \w+ \d+, \d{4}/;

// 의도를 설명하는 주석
// 스레드를 많이 생성하여 경쟁 조건을 만든다
for (let i = 0; i < 25000; i++) {
  new Thread(widgetBuilder).start();
}

// 결과를 경고하는 주석
// 여유 시간이 충분하지 않다면 실행하지 마세요
function testWithReallyBigFile() {}

// TODO 주석
// TODO: 현재 필요 없지만 언젠가 필요할 것
function makeVersion() {}
```

### 나쁜 주석

```typescript
// 주절거리는 주석
// 이 함수는 어쩌고 저쩌고...

// 같은 이야기 반복
// 월을 반환한다
function getMonth(): number {}

// 있으나 마나한 주석
// 기본 생성자
constructor() {}

// 무서운 잡음
/** The name. */
private name: string;
/** The version. */
private version: string;

// 닫는 괄호에 다는 주석
try {
  // ...
} // try
catch {
  // ...
} // catch

// 주석 처리된 코드
// this.bytePos = writeBytes(pos);
// this.bytePos = pos;
```

---

## 포맷팅

### 적절한 행 길이

```markdown
- 200줄 미만이 좋음
- 대부분의 함수: 20줄 이하
- 파일 길이가 길면 클래스/모듈 분리 고려
```

### 개념은 빈 행으로 분리

```typescript
// 좋음 - 개념 분리
import { something } from 'somewhere';

const CONSTANT = 'value';

interface Props {
  name: string;
}

function Component({ name }: Props) {
  return <div>{name}</div>;
}

export default Component;
```

### 세로 밀집도

```typescript
// 나쁨 - 불필요한 주석으로 분리
/**
 * 사용자 이름
 */
private name: string;

/**
 * 사용자 이메일
 */
private email: string;

// 좋음 - 연관된 코드는 가까이
private name: string;
private email: string;
```

### 변수 선언

```markdown
- 변수는 사용하는 위치에 최대한 가까이
- 인스턴스 변수는 클래스 맨 처음에 선언
- 루프 제어 변수는 루프 문 내부에
```

### 가로 길이

```markdown
- 80~120자 권장
- 스크롤이 필요 없는 길이
```

---

## 객체와 자료 구조

### 자료 추상화

```typescript
// 구체적 - 구현을 외부에 노출
class Point {
  public x: number;
  public y: number;
}

// 추상적 - 구현을 숨김
interface Point {
  getX(): number;
  getY(): number;
  setCartesian(x: number, y: number): void;
  setPolar(r: number, theta: number): void;
}
```

### 자료/객체 비대칭

```markdown
객체:
- 추상화 뒤로 자료를 숨김
- 자료를 다루는 함수만 공개
- 새 객체 타입 추가 쉬움
- 새 함수 추가 어려움

자료 구조:
- 자료를 그대로 공개
- 별다른 함수 없음
- 새 함수 추가 쉬움
- 새 자료 타입 추가 어려움
```

### 디미터 법칙

```typescript
// 나쁨 - 기차 충돌 (Train Wreck)
const outputDir = ctxt.getOptions().getScratchDir().getAbsolutePath();

// 좋음 - 하나씩 호출
const opts = ctxt.getOptions();
const scratchDir = opts.getScratchDir();
const outputDir = scratchDir.getAbsolutePath();

// 더 좋음 - 필요한 것만 요청
const outputDir = ctxt.getOutputDirectory();
```

---

## 오류 처리

### 오류 코드보다 예외 사용

```typescript
// 나쁨 - 오류 코드
function deletePage(page: Page): number {
  if (deletePage(page) === E_OK) {
    if (configKeys.deleteKey(page.name) === E_OK) {
      return E_OK;
    } else {
      return E_ERROR;
    }
  }
  return E_ERROR;
}

// 좋음 - 예외
function deletePage(page: Page): void {
  try {
    deletePageAndAllReferences(page);
  } catch (e) {
    logError(e);
  }
}
```

### Try-Catch-Finally 문부터 작성

```typescript
function retrieveSection(selector: string): string[] {
  try {
    const section = findSection(selector);
    return section.getContent();
  } catch (e) {
    if (e instanceof SectionNotFoundException) {
      return [];
    }
    throw e;
  }
}
```

### null을 반환하지 마라

```typescript
// 나쁨
function getUsers(): User[] | null {
  // ...
}
const users = getUsers();
if (users !== null) {
  for (const user of users) {}
}

// 좋음
function getUsers(): User[] {
  // ...
  return [];  // 빈 배열 반환
}
const users = getUsers();
for (const user of users) {}
```

### null을 전달하지 마라

```typescript
// 나쁨
function calculate(a: number, b: number | null): number {
  if (b === null) {
    throw new Error('b cannot be null');
  }
  return a + b;
}

// 좋음 - 타입으로 방지
function calculate(a: number, b: number): number {
  return a + b;
}
```
