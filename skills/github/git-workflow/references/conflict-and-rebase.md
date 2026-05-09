# Conflict Resolution & Rebase

## Pull strategy — `--rebase` por default

```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
```

Resultado: `git pull` rebasea tus commits locales sobre el remoto en lugar de generar un merge commit.

**Por qué:** historia linear, sin merge commits ruidosos como *"Merge branch 'main' of github..."*.

## Rebase rules — la única regla que importa

> **Rebase es seguro SOLO en commits que NUNCA fueron pusheados a una branch compartida.**

| Situación | Rebase | Por qué |
|---|---|---|
| Commits locales aún no pusheados | OK | Solo vos los tenés |
| Branch personal pusheada SOLO por vos | OK | `--force-with-lease` para actualizar |
| Branch compartida con otros devs | **NUNCA** | Reescribís historia que otros tienen |
| `main` / `master` / `develop` | **NUNCA JAMÁS** | History Bomb garantizada |
| PR ya con review en marcha | Evitar | Los comentarios pierden anclaje al diff |

## History Bomb — el incidente clásico

> Dos devs trabajan en `feat/checkout`. Dev A hace `git push --force` después de un rebase. Dev B intenta pushear sus commits, recibe rechazo, hace `git pull` (rebase auto), entra en conflict hell. **3 horas de trabajo de B perdidas** porque pushea encima sin entender qué pasó.

**Cómo evitarla:**
1. **`git push --force-with-lease`** en lugar de `--force` — falla si alguien pusheó después que vos. Mejor que nada, pero todavía rompe la branch para quien tenía commits locales.
2. **Branch protection en GitHub:** "Block force pushes" en `main` y branches con PR abierto.
3. **Comunicación:** si DEBES rebasear una branch compartida, avisar **antes** en el canal del equipo. Confirmar que nadie tiene commits locales encima.
4. **Para PRs en review:** preferir merge commits con `main` (un solo merge commit al final, antes del squash en merge) sobre rebase.

## Cómo rebasear correctamente — branch personal

```bash
# Estás en feat/x, querés actualizar contra main

git fetch origin                  # nunca asumas que tu local main está al día
git rebase origin/main            # NO uses 'git rebase main' si no pulleaste
# Si hay conflicts:
#   1. Editás los archivos
#   2. git add <archivos>
#   3. git rebase --continue
# Si te trabás:
#   git rebase --abort   (vuelve al estado anterior)

git push --force-with-lease origin feat/x   # solo si la rama es tuya
```

## Conflict resolution — flujo

### 1. Detectar

Después de `git pull --rebase` o `git rebase`:

```
CONFLICT (content): Merge conflict in apps/web/checkout.tsx
error: could not apply abc1234... feat(checkout): add coupon
```

### 2. Inspeccionar

```bash
git status                              # qué archivos están en conflict
git diff                                # ver los conflicts
```

En el archivo:

```
<<<<<<< HEAD (current — lo que viene de la rama base)
const total = subtotal + tax;
=======
const total = subtotal + tax - discount;
>>>>>>> abc1234 (your commit — lo tuyo)
```

### 3. Resolver

**No uses `--theirs` / `--ours` por default** — leé el código de ambos lados, decidí qué tiene sentido.

```bash
# Editás el archivo a mano
# Borrás los markers <<<<<<<, =======, >>>>>>>
# Quedás con la versión final correcta

git add apps/web/checkout.tsx
git rebase --continue                    # si rebase
# o
git commit                               # si merge
```

### 4. Verificar antes de pushear

```bash
git diff origin/main..HEAD               # ¿lo que voy a pushear es lo que esperaba?
bun test                                 # tests pasan
bun run typecheck                        # tipos pasan
```

### 5. Si te perdés — `git rerere`

Activar reuse-recorded-resolution una vez:

```bash
git config --global rerere.enabled true
```

Git recuerda cómo resolviste un conflict y lo aplica auto si reaparece (común al rebasear varias veces).

## Cuándo rebase, cuándo merge

| Operación | Estrategia |
|---|---|
| Actualizar feature branch contra main (rama personal) | `rebase` |
| Actualizar feature branch contra main (rama compartida) | `merge` |
| Mergear PR a main | `squash` (default) o `rebase` (si commits cohesivos) |
| Sync de fork con upstream | `rebase` |
| Hotfix back-port a release branch | `cherry-pick` (no rebase ni merge) |

## Recovery de force push catastrófico — `git reflog`

Si alguien hizo `git push --force` y perdió commits:

```bash
git reflog                               # ve TODOS los movimientos del HEAD local
# Busca el commit perdido
# Ejemplo output:
# abc1234 HEAD@{5}: commit: feat(checkout): add coupon
# def5678 HEAD@{6}: rebase: aborted

git checkout abc1234                     # te movés al commit perdido
git switch -c rescue/feat-x              # creás branch nueva desde ahí
git push -u origin rescue/feat-x         # subís
```

`reflog` solo guarda los últimos 90 días por default. Si pasa más, los commits son irrecuperables.

## Cherry-pick — cuándo usar

Cuando querés UN commit puntual de otra branch sin traer todo:

```bash
git checkout main
git cherry-pick abc1234                  # trae el commit abc1234

# Si conflict:
#   resolvés
#   git cherry-pick --continue
```

Casos:
- Hotfix que aplicaste en `hotfix/x`, querés en `release/2.5` también
- Bugfix en una feature branch que necesitás en main mientras la feature todavía no está lista
- Recovery de commits perdidos por reflog

## Stash — guardar trabajo a medias

Cuando necesitás cambiar de branch pero tenés cambios sin commitear:

```bash
git stash push -m "wip checkout coupon"  # guarda con mensaje
git checkout main                         # ahora podés cambiar
# ... hacés lo que tenías que hacer ...
git checkout feat/x
git stash pop                             # recupera

# Listar:
git stash list

# Mostrar uno:
git stash show -p stash@{0}

# Limpiar:
git stash drop stash@{0}
```

**Anti-pattern:** dejar 20 stashes acumulados. Si tenés > 5, tenés deuda — commiteá WIP a tu branch personal o `git stash drop` lo viejo.

## Bisect — encontrar regression

Cuando "hace X días andaba, ahora no":

```bash
git bisect start
git bisect bad                           # HEAD está roto
git bisect good v1.5.0                   # v1.5.0 estaba OK

# Git te checkea un commit intermedio. Probás.
git bisect good     # o bad, según resultado

# Repetir hasta que git diga: "abc1234 is the first bad commit"

git bisect reset                         # vuelve a HEAD original
```

Funciona MUY bien si los commits respetan Conventional Commits (cada uno es atomic). Funciona PÉSIMO con Garbage Commits.

## Recovery — comandos seguros

| Querés... | Comando |
|---|---|
| Deshacer último commit, mantener cambios staged | `git reset --soft HEAD~1` |
| Deshacer último commit, mantener cambios unstaged | `git reset HEAD~1` |
| Deshacer último commit, **descartar cambios** | `git reset --hard HEAD~1` (solo si no pusheaste) |
| Deshacer un commit ya pusheado | `git revert <sha>` (genera commit nuevo, no reescribe) |
| Recuperar archivo borrado | `git checkout HEAD -- <path>` |
| Ver historia de un archivo | `git log --follow -p <path>` |
| ¿Quién tocó esta línea? | `git blame <path>` o `gh blame` |
