# mobile-app-foundation

## Activation Prompts

```
Necesito arrancar una app mobile y nunca toqué React Native
```

```
Dame un boilerplate de Expo para una app de contenido
```

```
Quiero subir esta app a la App Store y a Play Store, ¿qué me falta?
```

```
¿Expo o React Native bare? ¿Managed o bare workflow?
```

```
La app funciona en Expo Go pero rompe en el build
```

```
El feed se traba cuando scrolleo, tengo 300 items
```

```
Sin conexión la app queda con el spinner para siempre
```

```
El contenido queda abajo del notch / arriba del home indicator
```

```
Cómo mando un update sin pasar por review de la store
```

```
Me rechazaron la app en App Store Connect
```

```
Revisá esta pantalla de React Native antes de que la dé por terminada
```

```
Esto tiene que ser multiplataforma: iOS, Android y web
```

```
Deployar el build web en el VPS con nginx
```

```
En el celular anda pero en web no pasa nada al tocar el botón
```

## Example Use Cases

- Web developer shipping their first native app — needs the whole path, not just the code
- Scaffolding a content/reading app (feed → detail → saved) that must work offline
- Deciding between Expo managed, bare React Native, Capacitor over an existing web app, or Flutter
- A feed that stutters because it renders inside a `ScrollView` with `.map()` (ScrollView Graveyard)
- An app that shows an infinite spinner with no connection (Offline Amnesia)
- Content rendering under the notch or behind the home indicator (Notch Blind)
- Code written with `<div>` / `onClick` / `position: fixed` that silently no-ops (Web Brain)
- Red screen after hand-editing React Native versions in `package.json` (Version Roulette)
- App Store rejection over missing or vague permission usage strings (Store Surprise)
- Planning the release path: bundle identifiers, credentials, EAS profiles, TestFlight, Play internal testing
- Setting up OTA updates and understanding what OTA can and cannot ship
- Deciding what to test on a simulator vs what demands a real device
- Adding dark + light theme to an app that only shipped light
- Migrating an app from Expo Go to a dev build after adding a native dependency

## Pairs With

- `mobile-design` — thumb zones, bottom sheets, and pattern picks translate directly to native
- `forms-and-validation` — React Hook Form + Zod work unchanged in React Native
- `auth-architect` — sessions and token rotation, with `expo-secure-store` as the token store
- `change-safety` — an OTA update is a production write with no review gate between you and every installed device
- `api-architect` — the mobile client is a first-class API consumer with different latency and offline constraints
