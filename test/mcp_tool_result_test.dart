import 'package:flutter_mcp_app/src/mcp_tool_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpToolResult', () {
    test('reads a CallToolResult', () {
      final result = McpToolResult.fromObject(<Object?, Object?>{
        'content': [
          {'type': 'text', 'text': 'a'},
          {'type': 'text', 'text': 'b'},
          {'type': 'resource', 'resource': {}},
        ],
        'structuredContent': {'n': 1},
        'isError': false,
      });

      expect(result.text, 'a\nb');
      expect(result.structuredContent, {'n': 1});
      expect(result.isError, isFalse);
      expect(result.content, hasLength(3));
    });

    test('is empty for anything else', () {
      final result = McpToolResult.fromObject('nope');

      expect(result.content, isEmpty);
      expect(result.structuredContent, isNull);
      expect(result.text, isNull);
    });
  });
}
