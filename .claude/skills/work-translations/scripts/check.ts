// Mechanical checks of translations.md that `bun run i18n:check` leaves out, scoped to the
// locale files changed against a ref (default HEAD: working tree plus untracked files).
//
//   bun check.ts [--fix] [ref]      run from inside hu-translations
//
// error  → a MUST broken; exit 1.
// review → a judgement call the caller resolves (TR-LOC-001 allows identical-by-nature values).
// note   → a touched file whose pre-existing order or format is off the standard, kept as is.
// --fix  → moves each new key to its sorted place among its neighbours and restores the
//          pre-existing order and the file's own format, so the diff carries only the change.

import { existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename } from "node:path";

type Json = string | number | boolean | null | Json[] | { [key: string]: Json };
type Obj = { [key: string]: Json };
type Flat = Map<string, string>;
type Style = { indent: string; newline: boolean };

const args = process.argv.slice(2);
const fix = args.includes("--fix");
const ref = args.find((arg) => !arg.startsWith("--")) ?? "HEAD";

const git = (...cmd: string[]) => {
  const out = Bun.spawnSync(["git", ...cmd], { cwd: root });
  return out.success ? out.stdout.toString() : null;
};

const root = Bun.spawnSync(["git", "rev-parse", "--show-toplevel"]).stdout.toString().trim();
if (!root || !existsSync(`${root}/locale/es`)) {
  console.error("work-translations check: run from inside hu-translations");
  process.exit(2);
}

