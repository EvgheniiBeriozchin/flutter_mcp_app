# flutter_mcp_app

Run an existing Flutter web app as an [MCP App](https://modelcontextprotocol.io/extensions/apps/overview):
interactive UI that an MCP server renders inside AI chats such as Claude.

Your app keeps its own widgets, state management and backend calls.

## Setup

### 1. Add the package and the bootstrap template

```yaml
dependencies:
  flutter_mcp_app: ^0.1.0
```

```bash
dart run flutter_mcp_app:init
```

`init` writes `web/flutter_bootstrap.js`. It starts the app without a service worker, and
with the shell's configuration when the shell is present. It refuses to overwrite an
existing file unless you pass `--force`.

Use a dedicated Flutter web project (or entrypoint) for the chat app: the template drops
Flutter's service worker, which you may want to keep for your main web app.

### 2. Start your app through `McpApp`

```dart
import 'package:flutter_mcp_app/flutter_mcp_app.dart';

void main() {
  McpApp.ensureInitialized();

  final name = McpApp.launch.string('name') ?? 'there';

  runApp(GreetingApp(name: name));
  McpApp.reportHeight(200);
}
```

- `McpApp.ensureInitialized()` replaces `WidgetsFlutterBinding.ensureInitialized()`. It
  disables browser-history integration and routes `url_launcher` through the host.
- `McpApp.launch` holds the tool call's `arguments` and, if it already arrived, the tool
  result's `structuredContent`. `string(key)` and `integer(key)` check the arguments first,
  then the result.
- `McpApp.reportHeight(height)` resizes the view in the chat.
- `McpApp.openLink(url)` asks the host to open a URL.
- `McpApp.callServerTool(name, arguments)` calls a tool on your MCP server, through the host
  and with the connector's credentials. Mark tools only the app should use with
  `_meta.ui.visibility: ["app"]`. *Not yet tested in a host.*
- `McpApp.sendMessage(text)` posts a message into the conversation, for example when the
  user finishes something in your app. *Not yet tested in a host.*
- `McpApp.resolve(path)` resolves a file from your build's `web/` folder. Use it instead of
  relative URLs: in the host's frame, the document's URL belongs to the host.

The app runs with an **opaque origin** in at least Claude, so anything that touches
`localStorage`, `IndexedDB` or cookies throws. Replace those dependencies for the chat build,
for example with Riverpod overrides or in-memory implementations:

- `shared_preferences`: set `SharedPreferencesStorePlatform.instance` to
  `InMemorySharedPreferencesStore.empty()` before `runApp`.
- `drift`: open the database with `WasmDatabase.inMemory(await WasmSqlite3.loadFromUrl(McpApp.resolve('sqlite3.wasm')))`.
- `supabase_flutter`: pass `authOptions: FlutterAuthClientOptions(localStorage: const EmptyLocalStorage(), pkceAsyncStorage: <in-memory storage>)`.

### Other platforms

The package compiles on every platform. Outside the browser no host can be running the app,
so `McpApp.launch` is empty, one-way calls do nothing, and requests throw `McpAppException`.
You can call `McpApp.ensureInitialized()` unconditionally from a codebase that also ships to
iOS, Android or desktop.

### 3. Build and host it

```bash
flutter build web --release
```

Serve `build/web` from any static host, with CORS open so the sandboxed host can load it:

```
Access-Control-Allow-Origin: *
```

(On Cloudflare Workers or Pages, put that in `web/_headers` under `/*`.)

### 4. Point your MCP server at it

The tool declares a UI resource, and the resource is a one-line stub that loads the
package's shell from your build. With the official TypeScript SDK
(`@modelcontextprotocol/server` and `@modelcontextprotocol/ext-apps`, version 2):

```ts
import { registerAppResource, registerAppTool, RESOURCE_MIME_TYPE } from "@modelcontextprotocol/ext-apps/server";
import { createMcpHandler, McpServer } from "@modelcontextprotocol/server";
import { z } from "zod";

const APP_URL = "https://app.example.com/"; // where your build/web is served
const APP_ORIGIN = new URL(APP_URL).origin;
const VIEW_URI = "ui://my-app/greeting";

const csp = {
  resourceDomains: [APP_ORIGIN],
  connectDomains: [APP_ORIGIN, "https://api.example.com", "https://fonts.gstatic.com"],
};

const html = `<!DOCTYPE html><html><body>
<script src="${APP_URL}assets/packages/flutter_mcp_app/assets/mcp_app_shell.js"
        data-height="200" data-start="result"></script>
</body></html>`;

function myServer() {
  const server = new McpServer({ name: "my-app", version: "1.0.0" });

  registerAppResource(server, "greeting", VIEW_URI, { _meta: { ui: { csp } } }, () => ({
    contents: [{ uri: VIEW_URI, mimeType: RESOURCE_MIME_TYPE, text: html, _meta: { ui: { csp } } }],
  }));

  registerAppTool(server, "greet", {
    description: "Greet the user with an interactive card.",
    inputSchema: z.object({ name: z.string() }),
    _meta: { ui: { resourceUri: VIEW_URI } },
  }, ({ name }) => ({
    content: [{ type: "text", text: `Greeting ${name}.` }],
    structuredContent: { name },
  }));

  return server;
}

export default createMcpHandler(myServer);
```

The app then reads the call in `main()` with `McpApp.launch.string('name')`: from the
tool's arguments, or from its `structuredContent` (`data-start="result"` waits for it).
`createMcpHandler` returns a `fetch` handler for Deno, Bun, Cloudflare Workers or Supabase
Edge Functions; on Node, wrap it with `toNodeHandler` from `@modelcontextprotocol/node`.

- `resourceDomains` and `connectDomains` must include your build's origin (the shell loads
  its scripts, assets and CanvasKit from there), plus every API and font host the app calls.
  Flutter downloads fonts from `fonts.gstatic.com` unless you bundle them.
- Hosts cache UI resources by URI. If a host keeps showing an old version after you
  redeploy, reconnect the connector, or put a version in the URI.

With another SDK or language, the resource is the same stub HTML with the MIME type
`text/html;profile=mcp-app` and the CSP under `_meta.ui.csp`, and the tool points at it
with `_meta.ui.resourceUri`.

Shell attributes, all optional:

| Attribute | Default | |
|---|---|---|
| `data-height` | `560` | View height in px until the app reports its own |
| `data-app-url` | Derived from the script URL | Base URL of the Flutter build |
| `data-bootstrap-url` | `<app-url>flutter_bootstrap.js` | |
| `data-start` | `input` | `result` waits for the tool result before starting the app, when the view depends on it |

## Host support

The shell starts Flutter in the host's own frame. That needs three things from the host:
`resourceDomains` added to `script-src`, `connectDomains` added to `connect-src`, and a
`script-src` that allows WebAssembly (`'unsafe-eval'` or `'wasm-unsafe-eval'`). The MCP Apps
spec doesn't let a server request the last one, so it depends on the host.

| Host | Status | Notes |
|---|---|---|
| claude.ai | tested | Forwards `resourceDomains`/`connectDomains`, and its `script-src` includes `'unsafe-eval'`. Drops `frameDomains` ([anthropics/claude-ai-mcp#40](https://github.com/anthropics/claude-ai-mcp/issues/40)). The view's origin is opaque. |
| Claude desktop | tested | Same sandbox as claude.ai. |
| Others (ChatGPT, VS Code, Goose, …) | untested | Work if they allow WebAssembly in the view's frame. |
