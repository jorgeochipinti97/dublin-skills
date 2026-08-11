# Tasks — __PROJECT__

Shared backlog (versioned). Private personal tasks go in `TASKS.<you>.local.md`
(gitignored). Prefix client items with the client name: `- [ ] [acme] …`.

## Client pains
<!-- What the client is complaining about — the "why" behind the work. -->

## Backlog

<!-- Ordenado por: desbloquea a otros → impacto → esfuerzo. -->

### Desbloquea todo lo demás
- [ ] Correrla y mirarla: `pnpm ios` y `pnpm web` — bundlear no prueba que funcione
- [ ] Definir qué hace esta app (sin esto no se puede priorizar nada más)
- [ ] Definir `ios.bundleIdentifier` y `android.package` — inmutables tras la primera submission
- [ ] Cuenta Apple Developer (USD 99/año) y Play Console (USD 25) — una sola vez para todas las apps; la aprobación de Apple demora
- [ ] Dev build en un celular físico (iOS y Android) — Expo Go no es tu app

### Producto
- [ ] Conectar la API real: `EXPO_PUBLIC_API_URL` + borrar el bloque `FIXTURES` de `src/api/articles.ts`
- [ ] Si hay login: que el backend acepte token vía header `Authorization` para nativo, además de la cookie httpOnly de web
- [ ] Iconos: `icon.png` 1024×1024 sin transparencia + adaptive icon Android
- [ ] Splash con variante dark (si no, flashea blanco antes de montar)

### Web (target de primera clase)
- [ ] Abrir el build web en un browser y revisar consola
- [ ] Nav en viewport ancho: la tab bar abajo es patrón mobile; en desktop va top nav o sidebar
- [ ] Deploy del export estático al VPS (`try_files $uri $uri.html …`, si no un refresh en ruta profunda tira 404)

### Antes de publicar
- [ ] Permission usage strings en `infoPlist` — un texto vago es rechazo automático de Apple
- [ ] URL de política de privacidad + formularios de data safety (Apple y Google, por separado)
- [ ] Sentry con source maps, verificado en un build de preview
- [ ] Checklist de device de `references/testing-on-device.md` en cada pantalla

## Doing

## Done
- [x] Scaffold con `mobile-app-foundation` — Expo, tres targets bundlean

## Future / ideas
- [ ] MMKV en lugar de AsyncStorage para preferencias (más rápido; requiere dev build)
- [ ] Universal links (`https://…` abriendo la app) — retrofitear implica reemitir builds
- [ ] Push notifications
- [ ] E2E con Maestro sobre los 2-3 flujos críticos
