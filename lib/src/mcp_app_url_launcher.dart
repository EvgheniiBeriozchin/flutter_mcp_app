import 'package:flutter_mcp_app/src/mcp_app_shell.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// A `url_launcher` implementation that asks the MCP Apps host to open links.
///
/// Installed by [McpApp.ensureInitialized]. The host's sandbox blocks the
/// popups `url_launcher` normally opens, so links go through the host's
/// `ui/open-link` instead.
class McpAppUrlLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    McpAppShell.post({'type': McpAppShell.openLinkMessage, 'url': url});
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;
}
