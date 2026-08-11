---
name: guard-rollout
description: Rollout gradual de un control transversal sobre un sistema que ya está en producción — autorización, rate limit, validación, feature flag de seguridad. Usar cuando el control cubre muchas rutas de una y prenderlo de golpe puede dejar afuera a usuarios legítimos. Define el par observe/enforce, exige que el criterio del flip sea MEDIBLE y que la medición se verifique antes de confiar en ella, y obliga a que volver atrás no dependa de un deploy. Se combina con change-safety (el checklist previo a tocar prod), auth-architect (el diseño del control) e infra-security (auditoría).
---

# Guard Rollout

Un control de seguridad que cubre 150 rutas y se prende de golpe tiene dos
finales posibles: cierra el agujero, o le corta el acceso a los usuarios reales
en pleno día de trabajo. Esta skill es para que el primero sea el único.

No trata de **cómo diseñar** el control —eso es `auth-architect`— sino de cómo
**encenderlo** sin romper lo que funciona.

## Cuándo se activa

- Un guard, middleware o interceptor **global** que toca muchas rutas de una vez
- Autorización, multi-tenancy, rate limiting, validación de firma, CSRF
- Cualquier chequeo nuevo sobre un sistema **con usuarios adentro**
- Un feature flag que cambia quién puede hacer qué

Si el control cubre una sola ruta y la escribiste vos hoy, no hace falta:
prendelo y listo. Esto es para lo transversal.

---

## 1. Los dos modos

```
observe  → detecta la violación, la registra, y DEJA PASAR el request
enforce  → detecta la violación y la BLOQUEA
```

El control se deploya en `observe`, se lo mira contra tráfico real, y recién
después se flipea a `enforce`.

### El default durante el rollout es `observe`, y es deliberado

Es lo contrario de lo que uno elige para un control de seguridad, y hay que
escribir el porqué al lado del código:

```ts
/**
 * OJO — el default es `observe`, NO `enforce`.
 *
 * Es un estado TRANSITORIO de una semana, no el estado final. Este guard nació
 * cubriendo 140 rutas y se deploya directo a producción sin staging: un deploy
 * al que se le olvide la variable NO puede cortarle el acceso a los usuarios
 * de golpe. Un valor con typo (`enfoce`) cae en `observe` por el mismo motivo.
 *
 * Cuando el flip esté hecho y estable, INVERTIR este default para que el
 * fail-safe pase a ser el seguro en vez del permisivo.
 */
```

Sin ese comentario, en tres meses nadie sabe si el `observe` es una decisión o
un olvido — y queda para siempre.

---

## 2. No todo control tiene modo `observe`

**Esta es la distinción que más se pasa por alto.** Antes de armar los dos modos,
preguntar qué hace el control:

| Si el control… | ¿tiene modo observe? |
|---|---|
| **Rechaza** un pedido inválido (403 a un id ajeno) | **Sí** — se puede loguear y dejar pasar |
| **Acota** el alcance de una consulta (filtrar un listado) | **No** |

Un listado que no filtra **es** la filtración. "Observar" ahí significa devolver
los datos ajenos y después anotar que estuvo mal: el daño ya está hecho cuando
se escribe el log.

Lo mismo con cualquier control que **redacta, enmascara o acota**: no hay
versión pasiva. Se aplica siempre, desde el primer deploy.

La consecuencia práctica: un mismo PR puede tener una parte con modos y otra
sin ellos. Está bien — lo que no está bien es forzar `observe` sobre algo que
no puede observarse sin filtrar.

### Y el modo `observe` deja un hueco mientras corre

Si el guard está en `observe`, un id ajeno se loguea **pero pasa**. Cualquier
consulta que dependa de que el guard haya rechazado va a recibir el valor malo
igual. Por eso las capas que acotan tienen que **intersectar** con lo permitido
en vez de confiar en el guard:

```ts
// Mal: confía en que el guard rechazó lo ajeno.
where.establishmentId = filtros.establishmentId;

// Bien: intersecta. En `observe` el id ajeno pasó el guard, y acá igual da cero filas.
where.establishmentId = scopedFilter(permitidos, filtros.establishmentId);
```

---

## 3. El criterio del flip tiene que ser medible — y la medición, verificada

"Lo prendemos cuando estemos tranquilos" no es un criterio. Un criterio es:

> Cero violaciones registradas en N días de uso real.

Y ahí viene lo que arruina el rollout: **la medición suele estar rota y nadie lo
chequea, porque un contador en cero se lee como buena noticia.**

### Verificar el contador contra un caso conocido

Antes de confiar en el número, provocar una violación a propósito (en dev) y
confirmar que **el contador sube**. Un contador que siempre da cero no
distingue "no hay violaciones" de "no estoy contando nada".

