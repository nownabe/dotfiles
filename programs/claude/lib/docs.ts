// Each CLI serves the Markdown under docs/<cli>/ from the working tree, so
// the index and pages are always the ones checked in here, with no build step.
export const DOCS_ROOT = new URL("../docs/", import.meta.url);

/** Doc names are paths under the CLI's docs dir without `.md`, e.g. `gh/get-release`. */
export async function listDocs(dir: URL): Promise<string[]> {
  const names: string[] = [];
  async function walk(current: URL, prefix: string): Promise<void> {
    for await (const entry of Deno.readDir(current)) {
      const child = new URL(entry.name + (entry.isDirectory ? "/" : ""), current);
      if (entry.isDirectory) {
        await walk(child, `${prefix}${entry.name}/`);
      } else if (entry.name.endsWith(".md")) {
        names.push(prefix + entry.name.slice(0, -".md".length));
      }
    }
  }
  await walk(dir, "");
  return names.sort();
}

/** The first sentence of the first paragraph after the title. */
export function summarize(markdown: string): string {
  const lines = markdown.split("\n");
  const start = lines.findIndex((line, i) => i > 0 && line.trim() && !line.startsWith("#"));
  if (start === -1) return "";
  const paragraph: string[] = [];
  for (const line of lines.slice(start)) {
    if (!line.trim()) break;
    paragraph.push(line.trim());
  }
  const text = paragraph.join(" ");
  const end = text.indexOf(". ");
  return end === -1 ? text : text.slice(0, end + 1);
}

export type Resolution =
  | { kind: "found"; name: string }
  | { kind: "ambiguous"; candidates: string[] }
  | { kind: "missing" };

/** Any trailing run of path segments identifies a doc as long as it is unique. */
export function resolveDoc(names: string[], query: string): Resolution {
  const normalized = query.replace(/^\/+|\/+$/g, "").replace(/\.md$/, "");
  if (names.includes(normalized)) return { kind: "found", name: normalized };
  const candidates = names.filter((name) => name.endsWith(`/${normalized}`));
  if (candidates.length === 1) return { kind: "found", name: candidates[0] };
  if (candidates.length > 1) return { kind: "ambiguous", candidates };
  return { kind: "missing" };
}

export async function renderIndex(cli: string, dir: URL): Promise<string> {
  const names = await listDocs(dir);
  const width = Math.max(...names.map((name) => name.length));
  const rows = await Promise.all(
    names.map(async (name) => {
      const markdown = await Deno.readTextFile(new URL(`${name}.md`, dir));
      return `${name.padEnd(width)}  ${summarize(markdown)}`;
    }),
  );
  return [
    `Read one with \`${cli} docs <name>\`; any unique trailing part of a name works.`,
    "",
    ...rows,
  ].join("\n");
}

/** Entry point for `<cli> docs [name...]`; `args` are the words after `docs`. */
export async function docsMain(cli: string, args: string[]): Promise<void> {
  const dir = new URL(`${cli}/`, DOCS_ROOT);
  // Words spell the same doc as a slash-separated path: `docs gh get-release`.
  const query = args.join("/");
  if (!query) {
    console.log(await renderIndex(cli, dir));
    return;
  }

  const resolution = resolveDoc(await listDocs(dir), query);
  switch (resolution.kind) {
    case "found":
      console.log(await Deno.readTextFile(new URL(`${resolution.name}.md`, dir)));
      return;
    case "ambiguous":
      console.error(`"${query}" matches several docs:`);
      for (const name of resolution.candidates) console.error(`  ${name}`);
      Deno.exit(1);
      break;
    case "missing":
      console.error(`No doc named "${query}". Run \`${cli} docs\` to list them.`);
      Deno.exit(1);
  }
}
