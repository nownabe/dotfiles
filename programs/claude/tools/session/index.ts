// Lazily imported so that adding commands does not slow down every invocation:
// only the command actually being run is loaded.
export const commands: Record<string, () => Promise<void>> = {
  "list-denials": () => import("./list-denials.ts").then((m) => m.main()),
  "mark-denials-collected": () => import("./mark-denials-collected.ts").then((m) => m.main()),
};
