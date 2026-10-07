/// The `web/flutter_bootstrap.js` that `dart run flutter_mcp_app:init` writes.
class BootstrapTemplate {
  const BootstrapTemplate._();

  /// Where Flutter looks for a custom bootstrap template.
  static const path = 'web/flutter_bootstrap.js';

  /// Starts the app without a service worker (reading `navigator.serviceWorker`
  /// throws in an opaque origin), with the shell's configuration when the
  /// `flutter_mcp_app` shell is present, and as a plain web app otherwise.
  static const contents = '''
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load(
  window.mcpAppShell ? { config: window.mcpAppShell.flutterConfig } : {}
);
''';
}
