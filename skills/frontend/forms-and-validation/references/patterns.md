# Forms — Code Reference

Copy-paste templates for the most common form scenarios.

## 1. Install

```bash
pnpm add react-hook-form zod @hookform/resolvers
```

## 2. Shared Schema Pattern

```ts
// schemas/signup.ts
import { z } from "zod";

export const signupSchema = z.object({
  email: z.string().email("Enter a valid email"),
  password: z
    .string()
    .min(12, "At least 12 characters")
    .regex(/[A-Z]/, "At least one uppercase letter")
    .regex(/[0-9]/, "At least one number"),
  name: z.string().min(1, "Required").max(100),
});

export type SignupInput = z.infer<typeof signupSchema>;
```

## 3. Complete Signup Form (branded ui)

```tsx
"use client";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { signupSchema, type SignupInput } from "@/schemas/signup";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { FormError } from "@/components/ui/form-error";
import { Stack } from "@/components/layout/stack";

export function SignupForm() {
  const form = useForm<SignupInput>({
    resolver: zodResolver(signupSchema),
    mode: "onTouched",
  });

  const onSubmit = form.handleSubmit(async (data) => {
    const res = await fetch("/api/signup", {
      method: "POST",
      body: JSON.stringify(data),
      headers: { "Content-Type": "application/json" },
    });
    if (!res.ok) {
      const { errors } = await res.json();
      for (const [field, messages] of Object.entries(errors.fieldErrors ?? {})) {
        form.setError(field as keyof SignupInput, { message: (messages as string[])[0] });
      }
      return;
    }
    window.location.href = "/dashboard";
  });

  return (
    <form onSubmit={onSubmit} noValidate>
      <Stack gap={4}>
        <Field label="Name" error={form.formState.errors.name?.message}>
          <Input {...form.register("name")} autoComplete="name" />
        </Field>
        <Field label="Email" error={form.formState.errors.email?.message}>
          <Input type="email" {...form.register("email")} autoComplete="email" />
        </Field>
        <Field label="Password" error={form.formState.errors.password?.message}>
          <Input type="password" {...form.register("password")} autoComplete="new-password" />
        </Field>
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Creating account…" : "Create account"}
        </Button>
      </Stack>
    </form>
  );
}

function Field({ label, error, children }: {
  label: string;
  error?: string;
  children: React.ReactElement;
}) {
  const id = useId();
  const errorId = `${id}-error`;
  return (
    <div>
      <Label htmlFor={id}>{label}</Label>
      {cloneElement(children, {
        id,
        "aria-invalid": !!error,
        "aria-describedby": error ? errorId : undefined,
      })}
      {error && (
        <p id={errorId} role="alert" className="mt-1 text-sm text-destructive">
          {error}
        </p>
      )}
    </div>
  );
}
```

## 4. Multi-Step Wizard

```tsx
const STEPS = [
  { title: "Account", fields: ["email", "password"] },
  { title: "Profile", fields: ["name", "company"] },
  { title: "Review",  fields: [] },
] as const;

export function SignupWizard() {
  const form = useForm<SignupInput>({
    resolver: zodResolver(signupSchema),
    mode: "onTouched",
    shouldUnregister: false,
  });
  const [step, setStep] = useState(0);

  const next = async () => {
    const valid = await form.trigger(STEPS[step].fields as any);
    if (valid) setStep(s => s + 1);
  };

  const onSubmit = form.handleSubmit(async (data) => { /* ... */ });

  return (
    <form onSubmit={onSubmit}>
      <ProgressBar current={step} total={STEPS.length} />
      {step === 0 && <AccountStep form={form} />}
      {step === 1 && <ProfileStep form={form} />}
      {step === 2 && <ReviewStep data={form.getValues()} />}
      <Row gap={2} justify="between">
        <Button type="button" variant="ghost" onClick={() => setStep(s => s - 1)} disabled={step === 0}>
          Back
        </Button>
        {step < STEPS.length - 1 ? (
          <Button type="button" onClick={next}>Continue</Button>
        ) : (
          <Button type="submit" disabled={form.formState.isSubmitting}>Finish</Button>
        )}
      </Row>
    </form>
  );
}
```

## 5. Async Field Validation (TanStack Query)

