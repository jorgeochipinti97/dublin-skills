---
name: presskit
description: "Crea y mantiene el PRESSKIT.md de una marca — el contrato de marca que todos los skills de contenido leen antes de producir. Incluye: rutas a archivos de assets (logos, colores, tipografías, video de intro/outro, avatar/presenter, música aprobada), reglas de voz y tono calibradas para video, QUÉ SÍ / QUÉ NO de contenido, restricciones por plataforma, y compliance legal. Alimenta directamente el Filtro de Guión de video-creativo. Usar al iniciar cualquier proyecto de contenido para una marca. También diagnostica y actualiza un PRESSKIT.md existente."
---

# Presskit

Crea el `PRESSKIT.md` de una marca — el documento de referencia central que todos los skills de contenido consultan antes de producir cualquier output.

El PRESSKIT.md no es un documento para clientes. Es un archivo de configuración de marca que el equipo de contenido (humano o IA) lee antes de escribir un guión, buscar un gancho, o configurar un avatar. Su valor está en ser específico, actualizado, y en el repositorio donde vive el trabajo.

---

## Hard Rules

1. **PRESSKIT.md vive en la raíz del proyecto** — no en una carpeta, no en Drive. Tiene que ser accesible desde el mismo lugar donde están los skills.
2. **Las rutas de assets son relativas al proyecto** — no absolutas (las absolutas rompen cuando cambia de máquina o se clona el repo).
3. **Solo assets que existen van con ruta** — si el archivo no existe todavía, marcarlo como `⚠️ PENDIENTE: crear`.
4. **Las reglas de contenido son específicas** — no "hablar con confianza" sino "como alguien que muestra algo que le cambió el trabajo, no como alguien que vende".
5. **Versionar** — cada cambio al PRESSKIT.md incrementa la versión y lo registra en §8.
6. **Nunca auto-inventar claims, cifras, o rutas** — si no se sabe, poner `⚠️ CONFIRMAR`.

---

## Modos de Uso

### Modo A — Crear desde cero
La marca no tiene PRESSKIT.md. Recopilar información y crear el archivo completo.

### Modo B — Actualizar existente
Ya existe un PRESSKIT.md. Diagnosticar qué secciones están desactualizadas, incompletas, o faltantes. Proponer los cambios. Aplicar con aprobación.

### Modo C — Auditoría de assets
Verificar que los archivos en las rutas del PRESSKIT.md realmente existen. Marcar los faltantes.

---

## Contexto Requerido (Modo A — Crear desde cero)

Preguntar en un solo bloque. No drip de preguntas.

**Mínimo para empezar:**

1. **Nombre oficial de la marca** y variantes/abreviaturas
2. **Posicionamiento** — en una oración: para quién, qué hace, qué la diferencia
3. **Assets existentes** — ¿hay logos? ¿en qué formatos? ¿dónde están actualmente?
4. **Colores de marca** — si los tienen definidos (HEX o descripción)
5. **Tono** — describir cómo suena la marca. ¿Tienen ejemplos de contenido que ya les gusta?
6. **Plataformas activas** — Instagram / TikTok / YouTube / LinkedIn / otro
7. **Restricciones conocidas** — ¿hay algo que la marca nunca puede decir o hacer?
8. **Tiene presentador / avatar?** — ¿Hay una cara de la marca? ¿Usan avatar de IA?
9. **Compliance especial** — ¿sector regulado? (salud, finanzas, alimentos, legal)

**Si el usuario dice "completá lo que falte":** proceder con ⚠️ en cada campo desconocido.

---

## Flujo de Trabajo

### Modo A — Crear desde cero

1. Recopilar contexto (preguntas de arriba)
2. Cargar `references/presskit-template.md`
3. Completar el template con la información recibida — cada campo desconocido: `⚠️ PENDIENTE: [descripción de qué falta]`
4. Proponer estructura de carpetas de assets (§2 del template) adaptada al proyecto real
5. Producir el `PRESSKIT.md` completo
6. Listar al final: assets existentes que hay que mover a las rutas correctas, assets que hay que crear

### Modo B — Actualizar existente

1. Leer el PRESSKIT.md actual
2. Identificar:
   - Secciones vacías o incompletas
   - Información desactualizada (versión, fechas, plataformas)
   - Reglas de contenido demasiado vagas para ser útiles
   - Rutas de assets que pueden no existir
3. Listar los problemas con su severidad (🔴 crítico / 🟡 importante / 🟢 mejora)
4. Proponer las actualizaciones — aplicar con confirmación del usuario

### Modo C — Auditoría de assets

