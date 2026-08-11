# Session notes — __PROJECT__

Lightweight continuity log. Caps: ~300 lines, prune stale entries.

Last updated: __DATE__

---

## Current state

**App multiplataforma** — iOS + Android + web desde una sola base de código. React Native + Expo, scaffoldeada con la skill `mobile-app-foundation`.

```bash
pnpm start      # Metro + QR (Expo Go — solo para mirar layout)
pnpm ios        # simulador iOS
pnpm android    # emulador Android
pnpm web        # browser
```

Web deploya como export estático (`expo export --platform web`) → VPS con nginx, sin Node server.

**Estado funcional:** feed → detalle → guardados, corriendo contra fixtures locales. Todavía **sin backend**: setear `EXPO_PUBLIC_API_URL` y borrar el bloque `FIXTURES` al final de `src/api/articles.ts`.

**Contrato de diseño:** `DESIGN.md` en la raíz — fuente de verdad cuando el código y la intención discrepan.

### Sin definir todavía
- `ios.bundleIdentifier` / `android.package` — **inmutables** tras la primera submission
- Qué hace realmente esta app

### Reglas que la rompen si se ignoran
- Nunca editar versiones de paquetes nativos a mano → `npx expo install <pkg>`
- No borrar `.npmrc` (`node-linker=hoisted`) — Metro no sigue los symlinks de pnpm; sin eso el bundle falla y `tsc` igual pasa en verde
- Nunca `Alert.alert` ni `expo-secure-store` directo → usar `src/lib/notify.ts` y `src/lib/session-storage.ts`. En web el primero es un no-op silencioso y el segundo no tiene implementación. Ninguno rompe el build
- Nunca espejar el token nativo en `localStorage` "para que sea simétrico" — convierte un secreto de Keychain en uno legible por XSS. En web la sesión va en cookie httpOnly
- Un `eas update` (OTA) llega a todos los devices instalados sin review de por medio → aplica `change-safety`

---

## Log

- __DATE__ — proyecto scaffoldeado con `mobile-app-foundation`.
  **Próximo:** correrla (`pnpm ios` / `pnpm web`), definir bundle identifier + package, conectar la API real.
  **Bloqueantes:** cuenta de Apple Developer (USD 99/año, la aprobación demora días) — bloquea cualquier build de iOS fuera del simulador. Se comparte entre todas las apps de la cuenta, así que se paga y se espera una sola vez.
