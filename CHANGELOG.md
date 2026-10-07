## 0.1.0

- Initial version.
- `McpApp`: `ensureInitialized`, `initialToolCall`, `arguments`, `isHosted`,
  `reportHeight`, `openLink`, `callServerTool`, `sendMessage`, `baseUrl` and `resolve`.
- `McpToolCall` and `McpToolResult`.
- The `mcp_app_shell.js` host shell: starts Flutter in the host's frame, supports
  `data-start="result"`, and relays an allowlisted set of requests between the app and
  the host.
- `dart run flutter_mcp_app:init` writes the service-worker-free bootstrap template.
- Compiles on every platform; outside the browser, `McpApp` reports no host.
- Tested with Claude.