### Trampa: el mensaje de arranque contaminando el conteo

Caso real. El guard loguea su modo al iniciar:

```
[TenantGuard] [OBSERVE] modo activo
```

Y el contador hacía:

```bash
docker logs api | grep -c '[OBSERVE]'        # ← cuenta el arranque
```

Con **cero** violaciones reales el número daba **1**. Leído literal, el criterio
decía "hay una violación, no flipees" — para siempre.

```bash
docker logs api | grep -c '[OBSERVE] acceso cross-establecimiento'   # ← el texto de la violación
```

**Regla: filtrar por el texto del evento, nunca por el tag del nivel.**

### Trampa: la ventana del log no es la que creés

```bash
docker logs api --since 24h | grep -c '...'
```

`docker logs` sólo tiene lo que vivió **el container actual**, y cada deploy lo
recrea. Con deploys diarios, ese "24h" puede ser en realidad "10 minutos". El
número da cero porque **no hubo tráfico**, no porque no haya violaciones.

Imprimir siempre la ventana real al lado del conteo:

```bash
echo "violaciones: $(docker logs api --since 24h | grep -cF 'TEXTO')"
echo "container arrancó: $(docker inspect -f '{{.State.StartedAt}}' api)"
echo "ahora:            $(date -u +%FT%TZ)"
```

Sin ese contexto, el conteo se lee como evidencia cuando no la hay.

### Si el criterio es inalcanzable, decirlo

Si cada deploy borra los logs, "N días limpios" no se acumula nunca. Las salidas
son: enviar los logs afuera del container, o **flipear asumiendo el riesgo y
dejarlo escrito**. Lo que no vale es fingir que se cumplió el criterio.

---

## 4. Un tag por fuente, y que un solo grep las junte

Si el control tiene varias entradas (un guard global + un chequeo manual donde
el guard no llega), **todas tienen que loguear con el mismo texto**. Si una usa
otro formato, el flip se decide mirando la mitad de las violaciones.

Al revés también importa: lo que **no** es una violación va con **otro** tag.
Un "falta declarar el mapeo de esta ruta" no puede contaminar el conteo que
habilita el flip — es una deuda de configuración, no un acceso indebido.

---

## 5. El flip no puede depender de un deploy

Volver atrás tiene que tomar segundos y no pasar por merge, build ni pipeline.
En la práctica: una variable de entorno + restart del proceso, disparado por un
workflow o un comando de una línea.

Y el que lo cambia tiene que **verificar contra el proceso, no contra el
archivo**:

```bash
# El .env puede estar perfecto mientras el proceso corre con el valor viejo
# porque el container no se recreó de verdad.
ACTIVE=$(docker logs api | grep -oE '\[(OBSERVE|ENFORCE)\] modo activo' | tail -1)
[ "$ACTIVE" = "$ESPERADO" ] || { restaurar_backup; exit 1; }
```

El control loguea su modo al arrancar **justamente para poder verificarlo desde
afuera** sin provocar una violación.

Checklist del mecanismo de flip:

- [ ] Backup del archivo de config antes de tocarlo
- [ ] Escribe la variable **y la agrega si no existía** (`sed -i` sólo reemplaza
      lo que ya está: sin ese `if`, diría "listo" sin haber cambiado nada)
- [ ] Fuerza el recreate (sin eso el container no relee el env)
- [ ] Verifica contra los logs del proceso
- [ ] **Restaura solo** si no coincide
- [ ] Chequea que la app siga respondiendo
- [ ] Queda auditado (workflow, no SSH a mano)

---

## 6. Al flipear

Decir la verdad sobre la evidencia. Si se prendió con dos horas de logs
nocturnos, **eso no es "los logs estaban limpios"**: es "no hubo tráfico".
Escribirlo en `TASKS.md` junto con el comando exacto de rollback.

El primer movimiento ante un reporte de "no puedo entrar a algo que antes veía"
es **volver a `observe`**, no investigar en caliente. Investigar se hace después,
con el acceso restablecido y los logs ya cargados de uso real.

Y ojo: **en `enforce` las violaciones se loguean con el otro tag**. El grep que
se venía usando deja de encontrar nada, y eso se lee como "no hay problemas".
Grepear los dos.

---

## Lo que esta skill NO es

- **No** reemplaza `change-safety`: eso es el checklist previo a cualquier
  escritura en prod (backup, rollback, ventana). Esto es específico del
  encendido de un control transversal.
- **No** diseña el control. Qué validar y contra qué es `auth-architect`.
- **No** aplica a features. Un feature a medias se ve; un control de seguridad
  a medias **no se ve** — pasa de largo en silencio, y ese es todo el problema.
