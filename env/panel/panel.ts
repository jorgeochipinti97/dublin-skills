// `ds panel` — tu panel personal, local: proyectos + tareas, MCPs, finanzas, estudio y nutrición.
// Lee y escribe los mismos archivos de siempre (TASKS.md, finanzas.md) en cada
// request, así que nunca se desincroniza. Solo escucha en 127.0.0.1.
//
//   Proyectos  $DUBLIN_PROJECTS → ~/.config/dublin/projects-root
//   Finanzas   $DUBLIN_FINANZAS → <padre de proyectos>/finanzas.md
//              una línea por movimiento: "- 2026-10-23 -15000 super #comida"
import { existsSync, readFileSync, readdirSync, writeFileSync, appendFileSync, statSync, mkdirSync, statfsSync } from "node:fs";
import { join, dirname, basename } from "node:path";
import { homedir, totalmem } from "node:os";

const HOME = homedir();
const PORT = Number(process.env.PANEL_PORT ?? 4321);
const CONF_DIR = join(HOME, ".config/dublin");
const conf = (f: string) => { const p = join(CONF_DIR, f); return existsSync(p) ? readFileSync(p, "utf8").split("\n")[0].trim() : ""; };
const tilde = (p: string) => p.replace(/^~/, HOME);
const PROJECTS = tilde(process.env.DUBLIN_PROJECTS || conf("projects-root"));
const FINANZAS = tilde(process.env.DUBLIN_FINANZAS || (PROJECTS ? join(dirname(PROJECTS), "finanzas.md") : join(HOME, "finanzas.md")));
const MASCOTAS = tilde(process.env.DUBLIN_MASCOTAS || join(dirname(FINANZAS), "mascotas.md"));
const USER = (process.env.USER || "yo").toLowerCase();

const read = (p: string) => { try { return readFileSync(p, "utf8"); } catch { return ""; } };
const dirs = (root: string) => { try { return readdirSync(root, { withFileTypes: true }).filter(d => d.isDirectory() && !d.name.startsWith(".")).map(d => d.name).sort(); } catch { return []; } };
const today = () => new Date().toLocaleDateString("sv-SE");

// Proyectos: cada carpeta del root; si una carpeta no es un proyecto pero adentro tiene
// proyectos (ej. cliente/cliente-api), se listan esos como "cliente/cliente-api".
// Todo lo que está en _archivo/ se lista (aunque no sea repo) y cuenta como archivado.
const ARCHIVE_DIR = "_archivo";
const isProject = (dir: string) => ["SESSION.md", "session.md", "TASKS.md", ".git", "package.json"].some(f => existsSync(join(dir, f)));
function expandDir(rel: string, all: boolean): string[] {
  if (isProject(join(PROJECTS, rel))) return [rel];
  const inner = dirs(join(PROJECTS, rel)).filter(c => isProject(join(PROJECTS, rel, c)));
  return inner.length ? inner.map(c => `${rel}/${c}`) : all || !rel.includes("/") ? [rel] : [];
}
function projectDirs() {
  if (!PROJECTS) return [];
  return dirs(PROJECTS).flatMap(d => d === ARCHIVE_DIR
    ? dirs(join(PROJECTS, d)).flatMap(c => expandDir(`${d}/${c}`, true))
    : expandDir(d, false));
}

// ---- Tareas: bloques "- [ ] …" (+ líneas indentadas de continuación) por sección ----
const BUCKETS: [string, string][] = [["pains", "Client pains"], ["backlog", "Backlog"], ["doing", "Doing"], ["done", "Done"], ["ideas", "Future"]];
const HEADER: Record<string, string> = { pains: "Client pains", backlog: "Backlog", doing: "Doing", done: "Done", ideas: "Future / ideas" };
// "## Doing" o "## Future / ideas", pero no un párrafo que empiece con "## Doing`)…".
const isHeader = (line: string, name: string) => new RegExp(`^## ${name}(\\s|$)`).test(line);
const bucketOf = (line: string) => BUCKETS.find(([, name]) => isHeader(line, name))?.[0] ?? null;

type Item = { line: number; end: number; raw: string; done: boolean; text: string; bucket: string };
function parse(md: string, loose: boolean): Item[] {
  const lines = md.split("\n"), items: Item[] = [];
  let b: string | null = loose ? "backlog" : null; // los .local.md pueden tener ítems sin sección
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].startsWith("## ")) { b = bucketOf(lines[i]); continue; }
    const m = lines[i].match(/^- \[( |x|X)\] (.*)$/);
    if (!m || !b) continue;
    let j = i + 1; while (j < lines.length && /^\s+\S/.test(lines[j])) j++;
    const done = m[1] !== " ";
    items.push({ line: i, end: j, raw: lines.slice(i, j).join("\n"), done, bucket: done ? "done" : b,
      text: [m[2], ...lines.slice(i + 1, j).map(l => l.trim())].join(" ") });
    i = j - 1;
  }
  return items;
}

function insertInto(lines: string[], bucket: string, block: string[]) {
  const h = BUCKETS.find(([k]) => k === bucket)![1];
  let s = lines.findIndex(l => isHeader(l, h));
  if (s < 0) { while (lines.length && lines.at(-1) === "") lines.pop(); lines.push("", "## " + HEADER[bucket], ""); s = lines.length - 2; }
  let e = lines.findIndex((l, i) => i > s && l.startsWith("## ")); if (e < 0) e = lines.length;
  let k = e - 1; while (k > s && lines[k].trim() === "") k--;
  lines.splice(k + 1, 0, ...block);
}

function taskFile(project: string, scope: string) {
  const dir = join(PROJECTS, project);
  if (scope !== "mine") return join(dir, "TASKS.md");
  const found = readdirSync(dir).find(f => /^TASKS\..+\.local\.md$/.test(f));
  return join(dir, found ?? `TASKS.${USER}.local.md`);
}

// Los *.local.md (tareas privadas, ficha del cliente) nunca se commitean.
function ignoreLocal(dir: string) {
  const gi = join(dir, ".gitignore");
  if (!read(gi).split("\n").some(l => l.trim() === "*.local.md")) appendFileSync(gi, (read(gi) && !read(gi).endsWith("\n") ? "\n" : "") + "*.local.md\n");
}

function ensureFile(file: string, project: string, scope: string) {
  if (existsSync(file)) return;
  if (scope === "mine") {
    writeFileSync(file, `# Tasks — ${project} (mías)\n\n## Backlog\n\n## Doing\n\n## Done\n`);
    ignoreLocal(dirname(file));
  } else {
    writeFileSync(file, read(join(import.meta.dir, "../templates/TASKS.md")).replace(/__PROJECT__/g, project) || `# Tasks — ${project}\n`);
  }
}

function taskOp(b: any) {
  if (!projectDirs().includes(b.project)) throw new Error("Proyecto desconocido");
  const file = taskFile(b.project, b.scope);
  const clean = (t: string) => String(t ?? "").replace(/[\r\n]+/g, " ").trim();
  if (b.op === "add") {
    const text = clean(b.text); if (!text) throw new Error("Tarea vacía");
    ensureFile(file, b.project, b.scope);
    const lines = read(file).split("\n");
    insertInto(lines, b.bucket, [`- [${b.bucket === "done" ? "x" : " "}] ${text}`]);
    return writeFileSync(file, lines.join("\n"));
  }
  const lines = read(file).split("\n");
  const it = parse(lines.join("\n"), b.scope === "mine").find(i => i.line === b.line && i.raw === b.raw);
  if (!it) throw new Error("El archivo cambió — recargá");
  const block = lines.splice(it.line, it.end - it.line);
  if (b.op === "move") {
    block[0] = block[0].replace(/^- \[[ xX]\]/, b.to === "done" ? "- [x]" : "- [ ]");
    insertInto(lines, b.to, block);
  } else if (b.op === "edit") {
    const text = clean(b.text); if (!text) throw new Error("Tarea vacía");
    lines.splice(it.line, 0, block[0].replace(/^(- \[[ xX]\] ).*$/, `$1${text}`), ...block.slice(1));
  } else if (b.op !== "delete") throw new Error("Operación desconocida");
  writeFileSync(file, lines.join("\n"));
}

function projects() {
  return projectDirs().map(name => {
    const dir = join(PROJECTS, name), files = readdirSync(dir);
    const sf = files.find(f => f.toLowerCase() === "session.md");
    const session = sf ? read(join(dir, sf)) : "";
    let entry = ""; for (const l of session.split("\n")) if (/^- \d{4}-\d{2}-\d{2}/.test(l)) entry = l.slice(2);
    const day = entry.match(/\d{4}-\d{2}-\d{2}/)?.[0] ?? (sf ? statSync(join(dir, sf)).mtime.toLocaleDateString("sv-SE") : "");
    const mineFile = files.find(f => /^TASKS\..+\.local\.md$/.test(f));
    return { name, hasSession: !!sf, hasTasks: files.includes("TASKS.md"), day,
      entry: entry.replace(/^\d{4}-\d{2}-\d{2}\s*[—–·:-]?\s*/, ""),
      shared: parse(read(join(dir, "TASKS.md")), false).map(({ end, ...i }) => i),
      mine: mineFile ? parse(read(join(dir, mineFile)), true).map(({ end, ...i }) => i) : [] };
  }).sort((a, b) => b.day.localeCompare(a.day) || a.name.localeCompare(b.name));
}

// ---- MCPs: user scope + local scope (~/.claude.json) + .mcp.json de cada proyecto ----
function mcps() {
  const by = new Map<string, { where: Set<string>; cmd: string }>();
  const add = (server: string, where: string, cfg: any) => {
    if (!by.has(server)) by.set(server, { where: new Set(), cmd: cfg?.url ?? [cfg?.command, ...(cfg?.args ?? [])].filter(Boolean).join(" ") });
    by.get(server)!.where.add(where);
  };
  let cj: any = {}; try { cj = JSON.parse(read(join(HOME, ".claude.json")) || "{}"); } catch {}
  for (const [s, c] of Object.entries<any>(cj.mcpServers ?? {})) add(s, "global", c);
  for (const [p, v] of Object.entries<any>(cj.projects ?? {})) for (const [s, c] of Object.entries<any>(v.mcpServers ?? {})) add(s, basename(p), c);
  for (const name of projectDirs()) {
    try { for (const [s, c] of Object.entries<any>(JSON.parse(read(join(PROJECTS, name, ".mcp.json")) || "{}").mcpServers ?? {})) add(s, name, c); } catch {}
  }
  return [...by].map(([server, v]) => ({ server, cmd: v.cmd, where: [...v.where].sort() })).sort((a, b) => b.where.length - a.where.length);
}

