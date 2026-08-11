import { useInfiniteQuery, useQuery } from "@tanstack/react-query";

export type Article = {
  id: string;
  title: string;
  excerpt: string;
  body: string;
  imageUrl: string;
  author: string;
  publishedAt: string;
  readingMinutes: number;
};

export type Page = { items: Article[]; nextCursor?: string };

/**
 * EXPO_PUBLIC_* values are inlined into the JS bundle at build time and are
 * readable by anyone who downloads the app. Never put a secret here.
 * Leave it unset to run against the local fixture below.
 */
const API_URL = process.env.EXPO_PUBLIC_API_URL;

export const articleKeys = {
  all: ["articles"] as const,
  feed: () => [...articleKeys.all, "feed"] as const,
  detail: (id: string) => [...articleKeys.all, "detail", id] as const,
};

async function fetchPage(cursor?: string): Promise<Page> {
  if (!API_URL) return mockPage(cursor);

  const url = new URL("/articles", API_URL);
  if (cursor) url.searchParams.set("cursor", cursor);

  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`GET /articles failed with ${res.status}`);
  return (await res.json()) as Page;
}

async function fetchArticle(id: string): Promise<Article> {
  if (!API_URL) return mockArticle(id);

  const res = await fetch(new URL(`/articles/${id}`, API_URL).toString());
  if (!res.ok) throw new Error(`GET /articles/${id} failed with ${res.status}`);
  return (await res.json()) as Article;
}

export function useFeed() {
  return useInfiniteQuery({
    queryKey: articleKeys.feed(),
    queryFn: ({ pageParam }) => fetchPage(pageParam),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (last) => last.nextCursor,
  });
}

export function useArticle(id: string) {
  return useQuery({
    queryKey: articleKeys.detail(id),
    queryFn: () => fetchArticle(id),
    enabled: Boolean(id),
  });
}

/* ------------------------------------------------------------------ *
 * Fixture data — lets the boilerplate run with no backend.
 * Delete this block once EXPO_PUBLIC_API_URL points at a real API.
 * ------------------------------------------------------------------ */

const FIXTURES: Article[] = [
  {
    id: "1947",
    title: "Cómo Despegar rediseñó su checkout y bajó el abandono 18%",
    excerpt:
      "Sacaron cuatro campos del formulario y movieron el resumen de precio arriba del fold. El resto fue medir.",
    body: "El equipo arrancó mirando la grabación de 200 sesiones en mobile. El patrón se repetía: el usuario llegaba al paso de pago, hacía scroll buscando el total, no lo encontraba y volvía atrás.\n\nLa hipótesis fue simple: el precio final tiene que estar visible sin scroll en 360px. La implementación llevó dos sprints, la mayoría en reordenar validaciones que asumían un orden de campos fijo.\n\nEl abandono en el paso de pago pasó de 41,3% a 33,9% en ocho semanas.",
    imageUrl: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800",
    author: "Camila Pereyra",
    publishedAt: "2026-07-28",
    readingMinutes: 6,
  },
  {
    id: "1946",
    title: "Postgres en un VPS de 4 GB: hasta dónde llega antes de doler",
    excerpt:
      "Medimos una tabla de 12 millones de filas con índices mal puestos, y después bien puestos. La diferencia sorprende.",
    body: "Arrancamos con una consulta de 2,4 segundos sobre 12 millones de filas. Un índice compuesto sobre (tenant_id, created_at) la bajó a 31 ms.\n\nEl punto no es el índice: es que nadie había mirado el plan de ejecución en catorce meses.",
    imageUrl: "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800",
    author: "Tomás Arias",
    publishedAt: "2026-07-21",
    readingMinutes: 9,
  },
  {
    id: "1945",
    title: "El costo real de elegir Next.js cuando alcanzaba con Astro",
    excerpt:
      "Un sitio institucional de 14 páginas, sin sesión y sin datos en vivo. Comparamos build time, bundle y factura mensual.",
    body: "El sitio original tardaba 3 minutos 40 en buildear y servía 187 KB de JS a un visitante que solo quería leer la página de contacto.\n\nMigrado a Astro con dos islas, el build bajó a 22 segundos y el JS a 4 KB. El VPS pasó de necesitar 2 GB de RAM a andar cómodo en 512 MB.",
    imageUrl: "https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=800",
    author: "Camila Pereyra",
    publishedAt: "2026-07-14",
    readingMinutes: 7,
  },
  {
    id: "1944",
    title: "Mercado Libre y el arte de no romper la app en producción",
    excerpt: "Feature flags, rollout por porcentaje y un botón de rollback que alguien realmente probó.",
    body: "La parte interesante no es el sistema de flags. Es la regla interna: ningún flag nuevo se mergea sin que alguien haya ejecutado el rollback en staging esa misma semana.",
    imageUrl: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800",
    author: "Sofía Bianchi",
    publishedAt: "2026-07-03",
    readingMinutes: 5,
  },
];

const PAGE_SIZE = 2;

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function mockPage(cursor?: string): Promise<Page> {
  await delay(600);
  const start = cursor ? Number(cursor) : 0;
  const items = FIXTURES.slice(start, start + PAGE_SIZE);
  const next = start + PAGE_SIZE;
  return { items, nextCursor: next < FIXTURES.length ? String(next) : undefined };
}

async function mockArticle(id: string): Promise<Article> {
  await delay(300);
  const found = FIXTURES.find((a) => a.id === id);
  if (!found) throw new Error(`Article ${id} not found`);
  return found;
}
