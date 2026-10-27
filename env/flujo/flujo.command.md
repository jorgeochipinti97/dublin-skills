---
description: Corre un flujo de cerebros (ds panel → Flujos). Uso: /flujo <nombre> [proyecto…] [+cerebro] [: indicación]
argument-hint: <flujo> [proyecto…] [+cerebro] [: indicación libre]
allowed-tools: Bash(ds flujo:*)
---

!`ds flujo "$ARGUMENTS"`

Si arriba hay pasos de un flujo, seguilos tal cual. Si hay una lista de flujos o un error, mostrásela al usuario y preguntale cuál quiere correr.
