import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_mcp_app/src/mcp_app_exception.dart';
import 'package:flutter_mcp_app/src/mcp_tool_call.dart';

/// Bridge to the `mcp_app_shell.js` script that hosts the app.
///
/// The shell starts Flutter in the host's frame and exposes itself as
/// `window.mcpAppShell`.
class McpAppShell {
  const McpAppShell._();

  /// The global the shell defines before it starts the app.
  static const property = 'mcpAppShell';

  /// Message type for size reports.
  static const heightMessage = 'mcp-app:height';

  /// Message type for links the host should open.
  static const openLinkMessage = 'mcp-app:open-link';

  /// The shell, or null outside an MCP Apps host.
  static JSObject? get shell =>
      globalContext.getProperty<JSObject?>(property.toJS);

  /// Whether the app runs inside an MCP Apps host.
  static bool get isHosted => shell != null;

  /// The tool call that opened the app, or an empty one outside a host.
  static McpToolCall get initialToolCall {
    final current = shell;
    if (current == null) return const McpToolCall();
    return McpToolCall.fromObject({
      'arguments': current.getProperty<JSAny?>('arguments'.toJS).dartify(),
      'result': current.getProperty<JSAny?>('result'.toJS).dartify(),
    });
  }

  /// The base URL of the Flutter build: the shell's app URL inside a host,
  /// the page's own URL outside one.
  static Uri get baseUrl {
    final appUrl = shell?.getProperty<JSString?>('appUrl'.toJS)?.toDart;
    return appUrl == null ? Uri.base : Uri.parse(appUrl);
  }

  /// Sends a one-way [message] to the shell. Does nothing outside a host.
  static void post(Map<String, Object> message) {
    shell?.callMethod<JSAny?>('post'.toJS, message.jsify());
  }

  /// Sends the JSON-RPC request [method] to the host through the shell and
  /// returns its result.
  static Future<Object?> request(
    String method,
    Map<String, Object?> params,
  ) async {
    final current = shell;
    if (current == null) {
      throw const McpAppException('Not running inside an MCP Apps host.');
    }
    final reply = await current
        .callMethod<JSPromise<JSAny?>>(
          'request'.toJS,
          method.toJS,
          params.jsify(),
        )
        .toDart;
    final outcome = reply.dartify();
    if (outcome is Map && outcome['error'] != null) {
      throw McpAppException.fromError(outcome['error']);
    }
    return outcome is Map ? outcome['result'] : null;
  }
}