```tsx
const username = form.watch("username");
const debounced = useDebounce(username, 400);

const { data, isFetching } = useQuery({
  queryKey: ["username-available", debounced],
  queryFn: () => fetch(`/api/username/check?u=${debounced}`).then(r => r.json()),
  enabled: debounced?.length >= 3,
});

useEffect(() => {
  if (data && !data.available) {
    form.setError("username", { message: "Already taken" });
  } else if (data?.available) {
    form.clearErrors("username");
  }
}, [data, form]);
```

## 6. File Upload with Progress

```tsx
const fileSchema = z.custom<File>()
  .refine(f => f instanceof File, "Required")
  .refine(f => f.size <= 5 * 1024 * 1024, "Max 5MB")
  .refine(f => ["image/png", "image/jpeg"].includes(f.type), "PNG or JPEG only");

function uploadWithProgress(file: File, onProgress: (p: number) => void) {
  return new Promise<{ url: string }>((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.upload.onprogress = e => e.lengthComputable && onProgress((e.loaded / e.total) * 100);
    xhr.onload = () => xhr.status < 400 ? resolve(JSON.parse(xhr.responseText)) : reject();
    xhr.onerror = () => reject();
    xhr.open("POST", "/api/upload");
    const fd = new FormData();
    fd.append("file", file);
    xhr.send(fd);
  });
}
```

## 7. Field Array (invoice line items)

```tsx
const { fields, append, remove, move } = useFieldArray({
  control: form.control,
  name: "lineItems",
});

<Stack gap={3}>
  {fields.map((field, i) => (
    <Row key={field.id} gap={2}>
      <Input {...form.register(`lineItems.${i}.description`)} placeholder="Description" />
      <Input type="number" {...form.register(`lineItems.${i}.qty`, { valueAsNumber: true })} />
      <Input type="number" {...form.register(`lineItems.${i}.price`, { valueAsNumber: true })} />
      <Button type="button" variant="ghost" size="icon" onClick={() => remove(i)}>
        <Trash className="size-4" />
      </Button>
    </Row>
  ))}
  <Button type="button" variant="outline" onClick={() => append({ description: "", qty: 1, price: 0 })}>
    Add line
  </Button>
</Stack>
```

## 8. Server Action Pattern (Next.js)

```ts
// app/signup/action.ts
"use server";
import { signupSchema } from "@/schemas/signup";
import { redirect } from "next/navigation";

export type SignupState =
  | { ok: true }
  | { ok: false; errors: Record<string, string[]>; values?: Record<string, string> };

export async function signupAction(_: SignupState | null, formData: FormData): Promise<SignupState> {
  const raw = Object.fromEntries(formData);
  const parsed = signupSchema.safeParse(raw);
  if (!parsed.success) {
    return {
      ok: false,
      errors: parsed.error.flatten().fieldErrors,
      values: raw as Record<string, string>, // preserve user input
    };
  }
  // ... create user, sign them in ...
  redirect("/dashboard");
}
```

```tsx
// app/signup/form.tsx
"use client";
import { useActionState } from "react";
import { signupAction } from "./action";

export function SignupForm() {
  const [state, formAction, isPending] = useActionState(signupAction, null);

  return (
    <form action={formAction}>
      <Input name="email" defaultValue={state?.ok === false ? state.values?.email : ""} />
      {state?.ok === false && state.errors.email && (
        <p role="alert" className="text-sm text-destructive">{state.errors.email[0]}</p>
      )}
      {/* ... */}
      <Button type="submit" disabled={isPending}>Create account</Button>
    </form>
  );
}
```

## 9. Error Mapping Helper

```ts
// lib/map-server-errors.ts
import type { UseFormSetError, FieldValues, Path } from "react-hook-form";

export function mapServerErrors<T extends FieldValues>(
  errors: Record<string, string[]>,
  setError: UseFormSetError<T>,
) {
  for (const [field, messages] of Object.entries(errors)) {
    setError(field as Path<T>, { message: messages[0] });
  }
}
```

## 10. Custom Hook — `useFocusFirstError`

```ts
export function useFocusFirstError<T extends FieldValues>(form: UseFormReturn<T>) {
  useEffect(() => {
    const errors = form.formState.errors;
    const firstErrorField = Object.keys(errors)[0];
    if (firstErrorField) {
      const el = document.querySelector<HTMLElement>(`[name="${firstErrorField}"]`);
      el?.focus();
      el?.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }, [form.formState.submitCount, form.formState.errors]);
}
```
