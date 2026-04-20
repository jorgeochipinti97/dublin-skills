# Testing Patterns — Code Reference

Ready-to-use setups and templates.

## 1. Vitest Setup (TS project)

```bash
pnpm add -D vitest @vitest/coverage-v8 @testing-library/react @testing-library/user-event @testing-library/jest-dom jsdom
```

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    environment: "jsdom",
    setupFiles: ["./test/setup.ts"],
    globals: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      exclude: ["**/*.config.ts", "**/*.d.ts", "test/**"],
      thresholds: { lines: 80, functions: 80, branches: 75 },
    },
  },
});
```

```ts
// test/setup.ts
import "@testing-library/jest-dom/vitest";
import { afterEach } from "vitest";
import { cleanup } from "@testing-library/react";

afterEach(() => cleanup());
```

## 2. In-Memory Repository (fake) for Use Case Tests

```ts
// test/fakes/in-memory-user-repo.ts
import type { UserRepository, User } from "@/domain";

export class InMemoryUserRepo implements UserRepository {
  private store = new Map<string, User>();

  async save(user: User) { this.store.set(user.id, user); return user; }
  async findById(id: string) { return this.store.get(id) ?? null; }
  async findByEmail(email: string) {
    return [...this.store.values()].find(u => u.email === email) ?? null;
  }
  async delete(id: string) { this.store.delete(id); }

  // test helpers
  _clear() { this.store.clear(); }
  _all() { return [...this.store.values()]; }
}
```

```ts
// use case test with fake
test("CreateUser creates and returns user", async () => {
  const repo = new InMemoryUserRepo();
  const hasher = { hash: async (p: string) => `hashed-${p}` };
  const useCase = new CreateUserUseCase(repo, hasher);

  const user = await useCase.execute({ email: "a@b.com", password: "pw12345678" });

  expect(user.email).toBe("a@b.com");
  expect(await repo.findByEmail("a@b.com")).not.toBeNull();
});
```

## 3. Testcontainers — Real Postgres Integration

```bash
pnpm add -D @testcontainers/postgresql
```

```ts
// test/integration/user-repo.integration.test.ts
import { PostgreSqlContainer, StartedPostgreSqlContainer } from "@testcontainers/postgresql";
import { beforeAll, afterAll, beforeEach, test, expect } from "vitest";
import { PrismaClient } from "@prisma/client";
import { execSync } from "child_process";
import { PrismaUserRepo } from "@/infrastructure/prisma-user-repo";

let container: StartedPostgreSqlContainer;
let prisma: PrismaClient;
let repo: PrismaUserRepo;

beforeAll(async () => {
  container = await new PostgreSqlContainer("postgres:16-alpine").start();
  const url = container.getConnectionUri();
  process.env.DATABASE_URL = url;
  execSync(`DATABASE_URL=${url} pnpm prisma migrate deploy`, { stdio: "inherit" });
  prisma = new PrismaClient({ datasources: { db: { url } } });
  repo = new PrismaUserRepo(prisma);
}, 60_000);

afterAll(async () => {
  await prisma.$disconnect();
  await container.stop();
});

beforeEach(async () => {
  await prisma.user.deleteMany();
});

test("findByEmail returns the user", async () => {
  await prisma.user.create({ data: { email: "a@b.com", passwordHash: "x", name: "A" } });
  const user = await repo.findByEmail("a@b.com");
  expect(user?.email).toBe("a@b.com");
});
```

## 4. MSW (Mock Service Worker)

```bash
pnpm add -D msw
```

```ts
// test/mocks/handlers.ts
import { http, HttpResponse } from "msw";

export const handlers = [
  http.get("https://api.example.com/users/:id", ({ params }) => {
    return HttpResponse.json({ id: params.id, name: "Test" });
  }),
  http.post("https://api.example.com/users", async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: "new-id", ...body }, { status: 201 });
  }),
];
```

```ts
// test/setup.ts (add to existing)
import { setupServer } from "msw/node";
import { handlers } from "./mocks/handlers";

const server = setupServer(...handlers);
beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## 5. Testing Library — Component Test Pattern

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { SignupForm } from "./signup-form";

test("shows error on invalid email", async () => {
  const user = userEvent.setup();
  render(<SignupForm />);

  await user.type(screen.getByLabelText(/email/i), "not-an-email");
  await user.tab(); // trigger blur
  await user.click(screen.getByRole("button", { name: /create account/i }));

  expect(await screen.findByRole("alert")).toHaveTextContent(/valid email/i);
});

test("submits on valid input", async () => {
  const user = userEvent.setup();
  const onSubmit = vi.fn();
  render(<SignupForm onSubmit={onSubmit} />);

  await user.type(screen.getByLabelText(/email/i), "a@b.com");
  await user.type(screen.getByLabelText(/password/i), "SuperSecret123!");
  await user.type(screen.getByLabelText(/name/i), "Alice");
  await user.click(screen.getByRole("button", { name: /create account/i }));

  expect(onSubmit).toHaveBeenCalledWith({
    email: "a@b.com", password: "SuperSecret123!", name: "Alice",
  });
});
```

## 6. Playwright Setup

```bash
pnpm dlx create-playwright
```

```ts
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [["html"], ["list"]],
  use: {
    baseURL: process.env.BASE_URL ?? "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "webkit",   use: { ...devices["Desktop Safari"] } },
  ],
  webServer: {
    command: "pnpm build && pnpm start",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

## 7. Test Data Factories

```ts
// test/factories.ts
import { faker } from "@faker-js/faker";
import type { User, Order } from "@/domain";

export const makeUser = (overrides: Partial<User> = {}): User => ({
  id: crypto.randomUUID(),
  email: faker.internet.email().toLowerCase(),
  name: faker.person.fullName(),
  role: "USER",
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

export const makeOrder = (overrides: Partial<Order> = {}): Order => ({
  id: crypto.randomUUID(),
  userId: crypto.randomUUID(),
  status: "PENDING",
  total: faker.number.int({ min: 1000, max: 50000 }),
  items: [],
  createdAt: new Date(),
  ...overrides,
});
```

## 8. Pact Contract Test (consumer side)

```ts
// test/pact/user-service.pact.test.ts
import { Pact } from "@pact-foundation/pact";
import { UserApiClient } from "@/clients/user-api";

const provider = new Pact({
  consumer: "web-app",
  provider: "user-service",
  port: 8999,
});

beforeAll(() => provider.setup());
afterAll(() => provider.finalize());

test("GET /users/:id returns user", async () => {
  await provider.addInteraction({
    state: "a user 123 exists",
    uponReceiving: "a request for user 123",
    withRequest: { method: "GET", path: "/users/123" },
    willRespondWith: {
      status: 200,
      headers: { "Content-Type": "application/json" },
      body: { id: "123", name: "Alice" },
    },
  });

  const client = new UserApiClient("http://localhost:8999");
  const user = await client.getUser("123");
  expect(user).toEqual({ id: "123", name: "Alice" });
  await provider.verify();
});
```

## 9. CI — Running Tests in Order

```yaml
# .github/workflows/test.yml (fragment)
jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:unit

  integration:
    runs-on: ubuntu-latest
    needs: unit
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:integration  # uses testcontainers

  e2e:
    runs-on: ubuntu-latest
    needs: integration
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm dlx playwright install --with-deps chromium
      - run: pnpm test:e2e
```

Fast tests fail first, expensive tests run only when the pyramid below is green.
