import 'package:flutter_mcp_app/src/bootstrap_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BootstrapTemplate', () {
    test('keeps the tokens flutter build substitutes', () {
      expect(BootstrapTemplate.contents, contains('{{flutter_js}}'));
      expect(BootstrapTemplate.contents, contains('{{flutter_build_config}}'));
    });

    test('never registers a service worker', () {
      expect(BootstrapTemplate.contents, isNot(contains('serviceWorker')));
      expect(
        BootstrapTemplate.contents,
        isNot(contains('flutter_service_worker_version')),
      );
    });

    test('starts inline with the shell config when the shell is present', () {
      expect(
        BootstrapTemplate.contents,
        contains('window.mcpAppShell.flutterConfig'),
      );
      expect(BootstrapTemplate.contents, contains('_flutter.loader.load('));
    });
  });
}
