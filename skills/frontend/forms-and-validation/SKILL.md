---
name: forms-and-validation
description: Build production-grade forms in React/Next.js with React Hook Form + Zod. Use for any form — login, signup, checkout, multi-step wizards, settings, dynamic field arrays, file upload, async validation (username available, VAT valid). Covers accessibility (labels, errors, aria-live), error UX, server-side validation mirroring, optimistic updates, and Server Actions integration. Pairs with frontend-foundation (Input/Select primitives) and auth-architect (signup/login forms).
---

# Forms and Validation

A form is not "an Input plus a Button". It's validation + error UX + submission + accessibility + server mirroring. Get any one wrong and the form is broken.

## Stack

- **React Hook Form** (`react-hook-form`) — performance (uncontrolled inputs, no re-render on every keystroke)
- **Zod** — single schema for client + server validation
- **@hookform/resolvers/zod** — glue between them
- Server Actions (Next.js) or NestJS controllers for submission

**Do NOT use Formik** (deprecated, slow) or raw `useState` per field (re-render hell).

## The One Golden Rule

**Validate on the server even if you validated on the client.** Client validation is UX. Server validation is security. Share the schema.

```ts
// schemas/signup.ts — shared
import { z } from "zod";

export const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12).regex(/[A-Z]/).regex(/[0-9]/),
  name: z.string().min(1).max(100),
});

export type SignupInput = z.infer<typeof signupSchema>;
```

```ts
// client — components/signup-form.tsx
const form = useForm<SignupInput>({ resolver: zodResolver(signupSchema) });

// server — app/api/signup/route.ts
const parsed = signupSchema.safeParse(await req.json());
if (!parsed.success) return Response.json({ errors: parsed.error.flatten() }, { status: 422 });
```

Same schema, two contexts. That's the whole game.

## Error UX Principles

This section covers the FORM-side of errors (how to render them in the UI). For the server-side error taxonomy, Problem Details (RFC 7807), logging, correlation IDs, and retry policy, see `skills/implementation/error-handling` — this skill consumes what error-handling produces and just maps server errors onto fields.

1. **Inline + below field**, not toast
2. **After blur, not on every keystroke** — `mode: "onTouched"`
3. **Red border + icon + message** (not just color — a11y)
4. **`aria-invalid` + `aria-describedby`** pointing to error node
5. **`aria-live="polite"` region** for async/server errors
6. **Focus the first invalid field** on submit attempt
7. **Submit button disabled only while submitting**, NOT while invalid (blocks users from seeing what's wrong)
8. **Server errors mapped to fields** — the API returns Problem Details with a `fieldErrors` shape (see error-handling); this skill's job is to call `form.setError(field, { message })` for each

## Multi-step Wizard Pattern

```tsx
const form = useForm<WholeFormData>({
  resolver: zodResolver(wholeSchema),
  mode: "onTouched",
  shouldUnregister: false,  // keep data across steps
});

const [step, setStep] = useState(0);

async function next() {
  const fieldsThisStep = stepFields[step];
  const valid = await form.trigger(fieldsThisStep);
  if (valid) setStep(s => s + 1);
}
```

Persist progress in **URL state** (`?step=2`) so back button works, or in `localStorage` keyed by form ID for recovery after crash.

## Async Validation (username available, etc.)

```tsx
const { watch, setError, clearErrors } = form;
const username = watch("username");

useEffect(() => {
  if (!username || username.length < 3) return;
  const t = setTimeout(async () => {
    const res = await fetch(`/api/username/check?u=${username}`);
    const { available } = await res.json();
    if (!available) setError("username", { message: "Already taken" });
    else clearErrors("username");
  }, 400); // debounce
  return () => clearTimeout(t);
}, [username, setError, clearErrors]);
```

For production: use TanStack Query's `useQuery` with `enabled` and debounce instead of raw useEffect.

## Server Actions Integration (Next.js)

```tsx
// app/signup/action.ts
"use server";
import { signupSchema } from "@/schemas/signup";

export async function signupAction(prevState: unknown, formData: FormData) {
  const parsed = signupSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    return { ok: false, errors: parsed.error.flatten().fieldErrors };
  }
  // ... create user ...
  redirect("/dashboard");
}

// component
const [state, action, isPending] = useActionState(signupAction, null);
```

RHF + Server Actions: use `form.handleSubmit` to run client validation, then call the action. Server errors come back in `state.errors` — map them to fields with `form.setError`.

## File Upload

- **Validate size + MIME on client** (fail fast UX) AND on server (security)
- **Accept attribute**: `<input type="file" accept="image/png,image/jpeg" />`
- **Show progress**: XHR has progress events, fetch doesn't — use XHR or a library (TUS, UppyJS)
- **Direct-to-S3 / R2** via presigned URLs for files > 5MB — don't bottleneck your server

```ts
const fileSchema = z.custom<File>()
  .refine(f => f instanceof File, "Required")
  .refine(f => f.size <= 5 * 1024 * 1024, "Max 5MB")
  .refine(f => ["image/png", "image/jpeg"].includes(f.type), "PNG or JPEG only");
```

## Dynamic Field Arrays

```tsx
const { fields, append, remove } = useFieldArray({ control: form.control, name: "items" });

{fields.map((field, i) => (
  <div key={field.id}>
    <Input {...form.register(`items.${i}.name`)} />
    <Button onClick={() => remove(i)}>Remove</Button>
  </div>
))}
<Button onClick={() => append({ name: "" })}>Add</Button>
```

## Accessibility Checklist (every form)

- [ ] Every input has a `<label htmlFor={id}>` (not just placeholder)
- [ ] `required` inputs have `aria-required="true"`
- [ ] Errors: `aria-invalid="true"` + `aria-describedby="field-error"` on input
- [ ] Error container: `id="field-error"` + `role="alert"` or `aria-live="polite"`
- [ ] Submit button has clear label (not "Submit" — "Create account")
- [ ] Focus moves to first invalid field on submit failure
- [ ] Form is navigable by keyboard only (Tab order correct, Enter submits)
- [ ] Color is not the only error indicator (icon + text)
- [ ] Password field: `autocomplete="new-password"` or `"current-password"`
- [ ] Autofill hints: `autocomplete="email"`, `"name"`, `"tel"`, etc.

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| `useState` per field | RHF uncontrolled + register |
| Validating on every keystroke | `mode: "onTouched"` |
| Disabling submit when invalid | Enable, validate on submit, show errors |
| Only client validation | Mirror schema on server, parse with Zod |
| Placeholder as label | Real `<label>` element |
| Toast-only errors | Inline + below field |
| Resetting form on server error | Preserve input, show error, let user fix |
| Submitting on Enter inside textarea | `onKeyDown` → don't submit if textarea |
| Regex for email | `z.string().email()` — regex is wrong |
| Custom date picker without a11y | Use React Aria DatePicker or Base UI |

## Output Standards

- Always share schema between client and server
- Include full error UX (aria-invalid, aria-live, focus management)
- Use the branded `<Input>` / `<Select>` from `components/ui/`
- Show loading + disabled + error + success states

## Reference Files

- `references/patterns.md` — Complete form templates (signup, multi-step wizard, file upload, field arrays, server action integration), Zod recipes, error mapping helpers

## Pairs With

- `error-handling` — server error taxonomy, Problem Details, correlation IDs (consumed by this skill's field-mapping logic)
- `frontend-foundation` — `<Input>`, `<Select>`, `<Textarea>` primitives this skill composes
- `auth-architect` — signup/login form requirements
