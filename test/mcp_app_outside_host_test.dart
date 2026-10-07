import 'package:flutter_mcp_app/flutter_mcp_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpApp outside a browser', () {
    test('initializes without touching the web-only plugins', () {
      McpApp.ensureInitialized();
    });

    test('reports no host and an empty initial tool call', () {
      expect(McpApp.isHosted, isFalse);
      expect(McpApp.initialToolCall.arguments, isEmpty);
      expect(McpApp.initialToolCall.result, isNull);
      expect(McpApp.arguments, isEmpty);
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
