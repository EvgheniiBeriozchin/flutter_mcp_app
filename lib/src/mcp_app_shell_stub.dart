import 'package:flutter_mcp_app/src/mcp_app_arguments.dart';
import 'package:flutter_mcp_app/src/mcp_app_exception.dart';

/// Stand-in for the shell bridge on platforms without a browser (iOS, Android,
/// desktop), where no MCP Apps host can be running the app.
///
/// It lets one codebase import `flutter_mcp_app` everywhere: launch data is
/// empty, one-way messages are dropped, and requests fail with
/// [McpAppException].
class McpAppShell {
  const McpAppShell._();

  /// Message type for size reports.
  static const heightMessage = 'mcp-app:height';

  /// Message type for links the host should open.
  static const openLinkMessage = 'mcp-app:open-link';

  /// Always false: no host can run the app outside the browser.
  static bool get isHosted => false;

  /// Always empty.
  static McpAppArguments get launch => const McpAppArguments();

  /// The current base URI.
  static Uri get baseUrl => Uri.base;

  /// Does nothing.
  static void post(Map<String, Object> message) {}

  /// Always fails.
  static Future<Object?> request(String method, Map<String, Object?> params) =>
      Future.error(
        const McpAppException('Not running inside an MCP Apps host.'),
      );
}
