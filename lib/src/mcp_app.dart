import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_mcp_app/src/mcp_app_arguments.dart';
import 'package:flutter_mcp_app/src/mcp_app_shell.dart';
import 'package:flutter_mcp_app/src/mcp_app_url_launcher.dart';
import 'package:flutter_mcp_app/src/mcp_tool_result.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Entry point for a Flutter web app running as an MCP App inside an AI chat.
///
/// Call [ensureInitialized] first in `main`, then read [launch] and run the
/// app:
///
/// ```dart
/// void main() {
///   McpApp.ensureInitialized();
///   runApp(GreetingApp(name: McpApp.launch.string('name') ?? 'there'));
///   McpApp.reportHeight(200);
/// }
/// ```
class McpApp {
  const McpApp._();

  /// Prepares Flutter to run inside an MCP Apps host. Use it instead of
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  ///
  /// Hosts sandbox the app with an opaque origin, where the browser history
  /// API throws, so this disables Flutter's URL strategy. It also routes
  /// `url_launcher` through the host, since the sandbox blocks popups.
  ///
  /// Outside the browser it only initializes the binding, so a codebase that
  /// also builds for iOS, Android or desktop can call it unconditionally.
  static void ensureInitialized() {
    if (kIsWeb) setUrlStrategy(null);
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) UrlLauncherPlatform.instance = McpAppUrlLauncher();
  }

  /// The tool call that opened the app: its arguments and, if it arrived
  /// before the app started, its result.
  static McpAppArguments get launch => McpAppShell.launch;

  /// Whether the app runs inside an MCP Apps host.
  static bool get isHosted => McpAppShell.isHosted;

  /// The URL the Flutter build is served from.
  ///
  /// Inside a host, the document's own URL belongs to the host, so resolve the
  /// app's files against this instead of `Uri.base`.
  static Uri get baseUrl => McpAppShell.baseUrl;

  /// Resolves [path] against [baseUrl], for files shipped in the build's
  /// `web/` folder.
  static Uri resolve(String path) => baseUrl.resolve(path);

  /// Tells the host how tall the app is, in logical pixels.
  static void reportHeight(double height) =>
      McpAppShell.post({'type': McpAppShell.heightMessage, 'height': height});

  /// Asks the host to open [url], usually after confirming with the user.
  static void openLink(String url) =>
      McpAppShell.post({'type': McpAppShell.openLinkMessage, 'url': url});

  /// Calls the MCP server tool [name] with [arguments], through the host and
  /// with the connector's credentials.
  ///
  /// The tool must be callable by apps: its `_meta.ui.visibility` must include
  /// `"app"` (the default). Use `["app"]` alone for tools only the app should
  /// see. Throws [McpAppException] if the host rejects the call; a tool that
  /// runs but fails returns a result with [McpToolResult.isError] set.
  static Future<McpToolResult> callServerTool(
    String name, [
    Map<String, Object?> arguments = const {},
  ]) async {
    final result = await McpAppShell.request('tools/call', {
      'name': name,
      'arguments': arguments,
    });
    return McpToolResult.fromObject(result);
  }

  /// Posts [text] into the conversation as a user message.
  ///
  /// Hosts may ask the user to confirm first. Throws [McpAppException] if the
  /// host refuses.
  static Future<void> sendMessage(String text) =>
      McpAppShell.request('ui/message', {
        'role': 'user',
        'content': {'type': 'text', 'text': text},
      });
}
