import 'package:flutter_mcp_app/flutter_mcp_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpApp outside a browser', () {
    test('initializes without touching the web-only plugins', () {
      McpApp.ensureInitialized();
    });

    test('reports no host and empty launch data', () {
      expect(McpApp.isHosted, isFalse);
      expect(McpApp.launch.arguments, isEmpty);
      expect(McpApp.launch.result, isNull);
    });

    test('drops one-way messages', () {
      McpApp.reportHeight(100);
      McpApp.openLink('https://flutter.dev');
    });

    test('fails host requests with McpAppException', () async {
      await expectLater(
        McpApp.callServerTool('anything'),
        throwsA(isA<McpAppException>()),
      );
      await expectLater(
        McpApp.sendMessage('hi'),
        throwsA(isA<McpAppException>()),
      );
    });
  });
}