const locales = readdirSync(`${root}/locale`, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

const lines = (out: string | null) => (out ?? "").split("\n").filter(Boolean);
const isNamespaceFile = (path: string) => /^locale\/[^/]+\/[^/]+\.json$/.test(path);

const changed = [
  ...lines(git("diff", "--name-only", "--diff-filter=d", ref, "--", "locale")),
  ...lines(git("ls-files", "--others", "--exclude-standard", "--", "locale")),
].filter(isNamespaceFile);
const deleted = lines(git("diff", "--name-only", "--diff-filter=D", ref, "--", "locale")).filter(
  isNamespaceFile,
);
const blacklistChanged = lines(git("diff", "--name-only", ref, "--", "config/mobile-blacklist.ts"));

const errors: string[] = [];
const reviews: string[] = [];
const notes: string[] = [];
const error = (rule: string, where: string, msg: string) => errors.push(`error  ${rule}  ${where}: ${msg}`);
const review = (rule: string, where: string, msg: string) => reviews.push(`review ${rule}  ${where}: ${msg}`);
const note = (rule: string, where: string, msg: string) => notes.push(`note   ${rule}  ${where}: ${msg}`);

const isObj = (value: Json | undefined): value is Obj =>
  value !== null && typeof value === "object" && !Array.isArray(value);

const sortDeep = (value: Json): Json => {
  if (!isObj(value)) return value;
  return Object.fromEntries(
    Object.keys(value)
      .sort()
      .map((key) => [key, sortDeep(value[key])]),
  );
};

// Pre-existing keys keep their order in `before`; each new key goes before the first key
// greater than it, so it sorts against both neighbours however unsorted the file is.
const place = (now: Json, before: Json | undefined): Json => {
  if (!isObj(now)) return now;
  if (!isObj(before)) return sortDeep(now);
  const order = Object.keys(before).filter((key) => key in now);
  for (const key of Object.keys(now)
    .filter((key) => !(key in before))
    .sort()) {
    const at = order.findIndex((existing) => existing > key);
    order.splice(at === -1 ? order.length : at, 0, key);
  }
  return Object.fromEntries(order.map((key) => [key, place(now[key], before[key])]));
};

const firstMisplaced = (now: Json, placed: Json, path: string[] = []): string | null => {
  if (!isObj(now) || !isObj(placed)) return null;
  const keys = Object.keys(now);
  const expected = Object.keys(placed);
  const at = keys.findIndex((key, i) => key !== expected[i]);
  if (at !== -1) return [...path, keys[at]].join(".");
  for (const key of keys) {
    const found = firstMisplaced(now[key], placed[key], [...path, key]);
    if (found) return found;
  }
  return null;
};

const isSortedDeep = (value: Json): boolean => {
  if (!isObj(value)) return true;
  const keys = Object.keys(value);
  const sorted = [...keys].sort();
  return keys.every((key, i) => key === sorted[i]) && keys.every((key) => isSortedDeep(value[key]));
};

const STANDARD: Style = { indent: "  ", newline: true };
const styleOf = (raw: string): Style => ({
  indent: raw.match(/^[{[]\r?\n([ \t]+)/)?.[1] ?? STANDARD.indent,
  newline: raw.endsWith("\n"),
});
const render = (json: Json, style: Style) =>
  `${JSON.stringify(json, null, style.indent)}${style.newline ? "\n" : ""}`;

const flatten = (value: Json, prefix = "", out: Flat = new Map()): Flat => {
  if (isObj(value)) {
    for (const [key, child] of Object.entries(value)) flatten(child, prefix ? `${prefix}.${key}` : key, out);
  } else {
    out.set(prefix, String(value));
  }
  return out;
};

const parse = (raw: string): Json | undefined => {
  try {
    return JSON.parse(raw);
  } catch {
    return undefined;
  }
};

const read = (path: string): Flat => {
  const full = `${root}/${path}`;
  const json = existsSync(full) ? parse(readFileSync(full, "utf8")) : undefined;
  return json === undefined ? new Map() : flatten(json);
};

// Plural categories a locale needs: those that real counts (0–1000) reach. Excludes the
// `many` of es/fr/it/pt, which CLDR reserves for round millions and i18n:check never required.
const PLURAL = /_(zero|one|two|few|many|other)$/;
const requiredPlurals = (locale: string) => {
  const rules = new Intl.PluralRules(locale.replace("_", "-"));
  const reached = new Set<string>();
  for (let n = 0; n <= 1000; n++) reached.add(rules.select(n));
  return [...reached];
};

const pluralBases = new Map<string, Set<string>>(); // namespace file name → plural base keys

// TR-KEY-002, TR-KEY-003, TR-LOC-001 on every touched file.
for (const path of changed) {
  const [, locale, file] = path.split("/");
  const raw = readFileSync(`${root}/${path}`, "utf8");
  const json = parse(raw);
  if (json === undefined) {
    error("TR-KEY-003", path, "invalid JSON");
    continue;
  }

  const beforeRaw = git("show", `${ref}:${path}`);
  const before = beforeRaw === null ? undefined : parse(beforeRaw);
  const style = beforeRaw === null ? STANDARD : styleOf(beforeRaw);
  const placed = place(json, before);
  const expected = render(placed, style);

  if (fix && raw !== expected) writeFileSync(`${root}/${path}`, expected);
  else if (raw !== expected) {
    const misplaced = firstMisplaced(json, placed);
    if (misplaced) error("TR-KEY-002", path, `${misplaced} out of place: new keys sort among their neighbours, existing keys keep their order`);
    if (raw !== render(json, style)) error("TR-KEY-003", path, "format differs from the file's own");
  }

  if (before !== undefined && !isSortedDeep(before)) note("TR-KEY-002", path, "pre-existing keys unsorted, kept");
  if (beforeRaw !== null && before !== undefined && beforeRaw !== render(before, STANDARD))
    note("TR-KEY-003", path, `pre-existing format kept (${style.indent === "\t" ? "tabs" : `${style.indent.length}-space`}${style.newline ? "" : ", no trailing newline"})`);

  const now = flatten(json);
  const was = before === undefined ? new Map() : flatten(before);
  const es = read(`locale/es/${file}`);
  const en = read(`locale/en/${file}`);

  for (const [key, value] of now) {
    if (was.get(key) === value) continue;
    if (PLURAL.test(key)) {
      if (!pluralBases.has(file)) pluralBases.set(file, new Set());
      pluralBases.get(file)!.add(key.replace(PLURAL, ""));
    }
    if (locale === "es") continue;
    // A suffix es lacks (`_few`) is compared with the es `_other`.
    const esKey = es.has(key) ? key : key.replace(PLURAL, "_other");
    if (value === es.get(esKey)) review("TR-LOC-001", `${path} ${key}`, `same as es: "${value}"`);
    else if (locale !== "en" && value === en.get(esKey))
      review("TR-LOC-001", `${path} ${key}`, `same as en: "${value}"`);
  }
}

// TR-FMT-003: every locale carries each changed plural key in every category it needs.
for (const [file, bases] of pluralBases) {
  for (const locale of locales) {
    const path = `locale/${locale}/${file}`;
    const flat = read(path);
    for (const base of bases) {
      const missing = requiredPlurals(locale).filter((category) => !flat.has(`${base}_${category}`));
      if (missing.length) error("TR-FMT-003", `${path} ${base}`, `missing _${missing.join(", _")}`);
    }
  }
}

// TR-NS-001: a touched namespace exists and is registered in every locale.
const indexOf = (locale: string) => {
  const path = `${root}/locale/${locale}/index.ts`;
  return existsSync(path) ? readFileSync(path, "utf8") : "";
};
const escape = (text: string) => text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const registration = (index: string, namespace: string) => {
  const name = index.match(new RegExp(`import\\s+(\\w+)\\s+from\\s+['"]\\./${escape(namespace)}\\.json['"]`))?.[1];
  const exported = index.slice(index.lastIndexOf("export default"));
  return { imported: Boolean(name), exported: Boolean(name) && new RegExp(`\\b${name}\\b`).test(exported) };
};

for (const namespace of new Set(changed.map((path) => basename(path, ".json")))) {
  for (const locale of locales) {
    const where = `locale/${locale}`;
    if (!existsSync(`${root}/${where}/${namespace}.json`)) error("TR-NS-001", where, `missing ${namespace}.json`);
    const { imported, exported } = registration(indexOf(locale), namespace);
    if (!imported) error("TR-NS-001", `${where}/index.ts`, `does not import ${namespace}.json`);
    else if (!exported) error("TR-NS-001", `${where}/index.ts`, `does not export ${namespace}`);
  }
}

// TR-NS-002: a deleted namespace leaves no trace in the blacklist or the indexes.
const blacklist = readFileSync(`${root}/config/mobile-blacklist.ts`, "utf8");
for (const namespace of new Set(deleted.map((path) => basename(path, ".json")))) {
  if (locales.some((locale) => existsSync(`${root}/locale/${locale}/${namespace}.json`))) continue;
  if (new RegExp(`["']${escape(namespace)}["']`).test(blacklist))
    error("TR-NS-002", "config/mobile-blacklist.ts", `still lists ${namespace}`);
  for (const locale of locales)
    if (registration(indexOf(locale), namespace).imported)
      error("TR-NS-001", `locale/${locale}/index.ts`, `still imports deleted ${namespace}.json`);
}

for (const line of [...errors, ...reviews, ...notes]) console.log(line);
const summary = [
  `${changed.length} files vs ${ref}`,
  fix ? "fixed: placement + format" : null,
  blacklistChanged.length ? "mobile-blacklist.ts changed: run bun test" : null,
].filter(Boolean);
console.log(
  `work-translations check · ${errors.length} errors · ${reviews.length} reviews · ${notes.length} notes · ${summary.join(" · ")}`,
);
process.exit(errors.length ? 1 : 0);
