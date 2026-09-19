import { main as preBash } from "./pre-bash.ts";
import { main as preWrite } from "./pre-write.ts";
import { main as notification } from "./notification.ts";

const commands: Record<string, () => Promise<void>> = {
  "pre-bash": preBash,
  "pre-write": preWrite,
  notification: notification,
};

const name = Deno.args[0];

if (!name || !(name in commands)) {
  const available = Object.keys(commands).join(", ");
  console.error(name ? `Unknown command: ${name}` : "No command specified");
  console.error(`Available commands: ${available}`);
  Deno.exit(1);
}

await commands[name]();
