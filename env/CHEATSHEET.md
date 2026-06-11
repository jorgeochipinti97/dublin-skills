# Cheatsheet — How to use this environment

Talk to Claude in plain language. There are almost no commands to memorize — the
skills, rules, Tech Lead behavior, and memory activate on their own.

---

## 🇪🇸 Español

### Instalar (una vez)
```bash
git clone git@github.com:jorgeochipinti97/dublin-skills.git && cd dublin-skills
./install.sh new ~/mi-proyecto      # proyecto nuevo de cero
./install.sh install ~/mi-proyecto     # proyecto que ya existe
brew install gentleman-programming/tap/engram   # 1 vez por máquina (memoria)
```
Después abrís Claude Code **dentro de tu proyecto** y listo.

### Cómo le hablás (sin comandos)
| Querés… | Decí algo como |
|---|---|
| Construir | `"armá el login con email y password"` |
| Forzar plan (grande) | `"sdd new checkout"` |
| Criterio de arquitecto | `"@dublin-agent ¿cómo encaro el multi-tenancy?"` |
| Estado de todo (daily) | `"daily"` / `"status of all projects"` |
| Estado de uno | `"how's troll-center going?"` |
| Anotar tarea (equipo) | `"add task to lacito: stories IG para fernando gray"` |
| Anotar tarea (tuya) | `"add task for me: revisar el deploy"` |
| Ver lo tuyo | `"my tasks"` / `"what's pending for me"` |
| Cerrar tarea | `"mark the auth refactor as done"` |

### ¿Grande o chica? (test de 1 pregunta)
**¿Te dolería tirar lo que hiciste?** No → chica, directo. Sí → grande, SDD.

| | Chica (directo) | Grande (SDD) |
|---|---|---|
| Archivos | 1–2 | ≥ 3 o cruza módulos |
| ¿Sabés el cómo? | sí | no, hay que diseñarlo |
| Arquitectura | no | sí |
| Ejemplos | bug conocido, copy, un campo | feature, refactor, pagos, auth |

No lo decidís vos: el agente clasifica y te propone SDD si es grande.

### Pasa solo (no lo disparás)
- **Guard:** frena `DROP` / force-push y te pide el protocolo
- **engram:** guarda las decisiones del proyecto
- **Contexto:** al terminar, tacha la tarea + actualiza `SESSION.md`

### Regla de oro
Hablá normal. Solo recordá: `sdd new <x>` para lo grande, `"daily"` / `"add task"` para ordenarte. El resto se dispara solo.

---

## 🇬🇧 English

### Install (once)
```bash
git clone git@github.com:jorgeochipinti97/dublin-skills.git && cd dublin-skills
./install.sh new ~/my-project       # new project from scratch
./install.sh install ~/my-project      # existing project
brew install gentleman-programming/tap/engram   # once per machine (memory)
```
Then open Claude Code **inside your project**.

### How you talk to it (no commands)
| You want to… | Say something like |
|---|---|
| Build | `"build the login with email and password"` |
| Force planning (big) | `"sdd new checkout"` |
| Architect judgment | `"@dublin-agent how should I approach multi-tenancy?"` |
| Status of everything | `"daily"` / `"status of all projects"` |
| Status of one | `"how's troll-center going?"` |
| Add task (team) | `"add task to lacito: IG stories for acme"` |
| Add task (yours) | `"add task for me: review the deploy"` |
| See yours | `"my tasks"` / `"what's pending for me"` |
| Close a task | `"mark the auth refactor as done"` |

### Big or small? (one-question test)
**Would it hurt to throw away what you built?** No → small, go direct. Yes →
big, use SDD.

| | Small (direct) | Big (SDD) |
|---|---|---|
| Files | 1–2 | ≥ 3 or crosses modules |
| Know the how? | yes | no, needs design |
| Architecture | no | yes |
| Examples | known bug, copy, one field | feature, refactor, payments, auth |

You don't decide it — the agent classifies and proposes SDD when it's big.

### Happens on its own (you don't trigger it)
- **Guard:** blocks `DROP` / force-push and asks for the protocol
- **engram:** saves the project's decisions
- **Context:** when done, ticks the task + updates `SESSION.md`

### Golden rule
Talk normally. Just remember: `sdd new <x>` for big work, `"daily"` / `"add task"`
to stay organized. Everything else triggers itself.