// ---- Finanzas ----------------------------------------------------------------
const MOV = /^- (\d{4}-\d{2}-\d{2}) ([+-]?\d+(?:\.\d+)?) (.*?)(?: #(\S+))?\s*$/;
// finanzas.md: "## Objetivos" ("- Auto | meta 5000000 | ahorrado 1200000 | para 2027-06"),
// "## Presupuestos" ("- comida 300000") y "## Movimientos" (una línea por movimiento, al final).
const GOAL = /^- (.+?) \| meta (\d+(?:\.\d+)?) \| ahorrado (\d+(?:\.\d+)?)(?: \| para (\d{4}-\d{2}))?\s*$/;
const BUDGET = /^- (\S+) (\d+(?:\.\d+)?)\s*$/;
// "## Inversiones": "- Plazo fijo Galicia | plazo fijo | invertido 1000000 | actual 1050000 | ARS | vence 2026-11-30"
const INV = /^- (.+?) \| (.+?) \| invertido (\d+(?:\.\d+)?) \| actual (\d+(?:\.\d+)?) \| (ARS|USD)(?: \| vence (\d{4}-\d{2}-\d{2}))?\s*$/;
const num = (v: unknown) => Number(String(v ?? "").replace(/[^\d.,]/g, "").replace(/\.(?=\d{3}(\D|$))/g, "").replace(",", "."));

function finSection(lines: string[], name: string) {
  const s = lines.findIndex(l => l.trim() === "## " + name); if (s < 0) return null;
  let e = lines.findIndex((l, i) => i > s && l.startsWith("## ")); if (e < 0) e = lines.length;
  return [s, e];
}
// Garantiza Objetivos / Presupuestos arriba y Movimientos al final (donde se agregan los nuevos).
function finLines() {
  if (!existsSync(FINANZAS)) writeFileSync(FINANZAS, "# Finanzas\n\n<!-- Movimientos: - AAAA-MM-DD <monto, negativo = gasto> <descripción> #categoría -->\n");
  const lines = read(FINANZAS).split("\n");
  if (!finSection(lines, "Movimientos")) {
    const first = lines.findIndex(l => MOV.test(l));
    if (first < 0) { while (lines.length && lines.at(-1) === "") lines.pop(); lines.push("", "## Movimientos", ""); }
    else lines.splice(first, 0, "## Movimientos");
  }
  for (const name of ["Objetivos", "Presupuestos", "Inversiones"]) if (!finSection(lines, name)) {
    const mv = finSection(lines, "Movimientos")![0]; lines.splice(mv, 0, "## " + name, "");
  }
  return lines;
}
function finInsert(lines: string[], name: string, line: string) {
  const [s, e] = finSection(lines, name)!; let k = e - 1; while (k > s && lines[k].trim() === "") k--;
  lines.splice(k + 1, 0, line);
}

function finanzas(month: string) {
  const all = read(FINANZAS).split("\n");
  const movs = all.map((l, line) => ({ l, line, m: l.match(MOV) })).filter(x => x.m)
    .map(({ l, line, m }) => ({ line, raw: l, day: m![1], amount: Number(m![2]), desc: m![3], cat: m![4] ?? "otros" }));
  const months = [...new Set([today().slice(0, 7), ...movs.map(m => m.day.slice(0, 7))])].sort().reverse();
  const inSec = (name: string) => { const r = finSection(all, name); return r ? all.map((l, line) => ({ l, line })).slice(r[0] + 1, r[1]) : []; };
  const goals = inSec("Objetivos").map(({ l, line }) => ({ line, raw: l, m: l.match(GOAL) })).filter(x => x.m)
    .map(({ line, raw, m }) => ({ line, raw, name: m![1], meta: Number(m![2]), ahorrado: Number(m![3]), para: m![4] ?? "" }));
  const budgets = inSec("Presupuestos").map(({ l, line }) => ({ line, raw: l, m: l.match(BUDGET) })).filter(x => x.m)
    .map(({ line, raw, m }) => ({ line, raw, cat: m![1], amount: Number(m![2]) }));
  const inversiones = inSec("Inversiones").map(({ l, line }) => ({ line, raw: l, m: l.match(INV) })).filter(x => x.m)
    .map(({ line, raw, m }) => ({ line, raw, name: m![1], tipo: m![2], invertido: Number(m![3]), actual: Number(m![4]), moneda: m![5], vence: m![6] ?? "" }));
  const net: Record<string, number> = {};
  for (const m of movs) net[m.day.slice(0, 7)] = (net[m.day.slice(0, 7)] ?? 0) + m.amount;
  return { file: FINANZAS, month, months, goals, budgets, inversiones,
    history: Object.entries(net).sort().map(([month, net]) => ({ month, net })),
    movs: movs.filter(m => m.day.startsWith(month)).sort((a, b) => b.day.localeCompare(a.day) || b.line - a.line) };
}

// ---- Mascotas ----------------------------------------------------------------
// mascotas.md: "## <Nombre>" por mascota; arriba la ficha ("- especie: perro") y debajo
//   ### Salud           - 2026-03-10 vacuna antirrábica | próxima 2027-03-10
//   ### Recordatorios   - pipeta | cada 30 días | última 2026-10-01
//   ### Rutina          - sentarse          (ejercicios de todos los días)
//   ### Diario          - 2026-10-26 | hecho: sentarse, quieto | notas: se distrajo con otros perros
// El diario lo puede escribir Claude a partir de lo que le contás: es el mismo formato.
// Los gastos salen de finanzas.md (#mascotas).
const SALUD = /^- (\d{4}-\d{2}-\d{2}) (.+?)(?: \| próxima (\d{4}-\d{2}-\d{2}))?\s*$/;
const RECO = /^- (.+?) \| cada (\d+) días(?: \| última (\d{4}-\d{2}-\d{2}))?\s*$/;
const DIA = /^- (\d{4}-\d{2}-\d{2})(?: \| hecho: ([^|]*?))?(?: \| notas: (.*?))?\s*$/;
const diaLine = (day: string, hecho: string[], notas: string) =>
  `- ${day}${hecho.length ? " | hecho: " + hecho.join(", ") : ""}${notas ? " | notas: " + notas : ""}`;
const FICHA_M = /^- ([^:]+): (.*)$/;
const PET_KEYS = ["especie", "raza", "nacimiento", "peso", "veterinaria", "notas"];
const addDays = (d: string, n: number) => { const x = new Date(d + "T12:00:00"); x.setDate(x.getDate() + n); return x.toLocaleDateString("sv-SE"); };
function petBounds(lines: string[], name: string) {
  const s = lines.findIndex(l => l.trim() === "## " + name); if (s < 0) throw new Error("Mascota desconocida");
  let e = lines.findIndex((l, i) => i > s && l.startsWith("## ")); if (e < 0) e = lines.length;
  return [s, e];
}
function mascotas() {
  const lines = read(MASCOTAS).split("\n"), pets: any[] = [];
  let pet: any = null, sub = "";
  lines.forEach((l, line) => {
    if (l.startsWith("## ")) { pet = { name: l.slice(3).trim(), ficha: {}, salud: [], recos: [], rutina: [], diario: [] }; pets.push(pet); sub = ""; return; }
    if (!pet) return;
    if (l.startsWith("### ")) { sub = l.slice(4).trim().toLowerCase(); return; }
    let m;
    if (!sub && (m = l.match(FICHA_M))) pet.ficha[m[1].trim().toLowerCase()] = m[2].trim();
    else if (sub === "salud" && (m = l.match(SALUD))) pet.salud.push({ line, raw: l, day: m[1], what: m[2], next: m[3] ?? "" });
    else if (sub === "recordatorios" && (m = l.match(RECO))) pet.recos.push({ line, raw: l, what: m[1], every: Number(m[2]), last: m[3] ?? "", next: m[3] ? addDays(m[3], Number(m[2])) : "" });
    else if (sub === "rutina" && (m = l.match(/^- (.+)$/))) pet.rutina.push({ line, raw: l, text: m[1].trim() });
    else if (sub === "diario" && (m = l.match(DIA))) pet.diario.push({ line, raw: l, day: m[1],
      hecho: (m[2] ?? "").split(",").map(x => x.trim()).filter(Boolean), notas: m[3]?.trim() ?? "" });
  });
  pets.forEach(p => { p.salud.sort((a: any, b: any) => b.day.localeCompare(a.day)); p.diario.sort((a: any, b: any) => b.day.localeCompare(a.day)); });
  // Gastos #mascotas de los últimos 6 meses.
  const gastos = read(FINANZAS).split("\n").map(l => l.match(MOV)).filter(m => m && m[4] === "mascotas" && Number(m[2]) < 0)
    .map(m => ({ day: m![1], amount: -Number(m![2]), desc: m![3] })).sort((a, b) => b.day.localeCompare(a.day));
  return { file: MASCOTAS, pets, gastos };
}
function mascotaOp(b: any) {
  const clean = (t: unknown) => String(t ?? "").replace(/[\r\n|#]/g, " ").replace(/\s+/g, " ").trim();
  const isDay = (d: unknown) => /^\d{4}-\d{2}-\d{2}$/.test(String(d ?? ""));
  if (!existsSync(MASCOTAS)) writeFileSync(MASCOTAS, "# Mascotas\n");
  const lines = read(MASCOTAS).split("\n");
  const save = () => writeFileSync(MASCOTAS, lines.join("\n"));
  if (b.op === "add") {
    const name = clean(b.name); if (!name) throw new Error("Falta el nombre");
    if (lines.some(l => l.trim() === "## " + name)) throw new Error("Ya existe");
    while (lines.length && lines.at(-1) === "") lines.pop();
    lines.push("", "## " + name, ...(clean(b.especie) ? [`- especie: ${clean(b.especie)}`] : []), "");
    return save();
  }
  const [s, e] = petBounds(lines, b.pet);
  // Agrega una línea al final de "### <sub>" dentro de la mascota (lo crea si falta).
  const insert = (sub: string, line: string) => {
    let h = lines.findIndex((l, i) => i > s && i < e && l.trim() === "### " + sub);
    if (h < 0) { let k = e; while (k > s + 1 && lines[k - 1].trim() === "") k--; lines.splice(k, 0, "", "### " + sub); h = k + 1; }
    let end = lines.findIndex((l, i) => i > h && (l.startsWith("#"))); if (end < 0) end = lines.length;
    let k = end - 1; while (k > h && lines[k].trim() === "") k--;
    lines.splice(k + 1, 0, line);
  };
  if (b.op === "ficha") {
    // Reescribe la ficha (las líneas "- clave: valor" antes del primer ###), respetando claves desconocidas.
    let f = lines.findIndex((l, i) => i > s && i < e && l.startsWith("### ")); if (f < 0) f = e;
    const old = lines.slice(s + 1, f).filter(l => l.match(FICHA_M) && !PET_KEYS.includes(l.match(FICHA_M)![1].trim().toLowerCase()));
    const fresh = PET_KEYS.filter(k => clean(b[k])).map(k => `- ${k}: ${clean(b[k])}`);
    lines.splice(s + 1, f - s - 1, ...fresh, ...old, "");
    return save();
  }
  if (b.op === "salud") {
    const what = clean(b.what); if (!what) throw new Error("Falta qué fue");
    insert("Salud", `- ${isDay(b.day) ? b.day : today()} ${what}${isDay(b.next) ? " | próxima " + b.next : ""}`); return save();
  }
  if (b.op === "reco") {
    const what = clean(b.what), every = Math.round(Number(b.every)); if (!what || !(every > 0)) throw new Error("Falta qué o cada cuántos días");
    insert("Recordatorios", `- ${what} | cada ${every} días${isDay(b.last) ? " | última " + b.last : ""}`); return save();
  }
  if (b.op === "rutina") {
    const text = clean(b.text).replace(/,/g, " "); if (!text) throw new Error("Falta el ejercicio");
    insert("Rutina", `- ${text}`); return save();
  }
  if (b.op === "dia" || b.op === "nota") {
    // Una línea por día en "### Diario": tildar un ejercicio o escribir la nota la crea o la actualiza.
    const day = today(), i = lines.findIndex((l, k) => k > s && k < e && l.startsWith(`- ${day}`) && DIA.test(l));
    const m = i >= 0 ? lines[i].match(DIA)! : null;
    let hecho = (m?.[2] ?? "").split(",").map(x => x.trim()).filter(Boolean), notas = m?.[3]?.trim() ?? "";
    if (b.op === "dia") { const ex = clean(b.ex); hecho = hecho.includes(ex) ? hecho.filter(x => x !== ex) : [...hecho, ex]; }
    else notas = clean(b.notas);
    const line = diaLine(day, hecho, notas);
    if (i >= 0) lines[i] = line; else insert("Diario", line);
    return save();
  }
  if (lines[b.line] !== b.raw || b.line <= s || b.line >= e) throw new Error("El archivo cambió — recargá");
  if (b.op === "hecho") { const m = b.raw.match(RECO); if (!m) throw new Error("No es un recordatorio"); lines[b.line] = `- ${m[1]} | cada ${m[2]} días | última ${today()}`; }
  else if (b.op === "delete") lines.splice(b.line, 1);
  else throw new Error("Operación desconocida");
  save();
}

// estudio.md / nutricion.md: secciones "## X", una línea por registro; se agrega al final de la sección (la crea si falta).
const mdLines = (file: string, title: string) => { if (!existsSync(file)) writeFileSync(file, `# ${title}\n`); return read(file).split("\n"); };
function secAdd(lines: string[], name: string, line: string) {
  if (!finSection(lines, name)) { while (lines.length && lines.at(-1) === "") lines.pop(); lines.push("", "## " + name, ""); }
  finInsert(lines, name, line);
}
function secRows(lines: string[], name: string, re: RegExp) {
  const r = finSection(lines, name); if (!r) return [];
  return lines.slice(r[0] + 1, r[1]).map((raw, k) => ({ line: r[0] + 1 + k, raw, m: raw.match(re) })).filter(x => x.m);
}
const cleanTxt = (t: unknown) => String(t ?? "").replace(/[\r\n|#]/g, " ").replace(/\s+/g, " ").trim();
const isDay = (d: unknown) => /^\d{4}-\d{2}-\d{2}$/.test(String(d ?? ""));
const DIAS = ["dom", "lun", "mar", "mie", "jue", "vie", "sab"];
const dayOf = (d: string) => DIAS[new Date(d + "T12:00:00").getDay()];
function delLine(file: string, b: any) {
  const lines = read(file).split("\n");
  if (lines[b.line] !== b.raw || !b.raw) throw new Error("El archivo cambió — recargá");
  lines.splice(b.line, 1); writeFileSync(file, lines.join("\n"));
}

// ---- Estudio -----------------------------------------------------------------
// estudio.md:
//   ## Rutina     - tarjetas chino-practico 15     (lo que hacés todos los días: leer|ver|practicar|tarjetas|examen|libro|curso <tema> [cantidad])
//   ## Hecho      - 2026-10-27 leer machine-learning  /  - 2026-10-27 tarjetas chino-practico 12   (lo cumplido cada día)
//   ## Materiales - [ ] lectura datos-y-bases-de-datos | Título | https://… | obligatoria   ([x] … | hecho 2026-10-27)
//   ## Examen     - 2026-10-27 datos-y-bases-de-datos 7/10      (aciertos/respondidas del día)
// Los temas son los cerebros de `ds cerebro` (o cualquier palabra); las tarjetas salen de
// <cerebro>/studio/tarjetas-*.md (Obsidian SR: frente / "?" / dorso, y <!--SR:!fecha,intervalo,facilidad-->)
// y las preguntas de examen de <cerebro>/studio/examen-*.json (quiz de NotebookLM bajado por `ds cerebro sync`).
const ESTUDIO = tilde(process.env.DUBLIN_ESTUDIO || join(dirname(FINANZAS), "estudio.md"));
const CEREBROS = tilde(process.env.DUBLIN_CEREBROS || conf("cerebros-root"));
const ACTS = ["leer", "ver", "practicar", "tarjetas", "examen", "libro", "curso"];
const RUT = /^- (leer|ver|practicar|tarjetas|examen|libro|curso) (\S+)(?: (\d+))?\s*$/;
// libros.md (al lado de estudio.md): recorridos por pasos. Un libro o un curso por "## …" y un paso por línea:
//   ## Título | tema | archivo.pdf [| obligatoria]        - [ ] Cap. 2 Nombre · Sección | p. 80-98 [| hecho 2026-10-27]
//   ## Título | tema | https://curso [| obligatoria]      - [ ] Módulo · Paso | https://… [| 10 min] [| hecho 2026-10-27]
// El módulo es lo de antes del primer " · ". El PDF vive en <cerebro>/libros/.
const LIBROS = tilde(process.env.DUBLIN_LIBROS || join(dirname(ESTUDIO), "libros.md"));
const LIBRO = /^## (.+?) \| (\S+) \| (https?:\/\/\S+|.+?\.pdf)( \| obligatoria)?\s*$/;
const UNIDAD = /^- \[( |x)\] (.+?) \| (?:p\. (\d+)(?:-(\d+))?|(https?:\/\/\S+))(?: \| (\d+) min)?(?: \| hecho (\d{4}-\d{2}-\d{2}))?\s*$/;
function libros() {
  const out: any[] = [];
  read(LIBROS).split("\n").forEach((raw, line) => {
    let m;
    if ((m = raw.match(LIBRO))) {
      const url = /^https?:/.test(m[3]);
      out.push({ line, titulo: m[1].trim(), tema: m[2], kind: url ? "curso" : "libro", file: url ? "" : m[3], url: url ? m[3] : "", obligatoria: !!m[4], unidades: [] });
    } else if (out.length && (m = raw.match(UNIDAD))) {
      const t = m[2].trim(), i = t.indexOf(" · ");
      out.at(-1).unidades.push({ line, raw, hecho: m[1] === "x", titulo: t, grupo: i > 0 ? t.slice(0, i) : "", paso: i > 0 ? t.slice(i + 3) : t,
        p0: Number(m[3] ?? 0), p1: Number(m[4] ?? m[3] ?? 0), url: m[5] ?? "", min: Number(m[6] ?? 0), day: m[7] ?? "" });
    }
  });
  return out;
}
// El PDF de un libro de un cerebro (solo archivos de <cerebro>/libros/), para abrirlo en el navegador en la página.
function libroPdf(c: string, f: string) {
  if (!dirs(CEREBROS).includes(c) || !f || /[\/\\]/.test(f) || !f.endsWith(".pdf")) return null;
  const p = join(CEREBROS, c, "libros", f); return existsSync(p) ? p : null;
}
const HECHO = /^- (\d{4}-\d{2}-\d{2}) (leer|ver|practicar|tarjetas) (\S+)(?: (\d+))?\s*$/;
const MAT = /^- \[( |x)\] (lectura|video|curso) (\S+) \| (.+?)(?: \| (https?:\/\/\S+))?( \| obligatoria)?(?: \| hecho (\d{4}-\d{2}-\d{2}))?\s*$/;
const EXA = /^- (\d{4}-\d{2}-\d{2}) (\S+) (\d+)\/(\d+)\s*$/;
const SR = /<!--SR:!(\d{4}-\d{2}-\d{2}),(\d+),(\d+)-->/;
const tema = (t: unknown) => cleanTxt(t).toLowerCase().replace(/\s+/g, "-");
function cards(dir: string) {
  const out: any[] = [];
  for (const f of (() => { try { return readdirSync(join(dir, "studio")).filter(n => /^tarjetas-.*\.md$/.test(n)); } catch { return []; } })()) {
    read(join(dir, "studio", f)).split(/\n\s*\n/).forEach(raw => {
      const p = raw.split("\n"), q = p.findIndex(l => l.trim() === "?"); if (q < 1) return;
      const sr = raw.match(SR);
      out.push({ file: f, raw, front: p.slice(0, q).join("\n").trim(), back: p.slice(q + 1).join("\n").replace(SR, "").trim(), due: sr?.[1] ?? "" });
    });
  }
  return out;
}
function examen(dir: string) {
  const out: any[] = [];
  for (const f of (() => { try { return readdirSync(join(dir, "studio")).filter(n => /^examen-.*\.json$/.test(n)); } catch { return []; } })()) {
    try { for (const q of JSON.parse(read(join(dir, "studio", f))).questions ?? [])
      if (q.question && q.answerOptions?.length) out.push({ q: q.question, hint: q.hint ?? "", opts: q.answerOptions.map((o: any) => ({ text: o.text, ok: !!o.isCorrect, why: o.rationale ?? "" })) });
    } catch { /* json a medio bajar: se ignora */ }
  }
  return out;
}
function estudio() {
  const lines = read(ESTUDIO).split("\n");
  const rutina = secRows(lines, "Rutina", RUT).map(({ line, raw, m }) => ({ line, raw, tipo: m![1], tema: m![2], n: Number(m![3] ?? 0) }));
  const hecho = secRows(lines, "Hecho", HECHO).map(({ line, raw, m }) => ({ line, raw, day: m![1], tipo: m![2], tema: m![3], n: Number(m![4] ?? 1) }))
    .sort((a, b) => b.day.localeCompare(a.day));
  const cerebros = CEREBROS ? dirs(CEREBROS).filter(d => existsSync(join(CEREBROS, d, "cerebro.md"))).map(slug => {
    const md = read(join(CEREBROS, slug, "cerebro.md")).split("\n"), c = cards(join(CEREBROS, slug));
    return { slug, title: md.find(l => l.startsWith("# "))?.slice(2).trim() || slug, fuentes: secRows(md, "Fuentes", /^- (.+)$/).map(x => x.m![1].replace(/\s+\(desde NotebookLM\)$/, "")),
      total: c.length, due: c.filter(x => !x.due || x.due <= today()).slice(0, 30), examen: examen(join(CEREBROS, slug)) };
  }) : [];
  const materiales = secRows(lines, "Materiales", MAT).map(({ line, raw, m }) => ({ line, raw, hecho: m![1] === "x", tipo: m![2], tema: m![3], titulo: m![4].trim(), url: m![5] ?? "", obligatoria: !!m![6], day: m![7] ?? "" }));
  const examenes = secRows(lines, "Examen", EXA).map(({ line, raw, m }) => ({ line, raw, day: m![1], tema: m![2], ok: Number(m![3]), n: Number(m![4]) })).sort((a, b) => b.day.localeCompare(a.day));
  return { file: ESTUDIO, librosFile: LIBROS, root: CEREBROS, rutina, hecho, materiales, examenes, cerebros, libros: libros() };
}
function estudioOp(b: any) {
  if (b.op === "delete") return delLine(ESTUDIO, b);
  if (b.op === "unidad") {
    // Tildar / destildar un paso de un libro o curso: [x] + fecha, o vuelve a pendiente.
    const lines = read(LIBROS).split("\n");
    if (lines[b.line] !== b.raw || !UNIDAD.test(b.raw)) throw new Error("El archivo cambió — recargá");
    const base = b.raw.replace(/ \| hecho \d{4}-\d{2}-\d{2}\s*$/, "");
    lines[b.line] = b.raw.startsWith("- [x]") ? base.replace("- [x]", "- [ ]") : base.replace("- [ ]", "- [x]") + ` | hecho ${today()}`;
    return writeFileSync(LIBROS, lines.join("\n"));
  }
  if (b.op === "repaso") {
    // Repetición espaciada mínima: "la sabía" multiplica el intervalo por la facilidad; "no" vuelve a 1 día.
    if (!dirs(CEREBROS).includes(b.slug) || !/^tarjetas-[^/]*\.md$/.test(b.file)) throw new Error("Tarjeta desconocida");
    const file = join(CEREBROS, b.slug, "studio", b.file), txt = read(file), i = txt.indexOf(b.raw);
    if (!b.raw || i < 0 || txt.indexOf(b.raw, i + 1) >= 0) throw new Error("El archivo cambió — recargá");
    const m = b.raw.match(SR), iv = Number(m?.[2] ?? 0), ease = Number(m?.[3] ?? 250);
    const [niv, nease] = b.ok ? [iv ? Math.round(iv * ease / 100) : 3, ease] : [1, Math.max(130, ease - 20)];
    const sr = `<!--SR:!${addDays(today(), niv)},${niv},${nease}-->`;
    writeFileSync(file, txt.slice(0, i) + (m ? b.raw.replace(SR, sr) : b.raw + "\n" + sr) + txt.slice(i + b.raw.length));
    // Cuenta para la actividad "tarjetas <tema>" de hoy.
    const lines = mdLines(ESTUDIO, "Estudio"), h = secRows(lines, "Hecho", HECHO).find(x => x.m![1] === today() && x.m![2] === "tarjetas" && x.m![3] === b.slug);
    const line = `- ${today()} tarjetas ${b.slug} ${Number(h?.m![4] ?? 0) + 1}`;
    if (h) lines[h.line] = line; else secAdd(lines, "Hecho", line);
    return writeFileSync(ESTUDIO, lines.join("\n"));
  }
  const lines = mdLines(ESTUDIO, "Estudio"), t = tema(b.tema);
  if (b.op === "mhecho") {
    // Tildar / destildar un material: [x] + fecha, o vuelve a pendiente.
    if (lines[b.line] !== b.raw) throw new Error("El archivo cambió — recargá");
    const m = b.raw.match(MAT); if (!m) throw new Error("No es un material");
    const base = b.raw.replace(/ \| hecho \d{4}-\d{2}-\d{2}\s*$/, "");
    lines[b.line] = m[1] === "x" ? base.replace("- [x]", "- [ ]") : base.replace("- [ ]", "- [x]") + ` | hecho ${today()}`;
    return writeFileSync(ESTUDIO, lines.join("\n"));
  }
  if (b.op === "material") {
    const titulo = cleanTxt(b.titulo), url = String(b.url ?? "").trim();
    if (!["lectura", "video"].includes(b.tipo) || !t || !titulo) throw new Error("Falta tipo, tema o título");
    if (url && !/^https?:\/\/\S+$/.test(url)) throw new Error("El link tiene que empezar con http");
    secAdd(lines, "Materiales", `- [ ] ${b.tipo} ${t} | ${titulo}${url ? " | " + url : ""}${b.obligatoria ? " | obligatoria" : ""}`);
    return writeFileSync(ESTUDIO, lines.join("\n"));
  }
  if (b.op === "respuesta") {
    // Una línea por día y tema en "## Examen": cada respuesta suma a "aciertos/respondidas".
    if (!t) throw new Error("Falta el tema");
    const i = secRows(lines, "Examen", EXA).find(x => x.m![1] === today() && x.m![2] === t);
    const [ok, n] = i ? [Number(i.m![3]), Number(i.m![4])] : [0, 0], line = `- ${today()} ${t} ${ok + (b.ok ? 1 : 0)}/${n + 1}`;
    if (i) lines[i.line] = line; else secAdd(lines, "Examen", line);
    return writeFileSync(ESTUDIO, lines.join("\n"));
  }
  if (!ACTS.includes(b.tipo) || !t) throw new Error("Falta la actividad o el tema");
  if (b.op === "actividad") {
    const n = Math.round(Number(b.n) || 0);
    secAdd(lines, "Rutina", `- ${b.tipo} ${t}${n > 0 ? " " + n : ""}`);
  } else if (b.op === "hecho") {
    // leer / ver / practicar: tildar hoy agrega la línea; destildar la saca.
    if (!["leer", "ver", "practicar"].includes(b.tipo)) throw new Error("Esta actividad se cuenta sola");
    const h = secRows(lines, "Hecho", HECHO).find(x => x.m![1] === today() && x.m![2] === b.tipo && x.m![3] === t);
    if (h) lines.splice(h.line, 1); else secAdd(lines, "Hecho", `- ${today()} ${b.tipo} ${t}`);
  } else throw new Error("Operación desconocida");
  writeFileSync(ESTUDIO, lines.join("\n"));
}

// ---- Nutrición ---------------------------------------------------------------
// nutricion.md:
//   ## Plan     - lun | almuerzo | pollo con arroz y ensalada   (lo que pensás comer cada día)
//   ## Diario   - 2026-10-27 | almuerzo | pollo con arroz        (lo que comiste)
//   ## Peso     - 2026-10-27 82.5
const NUTRICION = tilde(process.env.DUBLIN_NUTRICION || join(dirname(FINANZAS), "nutricion.md"));
const COMIDAS = ["desayuno", "almuerzo", "merienda", "cena", "colación"];
const PLAN = /^- (dom|lun|mar|mie|jue|vie|sab) \| (\S+) \| (.+)$/;
const COMI = /^- (\d{4}-\d{2}-\d{2}) \| (\S+) \| (.+)$/;
const PESO = /^- (\d{4}-\d{2}-\d{2}) (\d+(?:\.\d+)?)\s*$/;
// ---- Flujos ------------------------------------------------------------------
// flujos.md (en la raíz de los cerebros): qué cerebros consulta el agente, y por qué camino,
// antes de ciertas tareas. Es un grafo: nodos (cerebro + pregunta + posición en el lienzo) y
// cables, con condición opcional. Desde un nodo, los cables sin condición se siguen todos (en
// paralelo); los que tienen condición, solo el que aplique. Lo lee env/cerebro/cerebro-nudge.sh.
//   ## Ad para cliente
//   disparo: ad, anuncio, campaña
//   skills: video-creativo, ugc-scriptwriter
//   - a marca-personal-tech-en-instagram | ¿a quién le hablo? @ 260,40
//   - b storytelling-y-viralidad-en-video-corto | ¿qué gancho? @ 520,0
//   > inicio a
//   > a b | si es para un cliente
const FLUJOS = CEREBROS ? join(CEREBROS, "flujos.md") : "";
const SKILLS_DIR = join(HOME, ".claude", "skills");
const NODO = /^- (\w+) (\S+)(?: \| (.*?))?(?: @ (-?\d+),(-?\d+))?\s*$/, CABLE = /^> (\w+) (\w+)(?: \| (.*))?$/;
const csv = (t: unknown) => String(t ?? "").split(",").map(cleanTxt).filter(Boolean).join(", ");
const oneLine = (t: unknown) => String(t ?? "").replace(/[\r\n|]/g, " ").replace(/\s+/g, " ").trim();
function flujoBlocks() {
  const lines = FLUJOS && existsSync(FLUJOS) ? read(FLUJOS).split("\n") : [], out: { start: number; end: number; raw: string }[] = [];
  lines.forEach((l, i) => { if (l.startsWith("## ")) { if (out.length) out.at(-1)!.end = i; out.push({ start: i, end: lines.length, raw: "" }); } });
  for (const b of out) { while (b.end > b.start + 1 && lines[b.end - 1].trim() === "") b.end--; b.raw = lines.slice(b.start, b.end).join("\n"); }
  return { lines, blocks: out };
}
// Un nodo es un cerebro (slug) o una skill ("skill:onetake", instalada en ~/.claude/skills).
const nodoOk = (c: string, cer: Set<string>) => c.startsWith("skill:") ? existsSync(join(SKILLS_DIR, c.slice(6), "SKILL.md")) : cer.has(c);
function flujos() {
  const cer = new Set(CEREBROS ? dirs(CEREBROS) : []);
  const list = flujoBlocks().blocks.map(({ raw }) => {
    const ls = raw.split("\n"), get = (k: string) => (ls.find(l => l.startsWith(k + ":"))?.slice(k.length + 1) ?? "").split(",").map(s => s.trim()).filter(Boolean);
    const nodes = ls.map(l => l.match(NODO)).filter(Boolean).map((m, k) => ({ id: m![1], cerebro: m![2], pregunta: (m![3] ?? "").trim(), x: m![4] != null ? Math.max(274, Number(m![4])) : 344 + 300 * k, y: m![5] != null ? Number(m![5]) : 40, ok: nodoOk(m![2], cer) }));
    const edges = ls.map(l => l.match(CABLE)).filter(Boolean).map(m => ({ from: m![1], to: m![2], cond: (m![3] ?? "").trim() }));
    return { raw, name: ls[0].slice(3).trim(), tipo: ["ideas", "produccion"].includes(get("tipo")[0]) ? get("tipo")[0] : "consulta", angulos: ls.some(l => l.startsWith("angulos:")) ? get("angulos") : null, disparo: get("disparo"), skills: get("skills"), nodes, edges };
  });
  return { file: FLUJOS, list, cer: cerebroInfo(), skills: dirs(SKILLS_DIR).filter(d => existsSync(join(SKILLS_DIR, d, "SKILL.md"))) };
}
// Título y notebook de cada cerebro: van en el texto al compartir, así el otro sabe qué pedir.
function cerebroInfo() {
  return Object.fromEntries((CEREBROS ? dirs(CEREBROS) : []).filter(d => existsSync(join(CEREBROS, d, "cerebro.md"))).map(d => {
    const md = read(join(CEREBROS, d, "cerebro.md"));
    return [d, { title: md.match(/^# (.+)$/m)?.[1].trim() || d, notebook: md.match(/^notebook: *(\S+)/m)?.[1] ?? "" }];
  }));
}
// Compartir: el texto del flujo + una línea por cerebro (slug | título | notebook). Importar lo lee
// y crea los cerebros que falten como carpeta con su notebook (después: ds cerebro sync).
const CER_LINE = /^<!-- cerebro ([a-z0-9-]+) \| (.*?) \| ([\w-]*) -->$/;
function flujoImport(text: string) {
  const ls = String(text ?? "").split(/\r?\n/).map(l => l.trimEnd()), h = ls.findIndex(l => l.startsWith("## "));
  if (h < 0) throw new Error("No encontré un flujo en ese texto");
  const end = ls.findIndex((l, i) => i > h && l.startsWith("## ")), body = ls.slice(h + 1, end < 0 ? ls.length : end);
  const nodes = body.map(l => l.match(NODO)).filter(Boolean).map(m => ({ id: m![1], cerebro: m![2], pregunta: m![3] ?? "", x: Number(m![4] ?? 344), y: Number(m![5] ?? 40) }));
  const edges = body.map(l => l.match(CABLE)).filter(Boolean).map(m => ({ from: m![1], to: m![2], cond: m![3] ?? "" }));
  if (nodes.some(n => !/^(skill:)?[a-z0-9-]+$/.test(n.cerebro))) throw new Error("El flujo tiene un cerebro con nombre inválido");
  const faltanSkills = [...new Set(nodes.filter(n => n.cerebro.startsWith("skill:") && !nodoOk(n.cerebro, new Set())).map(n => n.cerebro.slice(6)))];
  if (faltanSkills.length) throw new Error("Te faltan estas skills (instalá dublin-skills con ./install.sh install): " + faltanSkills.join(", "));
  const get = (k: string) => body.find(l => l.startsWith(k + ":"))?.slice(k.length + 1) ?? "";
  const info = Object.fromEntries(ls.map(l => l.match(CER_LINE)).filter(Boolean).map(m => [m![1], { title: m![2], notebook: m![3] }]));
  const have = new Set(dirs(CEREBROS)), created: string[] = [], slugs: string[] = [], missing: string[] = [];
  for (const c of new Set(nodes.map(n => n.cerebro))) {
    if (have.has(c) || c.startsWith("skill:")) continue;
    const i = info[c];
    if (!i?.notebook) { missing.push(i?.title || c); continue; }
    mkdirSync(join(CEREBROS, c), { recursive: true });
    writeFileSync(join(CEREBROS, c, "cerebro.md"), `# ${cleanTxt(i.title) || c}\n\nnotebook: ${i.notebook}\n\n## Fuentes\n\n## Notas\n`);
    created.push(cleanTxt(i.title) || c); slugs.push(c);
  }
  if (missing.length) throw new Error("Al texto le faltan los datos de: " + missing.join(", "));
  const taken = new Set(flujoBlocks().blocks.map(b => b.raw.split("\n")[0].slice(3).trim().toLowerCase()));
  let name = cleanTxt(ls[h].slice(3)), k = 2; const base = name;
  while (taken.has(name.toLowerCase())) name = `${base} (${k++})`;
  flujosOp({ op: "save", old: "", name, tipo: get("tipo").trim(), angulos: get("angulos"), disparo: get("disparo"), skills: get("skills"), nodes, edges });
  // Los cerebros nuevos nacen con la lista de fuentes vacía: se trae de NotebookLM en segundo plano
  // (de a uno; si todavía no le dieron acceso falla sin romper nada y queda para `ds cerebro sync`).
  const sync = join(import.meta.dir, "..", "cerebro", "cerebro.sh");
  slugs.reduce((p, c) => p.then(() => run(["bash", sync, "sync", c], CEREBROS, 300000)), Promise.resolve<string | null>(null));
  return { name, created };
}
async function flujoShare(b: any) {
  const email = String(b.email ?? "").trim();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error("Mail inválido");
  const f = flujos().list.find(x => x.raw === b.old); if (!f) throw new Error("El archivo cambió — recargá");
  const info = cerebroInfo(), shared: string[] = [], failed: string[] = [];
  for (const c of new Set(f.nodes.map(n => n.cerebro).filter(c => !c.startsWith("skill:")))) {
    const i = info[c]; if (!i?.notebook) { failed.push(i?.title || c); continue; }
    const out = await run(["notebooklm", "--quiet", "share", "add", email, "--permission", "viewer", "-n", i.notebook], CEREBROS, 60000);
    (out == null ? failed : shared).push(i.title);
  }
  return { shared, failed };
}
function flujosOp(b: any) {
  if (!FLUJOS) throw new Error("No hay carpeta de cerebros configurada");
  const { lines, blocks } = flujoBlocks(), old = b.old ? blocks.find(x => x.raw === b.old) : null;
  if (b.old && !old) throw new Error("El archivo cambió — recargá");
  if (b.op === "delete") { if (!old) throw new Error("Falta el flujo"); lines.splice(old.start, old.end - old.start); }
  else if (b.op === "save") {
    const name = cleanTxt(b.name), cer = new Set(dirs(CEREBROS));
    if (!name) throw new Error("Ponele un nombre al flujo");
    if (blocks.some(x => x !== old && x.raw.split("\n")[0].slice(3).trim().toLowerCase() === name.toLowerCase())) throw new Error("Ya hay un flujo con ese nombre");
    const nodes = (Array.isArray(b.nodes) ? b.nodes : []).filter((n: any) => /^\w+$/.test(n?.id ?? "") && n.id !== "inicio");
    if (!nodes.length) throw new Error("Sumá al menos un cerebro");
    if (nodes.some((n: any) => !nodoOk(String(n.cerebro ?? ""), cer))) throw new Error("Hay un nodo sin cerebro o skill elegido");
    const ids = new Set(nodes.map((n: any) => n.id)); if (ids.size !== nodes.length) throw new Error("Nodos repetidos");
    const seen = new Set<string>(), edges = (Array.isArray(b.edges) ? b.edges : []).filter((e: any) => {
      const k = e?.from + ">" + e?.to; if (seen.has(k)) return false; seen.add(k);
      return (e.from === "inicio" || ids.has(e.from)) && ids.has(e.to) && e.from !== e.to;
    });
    if (!edges.some((e: any) => e.from === "inicio")) throw new Error("Uní el disparo con el primer cerebro");
    // Sin vueltas: un flujo siempre termina.
    const out = (id: string) => edges.filter((e: any) => e.from === id).map((e: any) => e.to), st: Record<string, number> = {};
    const loop = (id: string): boolean => { if (st[id] === 1) return true; if (st[id] === 2) return false; st[id] = 1; const r = out(id).some(loop); st[id] = 2; return r; };
    if (loop("inicio") || nodes.some((n: any) => loop(n.id))) throw new Error("Hay una vuelta en el flujo: los cables tienen que ir siempre hacia adelante");
    const block = [`## ${name}`, `tipo: ${["ideas", "produccion"].includes(b.tipo) ? b.tipo : "consulta"}`, ...(b.tipo === "ideas" ? [`angulos: ${csv(b.angulos)}`] : []), `disparo: ${csv(b.disparo)}`, `skills: ${csv(b.skills)}`,
      ...nodes.map((n: any) => { const q = oneLine(n.pregunta); return `- ${n.id} ${n.cerebro}${q ? " | " + q : ""} @ ${Math.max(0, Math.round(Number(n.x) || 0))},${Math.max(0, Math.round(Number(n.y) || 0))}`; }),
      ...edges.map((e: any) => { const c = oneLine(e.cond); return `> ${e.from} ${e.to}${c ? " | " + c : ""}`; })];
    if (old) lines.splice(old.start, old.end - old.start, ...block);
    else { if (!lines.length) lines.push("# Flujos", ""); while (lines.length && lines.at(-1) === "") lines.pop(); lines.push("", ...block); }
  } else throw new Error("Operación desconocida");
  writeFileSync(FLUJOS, lines.join("\n").replace(/\n*$/, "\n"));
}

// ---- Contenido ----------------------------------------------------------------
// contenido.md (al lado de finanzas.md): ideas que dejan los flujos de tipo "ideas" con
// `ds contenido add`. Se eligen acá: Bandeja → Cola (sí) o Descartadas (no) → Producción → Publicado.
//   ## Bandeja   - 2026-10-27 | rumen | La idea | El gancho | Contenido para proyectos
const CONTENIDO = tilde(process.env.DUBLIN_CONTENIDO || join(dirname(FINANZAS), "contenido.md"));
const CSECS = ["Bandeja", "Cola", "Producción", "Publicado", "Descartadas"];
const IDEA = /^- (\d{4}-\d{2}-\d{2}) \| ([^|]*)\| ([^|]*)\|?([^|]*)\|?([^|]*)\|?([^|]*)\|?(.*)$/;   // … | gancho | flujo | ángulo | tratamiento
function contenido() {
  const lines = existsSync(CONTENIDO) ? read(CONTENIDO).split("\n") : [];
  return { file: CONTENIDO, secs: Object.fromEntries(CSECS.map(n => [n, secRows(lines, n, IDEA).map(({ line, raw, m }) =>
    ({ line, raw, day: m![1], proyecto: m![2].trim(), idea: m![3].trim(), gancho: m![4].trim(), flujo: m![5].trim(), angulo: m![6].trim(), detalle: m![7].trim() }))])) };
}
function contenidoOp(b: any) {
  if (!existsSync(CONTENIDO)) writeFileSync(CONTENIDO, "# Contenido\n" + CSECS.map(n => `\n## ${n}\n`).join(""));
  const lines = read(CONTENIDO).split("\n");
  if (b.op === "add") {
    const proy = cleanTxt(b.proyecto), idea = cleanTxt(b.idea);
    if (!proy || !idea) throw new Error("Falta el proyecto o la idea");
    const ang = cleanTxt(b.angulo), det = cleanTxt(b.detalle);
    secAdd(lines, "Bandeja", `- ${today()} | ${proy} | ${idea} | ${cleanTxt(b.gancho)} | ${ang || det ? " | " + ang : ""}${det ? " | " + det : ""}`);
    return writeFileSync(CONTENIDO, lines.join("\n"));
  }
  if (lines[b.line] !== b.raw || !b.raw) throw new Error("El archivo cambió — recargá");
  if (b.op === "delete") lines.splice(b.line, 1);
  else if (b.op === "move") {
    if (!CSECS.includes(b.to)) throw new Error("Sección desconocida");
    lines.splice(b.line, 1); secAdd(lines, b.to, b.raw);
  } else if (b.op === "up" || b.op === "down") {   // ordenar dentro de la misma sección
    const j = b.line + (b.op === "up" ? -1 : 1);
    if (!lines[j]?.startsWith("- ")) return;
    [lines[b.line], lines[j]] = [lines[j], lines[b.line]];
  } else throw new Error("Operación desconocida");
  writeFileSync(CONTENIDO, lines.join("\n"));
}

function nutricion() {
  const lines = read(NUTRICION).split("\n");
  return { file: NUTRICION, comidas: COMIDAS,
    plan: secRows(lines, "Plan", PLAN).map(({ line, raw, m }) => ({ line, raw, dia: m![1], comida: m![2], que: m![3].trim() })),
    diario: secRows(lines, "Diario", COMI).map(({ line, raw, m }) => ({ line, raw, day: m![1], comida: m![2], que: m![3].trim() })).sort((a, b) => b.day.localeCompare(a.day) || COMIDAS.indexOf(a.comida) - COMIDAS.indexOf(b.comida)),
    peso: secRows(lines, "Peso", PESO).map(({ line, raw, m }) => ({ line, raw, day: m![1], kg: Number(m![2]) })).sort((a, b) => b.day.localeCompare(a.day)) };
}
function nutricionOp(b: any) {
  if (b.op === "delete") return delLine(NUTRICION, b);
  const lines = mdLines(NUTRICION, "Nutrición"), que = cleanTxt(b.que);
  if (b.op === "peso") {
    const kg = num(b.kg); if (!(kg > 0 && kg < 400)) throw new Error("Peso inválido");
    secAdd(lines, "Peso", `- ${isDay(b.day) ? b.day : today()} ${kg}`);
  } else if (b.op === "plan" || b.op === "comi") {
    if (!COMIDAS.includes(b.comida) || !que) throw new Error("Falta la comida o qué");
    if (b.op === "plan") { if (!DIAS.includes(b.dia)) throw new Error("Falta el día"); secAdd(lines, "Plan", `- ${b.dia} | ${b.comida} | ${que}`); }
    else secAdd(lines, "Diario", `- ${isDay(b.day) ? b.day : today()} | ${b.comida} | ${que}`);
  } else throw new Error("Operación desconocida");
  writeFileSync(NUTRICION, lines.join("\n"));
}

// Facturas de `ds factura` (sección "## Facturas"):
// "- 2026-10-26 C 0002-00000007 2000000 Cliente (30123456789) · desc · 2026-10 · vto pago 2026-10-31 · CAE … vto … · iva 4 · pendiente"
const FACT = /^- (\d{4}-\d{2}-\d{2}) ([BC]) (\d{4}-\d{8}) (\d+(?:\.\d+)?) (.*?) \((\d{11})\) · (.*)$/;
const FACTURA_SH = join(import.meta.dir, "../factura/factura.sh");
function facturas() {
  return read(FINANZAS).split("\n").map(l => l.match(FACT)).filter(Boolean).map(m => {
    const parts = m![7].split(" · "), estado = parts.at(-1) ?? "";
    const find = (p: string) => parts.find(x => x.startsWith(p))?.slice(p.length) ?? "";
    return { day: m![1], letra: m![2], id: m![3], monto: Number(m![4]), cliente: m![5], cuit: m![6],
      desc: parts[0] ?? "", periodo: parts[1] ?? "", vto: find("vto pago "), cae: find("CAE ").split(" ")[0],
      pagada: estado.startsWith("pagada") ? estado.slice(7) : "" };
  }).sort((a, b) => b.day.localeCompare(a.day) || b.id.localeCompare(a.id));
}
// Pagar y PDF corren el mismo script que la terminal: una sola lógica.
async function facturaOp(b: any) {
  if (!/^\d{4}-\d{8}$/.test(b.id) || !facturas().some(f => f.id === b.id)) throw new Error("Factura desconocida");
  const env = { ...process.env, DUBLIN_FINANZAS: FINANZAS };
  const p = Bun.spawn(["bash", FACTURA_SH, b.op === "pdf" ? "pdf" : "pagar", b.id], { stdout: "pipe", stderr: "pipe", stdin: "ignore", env });
  const t = setTimeout(() => p.kill(), 120000);
  const [out, err] = await Promise.all([new Response(p.stdout).text(), new Response(p.stderr).text()]);
  const code = await p.exited; clearTimeout(t);
  const plain = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "").trim();
  if (code !== 0) throw new Error(plain(err).split("\n").at(-1) || "Falló ds factura");
  if (b.op === "pdf") { const f = plain(out).match(/PDF: (.+\.pdf)/)?.[1]; if (f) Bun.spawn(["open", f]); }
}

function finOp(b: any) {
  const clean = (t: unknown) => String(t ?? "").replace(/[\r\n#|]/g, " ").replace(/\s+/g, " ").trim();
  if (b.op === "add") {
    const monto = num(b.monto), desc = clean(b.desc);
    const cat = String(b.cat ?? "").trim().toLowerCase().replace(/\s+/g, "-").replace(/[^\p{L}\d-]/gu, "");
    const day = /^\d{4}-\d{2}-\d{2}$/.test(b.day) ? b.day : today();
    if (!(monto > 0) || !desc) throw new Error("Falta monto o descripción");
    const lines = finLines(); while (lines.length && lines.at(-1) === "") lines.pop();
    lines.push(`- ${day} ${b.tipo === "+" ? "" : "-"}${monto} ${desc}${cat ? " #" + cat : ""}`, "");
    return writeFileSync(FINANZAS, lines.join("\n"));
  }
  if (b.op === "goal") {
    const name = clean(b.name), meta = num(b.meta), ahorrado = num(b.ahorrado) || 0;
    if (!name || !(meta > 0)) throw new Error("Falta nombre o meta");
    const lines = finLines();
    finInsert(lines, "Objetivos", `- ${name} | meta ${meta} | ahorrado ${ahorrado}${/^\d{4}-\d{2}$/.test(b.para) ? " | para " + b.para : ""}`);
    return writeFileSync(FINANZAS, lines.join("\n"));
  }
  if (b.op === "inv") {
    const name = clean(b.name), tipo = clean(b.tipo) || "otros", inv = num(b.invertido), act = num(b.actual) || inv;
    const mon = b.moneda === "USD" ? "USD" : "ARS", vence = /^\d{4}-\d{2}-\d{2}$/.test(b.vence) ? " | vence " + b.vence : "";
    if (!name || !(inv > 0)) throw new Error("Falta nombre o monto invertido");
    const lines = finLines(); finInsert(lines, "Inversiones", `- ${name} | ${tipo} | invertido ${inv} | actual ${act} | ${mon}${vence}`);
    return writeFileSync(FINANZAS, lines.join("\n"));
  }
  if (b.op === "budget") {
    const cat = String(b.cat ?? "").trim().toLowerCase().replace(/\s+/g, "-").replace(/[^\p{L}\d-]/gu, ""), amount = num(b.amount);
    if (!cat || !(amount > 0)) throw new Error("Falta categoría o monto");
    const lines = finLines(), [s, e] = finSection(lines, "Presupuestos")!;
    const i = lines.findIndex((l, k) => k > s && k < e && l.match(BUDGET)?.[1] === cat);
    if (i >= 0) lines[i] = `- ${cat} ${amount}`; else finInsert(lines, "Presupuestos", `- ${cat} ${amount}`);
    return writeFileSync(FINANZAS, lines.join("\n"));
  }
  const lines = read(FINANZAS).split("\n");
  if (lines[b.line] !== b.raw) throw new Error("El archivo cambió — recargá");
  if (b.op === "aportar") {
    const m = lines[b.line].match(GOAL); if (!m) throw new Error("No es un objetivo");
    const ahorrado = Math.max(0, Number(m[3]) + (b.tipo === "-" ? -1 : 1) * num(b.monto));
    lines[b.line] = lines[b.line].replace(/\| ahorrado \d+(?:\.\d+)?/, `| ahorrado ${ahorrado}`);
  } else if (b.op === "invact") {
    if (!INV.test(lines[b.line])) throw new Error("No es una inversión");
    const act = num(b.actual); if (!(act >= 0)) throw new Error("Monto inválido");
    lines[b.line] = lines[b.line].replace(/\| actual \d+(?:\.\d+)?/, `| actual ${act}`);
  } else if (b.op === "delete") lines.splice(b.line, 1);
  else throw new Error("Operación desconocida");
  writeFileSync(FINANZAS, lines.join("\n"));
}

// ---- Proyectos fijados / archivados (por persona, en ~/.config/dublin) ----------
const listFile = (k: string) => join(CONF_DIR, `panel-${k}`);
const readList = (k: string) => read(listFile(k)).split("\n").filter(Boolean);
function projectOp(b: any) {
  if (b.op === "order") { // orden manual de la lista (arrastrar)
    const known = new Set(projectDirs()), names = (Array.isArray(b.names) ? b.names : []).filter((n: unknown) => known.has(String(n)));
    mkdirSync(CONF_DIR, { recursive: true }); return writeFileSync(listFile("order"), names.join("\n") + "\n");
  }
  if (!projectDirs().includes(b.name)) throw new Error("Proyecto desconocido");
  const k = { pin: "pinned", unpin: "pinned", archive: "archived", unarchive: "archived" }[b.op as string];
  if (!k) throw new Error("Operación desconocida");
  mkdirSync(CONF_DIR, { recursive: true });
  const set = new Set(readList(k)); b.op.startsWith("un") ? set.delete(b.name) : set.add(b.name);
  if (b.op === "archive") { const p = new Set(readList("pinned")); p.delete(b.name); writeFileSync(listFile("pinned"), [...p].join("\n") + "\n"); }
  writeFileSync(listFile(k), [...set].join("\n") + "\n");
}

// ---- Calendario: direcciones iCal secretas (Google Calendar → Configuración →
// "Dirección secreta en formato iCal"). Solo lectura, sin OAuth. Una por línea en
// ~/.config/dublin/calendars ("<url> <nombre>"), con permisos 600 porque son secretas.
const CAL_FILE = join(CONF_DIR, "calendars");
const DAYS_AHEAD = 14;
const calList = () => read(CAL_FILE).split("\n").filter(Boolean).map(l => { const [url, ...n] = l.split(" "); return { url, name: n.join(" ") || "Calendario" }; });
const calCache = new Map<string, { at: number; text: string }>();

function tzOffset(utcMs: number, tz: string) { // ms que la zona está adelantada respecto de UTC
  try {
    const p = Object.fromEntries(new Intl.DateTimeFormat("en-US", { timeZone: tz, hourCycle: "h23", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit" })
      .formatToParts(new Date(utcMs)).map(x => [x.type, x.value]));
    return Date.UTC(+p.year, +p.month - 1, +p.day, +p.hour % 24, +p.minute, +p.second) - utcMs;
  } catch { return 0; }
}
// "20261023T150000Z" / TZID=… / "20261023" (todo el día) → { ms, allDay }
function icsDate(v: string, params: string) {
  const m = v.match(/^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z)?)?/); if (!m) return null;
  const [, y, mo, d, h, mi, s, z] = m;
  if (!h) return { ms: new Date(+y, +mo - 1, +d).getTime(), allDay: true };
  const wall = Date.UTC(+y, +mo - 1, +d, +h, +mi, +s);
  if (z) return { ms: wall, allDay: false };
  const tz = params.match(/TZID=([^;:]+)/)?.[1];
  if (!tz) return { ms: new Date(+y, +mo - 1, +d, +h, +mi, +s).getTime(), allDay: false };
  const guess = wall - tzOffset(wall, tz);
  return { ms: wall - tzOffset(guess, tz), allDay: false };
}

const WD = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
function parseIcs(text: string, cal: string, from: number, to: number) {
  const evs: any[] = []; let ev: any = null;
  for (const l of text.replace(/\r?\n[ \t]/g, "").split(/\r?\n/)) {
    if (l === "BEGIN:VEVENT") { ev = { ex: new Set<number>() }; continue; }
    if (l === "END:VEVENT") { if (ev?.start) evs.push(ev); ev = null; continue; }
    if (!ev) continue;
    const i = l.indexOf(":"); if (i < 0) continue;
    const [key, ...ps] = l.slice(0, i).split(";"), params = ps.join(";"), val = l.slice(i + 1);
    const unesc = (s: string) => s.replace(/\\n/gi, " ").replace(/\\([,;\\])/g, "$1");
    if (key === "DTSTART") ev.start = icsDate(val, params);
    else if (key === "DTEND") ev.end = icsDate(val, params);
    else if (key === "SUMMARY") ev.summary = unesc(val);
    else if (key === "LOCATION") ev.location = unesc(val);
    else if (key === "STATUS") ev.status = val;
    else if (key === "UID") ev.uid = val;
    else if (key === "RRULE") ev.rrule = Object.fromEntries(val.split(";").map(kv => kv.split("=")));
    else if (key === "RECURRENCE-ID") ev.rid = icsDate(val, params)?.ms;
    else if (key === "EXDATE") for (const d of val.split(",")) { const x = icsDate(d, params); if (x) ev.ex.add(x.ms); }
  }
  // Una instancia editada de una serie (RECURRENCE-ID) reemplaza a la original.
  for (const o of evs) if (o.rid != null) evs.find(m => m.uid === o.uid && m.rrule)?.ex.add(o.rid);
  const out: any[] = [];
  for (const e of evs) {
    if (e.status === "CANCELLED") continue;
    const dur = (e.end?.ms ?? e.start.ms + (e.start.allDay ? 864e5 : 36e5)) - e.start.ms;
    for (const s of expand(e, from - dur, to)) if (!e.ex.has(s))
      out.push({ cal, title: e.summary || "(sin título)", location: e.location || "", start: s, end: s + dur, allDay: e.start.allDay });
  }
  return out;
}
// Expande RRULE (DAILY/WEEKLY/MONTHLY/YEARLY, INTERVAL, COUNT, UNTIL, BYDAY semanal) dentro de [from, to].
function expand(ev: any, from: number, to: number): number[] {
  const s0 = ev.start.ms, r = ev.rrule;
  if (!r) return s0 <= to && s0 >= from ? [s0] : [];
  const iv = Number(r.INTERVAL ?? 1), count = r.COUNT ? Number(r.COUNT) : Infinity;
  const until = r.UNTIL ? icsDate(r.UNTIL, "")!.ms : Infinity, out: number[] = [];
  const base = new Date(s0); let n = 0;
  const push = (ms: number) => { n++; if (ms >= from && ms <= to && ms <= until) out.push(ms); };
  if (r.FREQ === "WEEKLY") {
    const days = (r.BYDAY ? r.BYDAY.split(",").map((d: string) => WD.indexOf(d.slice(-2))) : [base.getDay()]).sort();
    const week0 = new Date(base); week0.setDate(base.getDate() - base.getDay());
    for (let w = 0; n < count; w += iv) {
      const ws = new Date(week0); ws.setDate(week0.getDate() + w * 7);
      if (ws.getTime() > to || ws.getTime() > until) break;
      for (const d of days) {
        const x = new Date(ws); x.setDate(ws.getDate() + d); x.setHours(base.getHours(), base.getMinutes(), base.getSeconds());
        if (x.getTime() < s0 || n >= count) continue; push(x.getTime());
      }
    }
    return out;
  }
  for (let k = 0; n < count && k < 5000; k++) {
    const x = new Date(base);
    if (r.FREQ === "DAILY") x.setDate(base.getDate() + k * iv);
    else if (r.FREQ === "MONTHLY") x.setMonth(base.getMonth() + k * iv);
    else if (r.FREQ === "YEARLY") x.setFullYear(base.getFullYear() + k * iv);
    else { push(s0); break; }
    if (x.getTime() > to || x.getTime() > until) break; push(x.getTime());
  }
  return out;
}

async function calendar() {
  const cals = calList(); if (!cals.length) return { configured: false, cals: [], events: [] };
  const from = new Date(new Date().setHours(0, 0, 0, 0)).getTime(), to = from + DAYS_AHEAD * 864e5;
  const errors: string[] = [], events: any[] = [];
  await Promise.all(cals.map(async (c, idx) => {
    try {
      let hit = calCache.get(c.url);
      if (!hit || Date.now() - hit.at > 5 * 60e3) {
        const r = await fetch(c.url, { signal: AbortSignal.timeout(10000) });
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        hit = { at: Date.now(), text: await r.text() }; calCache.set(c.url, hit);
      }
      events.push(...parseIcs(hit.text, String(idx), from, to));
    } catch (e: any) { errors.push(`${c.name}: ${e.message}`); }
  }));
  return { configured: true, cals: cals.map((c, i) => ({ id: String(i), name: c.name })), errors,
    events: events.sort((a, b) => a.start - b.start) };
}

function calOp(b: any) {
  const cals = calList();
  if (b.op === "add") {
    const url = String(b.url ?? "").trim().replace(/^webcal:/, "https:");
    if (!/^https:\/\/\S+$/.test(url)) throw new Error("Pegá la dirección iCal (empieza con https://)");
    cals.push({ url, name: String(b.name ?? "").replace(/\s+/g, " ").trim() || "Calendario" });
  } else if (b.op === "delete") cals.splice(Number(b.id), 1);
  else throw new Error("Operación desconocida");
  mkdirSync(CONF_DIR, { recursive: true });
  writeFileSync(CAL_FILE, cals.map(c => `${c.url} ${c.name}`).join("\n") + (cals.length ? "\n" : ""), { mode: 0o600 });
  calCache.clear();
}

// ---- Foco de hoy ---------------------------------------------------------------
// Hasta 3 tareas elegidas para hoy. panel-foco: "AAAA-MM-DD<TAB>proyecto<TAB>scope<TAB>1ª línea".
// Se guarda la línea de la tarea (no su posición) para que sobreviva a ediciones del TASKS.md.
const FOCO_MAX = 3;
const focoAll = () => read(listFile("foco")).split("\n").filter(Boolean).map(l => l.split("\t")).filter(p => p.length === 4).map(([day, project, scope, key]) => ({ day, project, scope, key }));
const foco = () => focoAll().filter(f => f.day === today());

function focoOp(b: any) {
  const key = String(b.key ?? "").trim(), project = String(b.project ?? ""), scope = b.scope === "mine" ? "mine" : "shared";
  if (!key || !projectDirs().includes(project)) throw new Error("Tarea desconocida");
  const same = (f: { project: string; scope: string; key: string }) => f.project === project && f.scope === scope && f.key === key;
  let list = foco();
  if (b.op === "add") {
    if (list.some(same)) return;
    if (list.length >= FOCO_MAX) throw new Error(`Máximo ${FOCO_MAX} cosas por día — sacá una primero`);
    list.push({ day: today(), project, scope, key });
  } else if (b.op === "remove") list = list.filter(f => !same(f));
  else throw new Error("Operación desconocida");
  mkdirSync(CONF_DIR, { recursive: true }); // solo se guarda el día de hoy: el foco no se arrastra
  writeFileSync(listFile("foco"), list.map(f => [f.day, f.project, f.scope, f.key.replace(/[\t\n]/g, " ")].join("\t")).join("\n") + "\n");
}

// ---- Compu -------------------------------------------------------------------
// Disco y memoria ahora + una línea por día en compu.log ("AAAA-MM-DD <GB libres>")
// para ver cómo evoluciona el espacio libre.
const COMPU_LOG = join(CONF_DIR, "compu.log");
// Bun 1.2.21 segfaulteó con Bun.spawnSync en macOS: disco por statfs (sin procesos),
// vm_stat con spawn async.
const sh = async (cmd: string[]) => { try { return await new Response(Bun.spawn(cmd, { stdout: "pipe", stderr: "ignore" }).stdout).text(); } catch { return ""; } };

async function compu() {
  const GB = 1024 ** 3;
  const fs = statfsSync("/");
  // "Usado" como lo cuenta df: total menos lo disponible para el usuario.
  const disk = { total: fs.blocks * fs.bsize / GB, free: fs.bavail * fs.bsize / GB, used: 0 };
  disk.used = disk.total - disk.free;
  // vm_stat: libre real = free + inactive + speculative + purgeable (macOS los reclama al toque).
  const vm = await sh(["vm_stat"]); const page = Number(vm.match(/page size of (\d+)/)?.[1] ?? 16384);
  const pg = (k: string) => Number(vm.match(new RegExp(`Pages ${k}:\\s+(\\d+)`))?.[1] ?? 0);
  const memTotal = totalmem() / GB;
  const memFree = (pg("free") + pg("inactive") + pg("speculative") + pg("purgeable")) * page / GB;
  const mem = { total: memTotal, used: Math.max(0, memTotal - memFree) };

  const log = read(COMPU_LOG).split("\n").map(l => l.split(" ")).filter(p => /^\d{4}-\d{2}-\d{2}$/.test(p[0])).map(([day, gb]) => ({ day, free: Number(gb) }));
  if (log.at(-1)?.day !== today()) {
    mkdirSync(CONF_DIR, { recursive: true });
    appendFileSync(COMPU_LOG, `${today()} ${disk.free.toFixed(1)}\n`);
    log.push({ day: today(), free: disk.free });
  } else log[log.length - 1].free = disk.free;
  return { disk, mem, history: log.slice(-30) };
}

// ---- Página de proyecto: git + ficha (FICHA.local.md) + historial (SESSION.md) ----
// git con Bun.spawn async (spawnSync crasheó Bun 1.2.21), en paralelo y con timeout:
// si un comando falla o tarda, esa parte vuelve null y el resto sigue.
async function run(cmd: string[], cwd: string, ms = 3000): Promise<string | null> {
  try {
    const p = Bun.spawn(cmd, { cwd, stdout: "pipe", stderr: "ignore", stdin: "ignore",
      env: { ...process.env, GIT_OPTIONAL_LOCKS: "0", GIT_TERMINAL_PROMPT: "0", GH_PROMPT_DISABLED: "1" } });
    const t = setTimeout(() => p.kill(), ms);
    const out = await new Response(p.stdout).text(); const code = await p.exited; clearTimeout(t);
    return code === 0 ? out : null;
  } catch { return null; }
}
const git = (dir: string, ...a: string[]) => run(["git", ...a], dir);
const SEP = "\x1f";
// Solo el link canónico: nunca se manda la URL cruda del remoto (puede llevar un token).
function githubUrl(remote: string) {
  const m = remote.match(/github\.com[:/]+([\w.-]+)\/([\w.-]+?)(?:\.git)?\/?$/);
  return m ? `https://github.com/${m[1]}/${m[2]}` : null;
}
async function commits(dir: string, skip = 0, n = 10) {
  const out = await git(dir, "log", `--skip=${skip}`, `-n${n}`, `--format=%H${SEP}%an${SEP}%cI${SEP}%s`);
  return out === null ? null : out.split("\n").filter(Boolean).map(l => { const [hash, author, date, msg] = l.split(SEP); return { hash, author: author.split(/\s+/)[0], date, msg }; });
}

async function gitInfo(dir: string) {
  if (!existsSync(join(dir, ".git"))) return null;
  const [branch, status, remotes, track, log, refs, upRefs] = await Promise.all([
    git(dir, "branch", "--show-current"), git(dir, "status", "--porcelain"), git(dir, "remote", "-v"),
    git(dir, "rev-list", "--left-right", "--count", "@{u}...HEAD"), commits(dir),
    git(dir, "for-each-ref", "refs/heads", `--format=%(refname:short)${SEP}%(committerdate:iso-strict)`),
    git(dir, "for-each-ref", "refs/remotes", `--format=%(refname:short)${SEP}%(committerdate:iso-strict)`),
  ]);
  const remote = remotes?.split("\n").find(l => l.endsWith("(fetch)"))?.split(/\s+/)[1] ?? "";
  const gh = githubUrl(remote);
  const files = status === null ? null : status.split("\n").filter(Boolean).map(l => l.slice(3).replace(/^.* -> /, "").replace(/^"|"$/g, ""));
  const [behind, ahead] = track ? track.trim().split(/\s+/).map(Number) : [null, null];
  // Ramas del remoto ("origin/x" → "x"), sin "origin/HEAD" ni el remoto pelado.
  const remoteRefs = (upRefs ?? "").split("\n").filter(Boolean).map(l => { const [ref, date] = l.split(SEP); return { ref, name: ref.replace(/^[^/]+\//, ""), date }; })
    .filter(r => r.ref.includes("/") && r.name !== "HEAD");
  const remoteBranches = new Set(remoteRefs.map(r => r.name));
  const local = (refs ?? "").split("\n").filter(Boolean).map(l => { const [name, date] = l.split(SEP); return { name, date, ref: name, remoteOnly: false }; });
  const base = ["main", "master"].find(b => local.some(l => l.name === b)) ?? null;
  // Ramas: las locales (≤ 25) + las que existen solo en GitHub (≤ 15, las más nuevas); adelante/atrás de main en paralelo.
  const localNames = new Set(local.map(l => l.name));
  const onlyRemote = remoteRefs.filter(r => !localNames.has(r.name)).sort((a, b) => b.date.localeCompare(a.date)).slice(0, 15).map(r => ({ ...r, remoteOnly: true }));
  const list = [...local.sort((a, b) => (b.name === branch?.trim() ? 1 : 0) - (a.name === branch?.trim() ? 1 : 0) || b.date.localeCompare(a.date)).slice(0, 25), ...onlyRemote];
  const hasGh = !!gh && !!Bun.which("gh");
  const [merged, counts, prs, mergedPrs] = await Promise.all([
    base ? git(dir, "branch", "--merged", base, "--format=%(refname:short)") : null,
    Promise.all(list.map(l => base && l.name !== base ? git(dir, "rev-list", "--left-right", "--count", `${base}...${l.ref}`) : null)),
    hasGh ? run(["gh", "pr", "list", "--state", "open", "--json", "number,title,headRefName,author,createdAt,updatedAt,isDraft,url"], dir, 5000) : null,
    // Squash merge no deja rastro en git: las ramas de PRs mergeados también cuentan como mergeadas.
    hasGh ? run(["gh", "pr", "list", "--state", "merged", "--limit", "200", "--json", "headRefName"], dir, 5000) : null,
  ]);
  const mergedSet = new Set((merged ?? "").split("\n").map(s => s.trim()).filter(Boolean));
  try { if (mergedPrs) for (const p of JSON.parse(mergedPrs)) mergedSet.add(p.headRefName); } catch {}
  let pulls = null;
  try { if (prs) pulls = (JSON.parse(prs) as any[]).map(p => ({ number: p.number, title: p.title, branch: p.headRefName, author: p.author?.name?.split(/\s+/)[0] || p.author?.login || "", created: p.createdAt ?? null, updated: p.updatedAt, draft: !!p.isDraft, url: /^https:\/\/github\.com\//.test(p.url) ? p.url : null })); } catch {}
  return {
    branch: branch?.trim() || null, files, behind, ahead, hasRemote: remotes !== null ? !!remote : null,
    upstream: track !== null, github: gh, commits: log, base, pulls,
    // Última vez que se trajo del remoto (FETCH_HEAD se toca en cada fetch/pull).
    fetched: existsSync(join(dir, ".git/FETCH_HEAD")) ? statSync(join(dir, ".git/FETCH_HEAD")).mtime.toISOString() : null,
    branches: list.map((l, i) => { const c = counts[i]?.trim().split(/\s+/).map(Number);
      return { name: l.name, date: l.date, current: l.name === branch?.trim(), behind: c?.[0] ?? null, ahead: c?.[1] ?? null, remoteOnly: l.remoteOnly,
        merged: !!base && l.name !== base && (mergedSet.has(l.name) || (l.remoteOnly && c?.[1] === 0)), pushed: remoteBranches.has(l.name) }; })
      // Las que están solo en GitHub y ya se mergearon son ruido: no se muestran.
      .filter(b => !(b.remoteOnly && b.merged)),
  };
}

// "Desde tu última visita": commits de todas las ramas (sin stash) desde `since`, agrupados por autor
// con el nombre corto, y las ramas (locales o del remoto) que se movieron. Los PRs salen de gitInfo.
const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d{1,3})?)?(?:Z|[+-]\d{2}:\d{2})$/;
const shortName = (a: string) => { const t = (a.split(/\s+/)[0] || a).replace(/[\d_-].*$/, "") || a; return t.charAt(0).toUpperCase() + t.slice(1); };
async function recent(dir: string, since: string) {
  if (!existsSync(join(dir, ".git")) || !ISO.test(since) || isNaN(Date.parse(since))) return null;
  const LIMIT = 200;
  const [log, refs] = await Promise.all([
    git(dir, "log", "--branches", "--remotes", `--since=${since}`, "--no-merges", `-n${LIMIT + 1}`, `--format=%H${SEP}%an${SEP}%cI${SEP}%s`),
    git(dir, "for-each-ref", "refs/heads", "refs/remotes", `--format=%(refname)${SEP}%(committerdate:iso-strict)`),
  ]);
  const rows = (log ?? "").split("\n").filter(Boolean).map(l => { const [hash, author, date, msg] = l.split(SEP); return { hash, author: shortName(author), date, msg }; });
  const byAuthor = new Map<string, { name: string; count: number; samples: { hash: string; msg: string }[] }>();
  for (const c of rows.slice(0, LIMIT)) {
    const a = byAuthor.get(c.author) ?? { name: c.author, count: 0, samples: [] }; byAuthor.set(c.author, a);
    a.count++; if (a.samples.length < 2 && !a.samples.some(x => x.msg === c.msg)) a.samples.push({ hash: c.hash, msg: c.msg });
  }
  const t = Date.parse(since), moved = new Map<string, { name: string; date: string; local: boolean; remote: boolean }>();
  for (const l of (refs ?? "").split("\n").filter(Boolean)) {
    const [ref, date] = l.split(SEP); const local = ref.startsWith("refs/heads/");
    const name = local ? ref.slice("refs/heads/".length) : ref.replace(/^refs\/remotes\/[^/]+\/?/, "");
    if (!name || name === "HEAD") continue;
    const m = moved.get(name) ?? { name, date: "", local: false, remote: false }; moved.set(name, m);
    if (local) m.local = true; else m.remote = true;
    if (!m.date || Date.parse(date) > Date.parse(m.date)) m.date = date;
  }
  for (const [k, m] of moved) if (Date.parse(m.date) < t) moved.delete(k);
  return { since, total: Math.min(rows.length, LIMIT), more: rows.length > LIMIT,
    authors: [...byAuthor.values()].sort((a, b) => b.count - a.count),
    branches: [...moved.values()].sort((a, b) => Date.parse(b.date) - Date.parse(a.date)) };
}

// Historial: SESSION.md en sus distintos formatos → [{date, text}] legible, más reciente primero.
//   "- 2026-10-13 — …"   "## 2026-10-23 (noche) — …"   "## 13/10 (mar) — …"   "### 2026-10-10 — …"   "# Sesión 2026-04-30"
const DATE = String.raw`(\d{4}-\d{2}-\d{2}|\d{1,2}\/\d{1,2}(?:\/\d{2,4})?)`;
function isoOf(d: string, year: number) {
  if (/^\d{4}-/.test(d)) return d;
  const [dd, mm, yy] = d.split("/"); let y = yy ? Number(yy.length === 2 ? "20" + yy : yy) : year;
  const iso = (yy: number) => `${yy}-${mm.padStart(2, "0")}-${dd.padStart(2, "0")}`;
  if (!yy && iso(y) > today()) y--;
  return iso(y);
}
function cleanEntry(s: string) {
  let t = s.replace(/^\s*\*\*([^*]{8,}?)\*\*/, "$1 — ") // "**Título.** resto" → título
    .replace(/(?:\s(?:de|del|en|a|al|con|el|la|los|las|por))?\s*`[^`]*`/gi, " ").replace(/\[([^\]]+)\]\([^)]*\)/g, "$1").replace(/https?:\/\/\S+/g, " ")
    .replace(/\*\*|__/g, "").replace(/\p{Extended_Pictographic}️?/gu, " ")
    .replace(/\(([^()]*)\)/g, (m, inner) => /#\d|\/|\b(?=[0-9a-f]*\d)(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}\b|\.\w{2,4}\b|^[A-ZÁÉÍÓÚ\s]+$/.test(inner) ? " " : m)
    .replace(/(?:\s(?:de|del|en|el|al|con|por))?\s*\bPRs?\s+#?\d+(?:\s*(?:[–→,-]|y)\s*#?\d+)*/g, " ").replace(/#\d+(?:\s*[–→-]+\s*#?\d+)?/g, " ")
    .replace(/\b(?=[0-9a-f]*\d)(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}\b/g, " ")
    .replace(/(?:^|\s)(?:~|\.{1,2})?\/[\w.@/-]+/g, " ").replace(/\b[\w.-]+\/[\w.-]+\/[\w./-]*/g, " ").replace(/\b[\w-]+\/[\w-]+\.\w+\b/g, " ")
    .replace(/\b[\w-]+\.(?:tsx?|jsx?|mjs|md|json|ya?ml|py|sh|sql|css|html|env|toml|lock|mp4)\b/g, " ")
    .replace(/^\s*blocker:/i, "Bloqueo:").replace(/project scaffolded with the Dublin operating model\.?/i, "Arranque del proyecto")
    .replace(/\(([^()]*?)[\s,;]+\)/g, "($1)").replace(/\(\s*[,;.]?\s*\)/g, " ").replace(/\s+([,.;:)»])/g, "$1").replace(/([(«])\s+/g, "$1").replace(/\s{2,}/g, " ").trim();
  t = t.replace(/^[\s—–:;,.·-]+/, "");
  const dot = t.indexOf(" · "); if (dot >= 12) t = t.slice(0, dot); // "Título · PR … en prod"
  t = t.replace(/:\s*\S+$/, m => m.length <= 14 ? "" : m); // "…: abiertos" (lo demás se fue al limpiar)
  const cut = t.search(/(?<=[.!?])\s| — |; /);
  if (cut >= 15) t = t.slice(0, cut);
  t = t.replace(/\s*\(COMPLETADO\)|COMPLETADO,\s*/g, "").replace(/[\s—–:;,(·→-]+$/, "").replace(/\.$/, "");
  if (t.length > 130) t = t.slice(0, 130).replace(/\s+\S*$/, "") + "…";
  if (t.replace(/[^\p{L}]/gu, "").length >= 3 && t === t.toUpperCase()) t = t.toLowerCase(); // TÍTULO EN MAYÚSCULAS
  t = t.charAt(0).toUpperCase() + t.slice(1);
  return t.replace(/[^\p{L}]/gu, "").length >= 6 && /\p{L}{3}/u.test(t) ? t : "";
}
function history(dir: string) {
  const sf = readdirSync(dir).find(f => f.toLowerCase() === "session.md"); if (!sf) return [];
  const file = join(dir, sf), year = statSync(file).mtime.getFullYear();
  const lines = read(file).split("\n"), raw: { date: string; text: string }[] = [];
  const head = new RegExp(String.raw`^(#{1,4})\s+(?:Sesi[oó]n\s+)?${DATE}(.*)$`, "i");
  const bullet = new RegExp(String.raw`^[-*]\s+(?:\*\*)?${DATE}(?:\*\*)?(.*)$`);
  let inDated = false, pending: { date: string; text: string } | null = null;
  for (let i = 0; i < lines.length; i++) {
    const l = lines[i], h = l.match(head);
    if (h) {
      inDated = true;
      const rest = h[3].replace(/^\s*(?:→\s*[\d\/-]+\s*)?(?:\([^)]*\)\s*)*/, "").replace(/^[\s—–:·-]+/, "");
      pending = { date: isoOf(h[2], year), text: rest }; raw.push(pending);
      if (rest) pending = null; continue;
    }
    if (/^#{1,2}\s/.test(l)) { if (pending) pending.text = l.replace(/^#+\s*/, ""); inDated = false; pending = null; continue; }
    if (/^#/.test(l)) continue;
    if (pending && l.trim() && !/^(\*\*[^*]+\*\*:?|---)\s*$/.test(l.trim())) { pending.text = l.replace(/^\s*[-*]\s+/, ""); pending = null; continue; }
    const b = !inDated && l.match(bullet);
    if (b) {
      let text = b[2]; while (i + 1 < lines.length && /^\s+\S/.test(lines[i + 1]) && !/^\s+[-*]\s/.test(lines[i + 1])) text += " " + lines[++i].trim();
      raw.push({ date: isoOf(b[1], year), text: text.replace(/^\*\*/, "**").replace(/^\s*(?:\([^)]*\)\s*)*/, "") });
    }
  }
  // Para fechas iguales: si el archivo va de viejo a nuevo, lo último anotado va primero.
  const asc = raw.length > 1 && raw[0].date < raw.at(-1)!.date;
  return raw.map((e, i) => ({ ...e, i, text: cleanEntry(e.text.replace(/^[\s—–:·-]+/, "").replace(/^\*\*\s*[—–:-]?\s*/, "")) }))
    .filter(e => e.text)
    .sort((a, b) => b.date.localeCompare(a.date) || (asc ? b.i - a.i : a.i - b.i))
    .slice(0, 200).map(({ date, text }) => ({ date, text }));
}

// Ficha: FICHA.local.md (gitignored), editable a mano. Las claves/secciones que el panel
// no conoce se conservan tal cual al guardar.
const FICHA_KEYS: [string, string][] = [["nombre", "Nombre"], ["contacto", "Contacto"], ["cobro", "Cobro"]];
const fichaFile = (p: string) => join(PROJECTS, p, "FICHA.local.md");
function parseFicha(md: string) {
  const out = { cliente: [] as [string, string][], links: [] as { label: string; url: string }[], notas: "", extra: [] as string[] };
  let sec = "";
  for (const l of md.split("\n")) {
    if (/^# /.test(l)) continue;
    const h = l.match(/^## (.+?)\s*$/); if (h) { sec = h[1].toLowerCase(); if (!["cliente", "links", "notas"].includes(sec)) out.extra.push(l); continue; }
    const kv = l.match(/^- ([^:]+):\s*(.*)$/);
    if (sec === "cliente" && kv) out.cliente.push([kv[1].trim(), kv[2].trim()]);
    else if (sec === "links" && kv && /^https?:\/\//.test(kv[2].trim())) out.links.push({ label: kv[1].trim(), url: kv[2].trim() });
    else if (sec === "notas") out.notas += l + "\n";
    else if (sec && !["cliente", "links", "notas"].includes(sec)) out.extra.push(l);
  }
  out.notas = out.notas.trim();
  return out;
}
function ficha(project: string) {
  const f = fichaFile(project), exists = existsSync(f), p = parseFicha(exists ? read(f) : "");
  const get = (k: string) => p.cliente.find(([key]) => key.toLowerCase() === k.toLowerCase())?.[1] ?? "";
  return { exists, mtime: exists ? statSync(f).mtimeMs : 0, nombre: get("Nombre"), contacto: get("Contacto"), cobro: get("Cobro"), notas: p.notas, links: p.links };
}
function fichaOp(b: any) {
  if (!projectDirs().includes(b.project)) throw new Error("Proyecto desconocido");
  const f = fichaFile(b.project), exists = existsSync(f);
  if (exists && Number(b.mtime) !== statSync(f).mtimeMs) throw new Error("La ficha cambió — recargá");
  const one = (v: unknown, max = 200) => { const s = String(v ?? "").trim(); if (/[\r\n]/.test(s)) throw new Error("Sin saltos de línea en los campos"); if (s.length > max) throw new Error("Campo demasiado largo"); return s; };
  const notas = String(b.notas ?? "").replace(/\r/g, "").trim();
  if (notas.split("\n").some(l => /^#/.test(l))) throw new Error("Las notas no pueden tener líneas que empiecen con #");
  if (notas.length > 5000) throw new Error("Notas demasiado largas");
  const links = (Array.isArray(b.links) ? b.links : []).map((l: any) => ({ label: one(l?.label, 60).replace(/:/g, " "), url: one(l?.url, 500) }))
    .filter((l: any) => l.label || l.url).map((l: any) => {
      let ok = false; try { ok = /^https?:$/.test(new URL(l.url).protocol) && !/\s/.test(l.url); } catch {}
      if (!ok) throw new Error(`Link inválido: ${l.label || l.url} (tiene que empezar con http:// o https://)`);
      return { label: l.label || new URL(l.url).hostname, url: l.url };
    });
  const p = parseFicha(exists ? read(f) : "");
  const vals: Record<string, string> = Object.fromEntries(FICHA_KEYS.map(([k]) => [k, one(b[k])]));
  const known = new Set(FICHA_KEYS.map(([, l]) => l.toLowerCase()));
  const cliente = [...FICHA_KEYS.filter(([k]) => vals[k]).map(([k, l]) => [l, vals[k]]), ...p.cliente.filter(([k]) => !known.has(k.toLowerCase()))];
  const name = readList("alias").map(l => l.trim().split(/\s+/)).find(([k]) => k === b.project)?.slice(1).join(" ")
    || basename(b.project).replace(/[-_]+/g, " ").replace(/(^|\s)\p{L}/gu, c => c.toUpperCase());
  const md = [`# Ficha — ${name}`, "", "## Cliente", ...cliente.map(([k, v]) => `- ${k}: ${v}`), "", "## Links", ...links.map((l: any) => `- ${l.label}: ${l.url}`), "", "## Notas", ...(notas ? [notas] : []), "",
    ...(p.extra.length ? [p.extra.join("\n").trim(), ""] : [])].join("\n");
  writeFileSync(f, md);
  ignoreLocal(join(PROJECTS, b.project)); // contacto y cobro nunca se commitean
}

// ---- Server ------------------------------------------------------------------
const json = (d: unknown, status = 200) => Response.json(d, { status });
const ORIGINS = [`http://127.0.0.1:${PORT}`, `http://localhost:${PORT}`];

Bun.serve({
  hostname: "127.0.0.1", port: PORT, idleTimeout: 255,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/") return new Response(Bun.file(join(import.meta.dir, "panel.html")));
    if (req.method === "GET" && url.pathname === "/api/state") {
      const month = /^\d{4}-\d{2}$/.test(url.searchParams.get("month") ?? "") ? url.searchParams.get("month")! : today().slice(0, 7);
      return json({ today: today(), user: USER, roots: { projects: PROJECTS },
        pinned: readList("pinned"), archived: readList("archived"), order: readList("order"),
        projects: projects(), mcps: mcps(), finanzas: finanzas(month), facturas: facturas(), mascotas: mascotas(), estudio: estudio(), nutricion: nutricion(), flujos: flujos(), contenido: contenido(), dayOfWeek: dayOf(today()), compu: await compu(), foco: foco(),
        // panel-alias: "carpeta Nombre visible" por línea (ej. "mi_app_v2 Mi App").
        alias: Object.fromEntries(readList("alias").map(l => l.trim().split(/\s+/)).filter(p => p.length > 1).map(([k, ...v]) => [k, v.join(" ")])) });
    }
    if (req.method === "GET" && url.pathname.startsWith("/api/proj")) {
      const name = url.searchParams.get("name") ?? "";
      if (!projectDirs().includes(name)) return json({ error: "Proyecto desconocido" }, 404);
      const dir = join(PROJECTS, name);
      if (url.pathname === "/api/proj/commits") {
        const skip = Math.max(0, Number(url.searchParams.get("skip")) || 0);
        return json(existsSync(join(dir, ".git")) ? await commits(dir, skip, 20) ?? [] : []);
      }
      if (url.pathname === "/api/proj/recent") return json(await recent(dir, url.searchParams.get("since") ?? ""));
      if (url.pathname === "/api/proj") return json({ name, git: await gitInfo(dir), ficha: ficha(name), history: history(dir) });
    }
    if (req.method === "GET" && url.pathname === "/api/libro") {
      const p = libroPdf(url.searchParams.get("c") ?? "", url.searchParams.get("f") ?? "");
      return p ? new Response(Bun.file(p), { headers: { "content-type": "application/pdf" } }) : json({ error: "No existe" }, 404);
    }
    if (req.method === "GET" && url.pathname === "/api/calendar") return json(await calendar());
    if (req.method === "POST") {
      // Solo la propia página: otro sitio abierto en el navegador no puede escribir tus archivos.
      if (!ORIGINS.includes(req.headers.get("origin") ?? "") || !req.headers.get("content-type")?.includes("application/json")) return json({ error: "Origen no permitido" }, 403);
      try {
        const b = await req.json();
        if (url.pathname === "/api/task") { taskOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/fin") { finOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/mascota") { mascotaOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/estudio") { estudioOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/nutricion") { nutricionOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/contenido") { contenidoOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/flujos") {
          if (b.op === "import") return json(flujoImport(b.text));
          if (b.op === "share") return json(await flujoShare(b));
          flujosOp(b); return json({ ok: true });
        }
        if (url.pathname === "/api/factura") { await facturaOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/project") { projectOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/cal") { calOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/foco") { focoOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/ficha") { fichaOp(b); return json({ ok: true }); }
        if (url.pathname === "/api/fetch") { // git fetch: trae lo nuevo de GitHub sin tocar el código local
          if (!projectDirs().includes(b.name) || !existsSync(join(PROJECTS, b.name, ".git"))) throw new Error("Proyecto desconocido");
          if (await run(["git", "fetch", "--prune", "--quiet"], join(PROJECTS, b.name), 30000) === null) throw new Error("No pude actualizar: sin conexión o sin acceso al repo");
          return json({ ok: true });
        }
        if (url.pathname === "/api/pull") { // git pull seguro: solo fast-forward; si no se puede, no toca nada
          if (!projectDirs().includes(b.name) || !existsSync(join(PROJECTS, b.name, ".git"))) throw new Error("Proyecto desconocido");
          const dir = join(PROJECTS, b.name);
          await run(["git", "fetch", "--quiet"], dir, 30000);
          const counts = await git(dir, "rev-list", "--left-right", "--count", "@{u}...HEAD");
          if (counts === null) throw new Error("Esta rama no está subida a GitHub");
          const [behind, ahead] = counts.trim().split(/\s+/).map(Number);
          if (!behind) return json({ ok: true, pulled: 0 });
          if (ahead) throw new Error("Tu rama y GitHub tienen cambios distintos: hay que unirlos a mano");
          if (await run(["git", "merge", "--ff-only", "--quiet", "@{u}"], dir, 30000) === null)
            throw new Error("No traje nada: tenés cambios sin commitear en archivos que también cambiaron en GitHub");
          return json({ ok: true, pulled: behind });
        }
      } catch (e: any) { return json({ error: e.message }, 400); }
    }
    return json({ error: "No existe" }, 404);
  },
});
console.log(`Panel en http://127.0.0.1:${PORT}  (Ctrl+C para cerrar)`);