1. Leer las rutas en §2 del PRESSKIT.md
2. Verificar con herramientas de filesystem que cada ruta existe
3. Producir un reporte: ✅ existe / ❌ no existe / ⚠️ existe pero formato incorrecto
4. Para los ❌: sugerir acción (crear / renombrar / conseguir de cliente)

---

## Output

### PRESSKIT.md (Modo A)

El archivo completo siguiendo el template de `references/presskit-template.md`. Adaptado al proyecto:
- Remover secciones del template que no aplican (ej: si no tienen TikTok, sacar §5 TikTok)
- Expandir secciones que el cliente tiene más desarrolladas
- Mantener la estructura de §7 (integración con skills) siempre — es lo que hace el archivo funcional

### Reporte de Diagnóstico (Modo B)

```markdown
## Diagnóstico PRESSKIT.md — [Marca] — [Fecha]

**Versión actual**: X.X

### Problemas encontrados

🔴 CRÍTICO
- §[N]: [descripción del problema] → [acción recomendada]

🟡 IMPORTANTE
- §[N]: [descripción]

🟢 MEJORA
- §[N]: [descripción]

### Cambios propuestos
[Lista de cambios específicos con antes/después]

### Assets pendientes de verificación
[Lista de rutas no confirmadas]
```

### Reporte de Assets (Modo C)

```markdown
## Auditoría de Assets — [Marca] — [Fecha]

| Ruta | Estado | Acción |
|---|---|---|
| assets/brand/logos/logo-principal.svg | ✅ existe | — |
| assets/brand/logos/logo-dark.svg | ❌ no existe | Crear o conseguir del cliente |
| assets/brand/video/intro/intro-3s.mp4 | ⚠️ formato incorrecto (.mov) | Convertir a .mp4 |
```

---

## Integración con el Pipeline de Contenido

El PRESSKIT.md es el input de marca para todos los skills:

```
PRESSKIT.md
    ↓ lee §3 (Voz), §4 (Reglas), §5 (Plataforma)
gancho-argumental → valida que el gancho no viola reglas de marca
    ↓
video-creativo / FILTRO DE GUIÓN:
    - QUÉ SÍ ← §4 Claims aprobados + §3 Tono
    - QUÉ NO ← §4 Prohibiciones + §6 Compliance
    - TONO ← §3 Tono calibrado para video
    - PALABRAS PROHIBIDAS ← §4 + Filler Word Index
    - PALABRAS CLAVE ← §4 Terminología de marca
    ↓
ai-avatar-director → lee §2 Presenter (foto, voz, avatar ID)
ugc-video-prompting → lee §2 Video assets (b-roll, colores)
ugc-post-production → lee §2 Intro/outro, música + §5 Hashtags
```

**Regla**: cualquier skill que produce contenido para una marca lee el PRESSKIT.md antes de empezar. Si no existe el PRESSKIT.md, crear uno antes de producir contenido.

---

## Cuándo Actualizar el PRESSKIT.md

- Cambio de identidad visual (logo, colores, tipografía)
- Cambio de posicionamiento o tagline
- Nuevas plataformas activadas o desactivadas
- Nuevos assets de producción (nuevo intro, nueva música, nuevo avatar)
- Cambios en reglas de compliance
- Cambio de presentador o voz de marca
- Después de cualquier crisis de marca (actualizar QUÉ NO)

**Regla práctica**: si alguien del equipo tiene que preguntar "¿podemos decir X?" o "¿dónde está el logo?", el PRESSKIT.md está desactualizado.

---

## Anti-Patrones

- **PRESSKIT.md en Google Drive / Notion / Confluence** (no en el repo) — los skills no pueden leerlo; pierde su función de configuración
- **Rutas absolutas** (`/Users/jorge/Desktop/marca/logos/`) — se rompen en cualquier otra máquina
- **Tono demasiado vago** ("somos cercanos y profesionales") — no le dice nada al modelo ni al equipo
- **Sin sección de QUÉ NO** — el QUÉ NO es igual de importante que el QUÉ SÍ
- **Sin versioning** — imposible saber si lo que se lee está actualizado
- **Rutas que no existen** — un PRESSKIT.md con rutas rotas es peor que no tenerlo (da falsa seguridad)
- **Claims no verificados sin marcar** — si no tenemos fuente para un claim, marcarlo ⚠️ o no ponerlo

---

## Reference Loading

- `references/presskit-template.md` — template completo de PRESSKIT.md con todas las secciones, campos, estructura de carpetas de assets, y tabla de integración con skills (cargar siempre — es el formato de referencia)
