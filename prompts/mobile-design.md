# mobile-design

## Activation Prompts

```
El frontend se ve bien en desktop pero en mobile se sale de pantalla
```

```
Necesito mobile UX distinta de desktop, no responsive nada más
```

```
Tengo horizontal scroll en mobile y no sé de dónde viene
```

```
Pasar de modal centrado a bottom sheet en mobile
```

```
Auditar thumb zones y touch targets de la app
```

```
Configurar inputs para que no haga zoom iOS al focusear
```

```
Reemplazar la sidebar por bottom tab bar en mobile
```

## Example Use Cases

- The hero / landing page looks polished on desktop but breaks at 360px (overflow, type too big, CTAs unreachable)
- A SaaS dashboard with a sidebar nav that becomes useless on mobile — needs a real bottom tab bar
- Modal-heavy app that needs to swap to bottom sheets and full-screen sheets on mobile
- E-commerce PDP with no sticky bottom CTA, conversion is leaking
- Onboarding flow that feels desktop-first — multi-step wizard horizontal instead of one-screen-per-step
- iOS Safari layout breaking because of `100vh` on hero
- iOS auto-zoom fires on every form because inputs have `text-sm`
- Filter panel as a desktop sidebar on mobile — needs filter button → bottom sheet
- Lists that need swipe-to-archive / swipe-to-delete on mobile (inbox / tasks / notifications)
- Buttons too small to tap, primary CTA in top-right corner
- Long words / URLs / hashes pushing the layout wider than the viewport
- Headlines that overflow on 360px because they use `text-7xl` without `clamp()`

## Invoke After

`frontend-foundation` — Pillar 4 owns the baseline mobile-first rules. `mobile-design` extends them with mobile-as-its-own-medium and the overflow killers.

## Invoke Before

`premium-frontend-design` — polish goes on top of a mobile-correct layout. Polish a Shrunk Desktop and you get a polished broken UI.

`frontend-output-validator` — runs as the gate after `mobile-design` to confirm overflow, touch targets, viewport meta, safe-area, and forbidden patterns are all clean.
