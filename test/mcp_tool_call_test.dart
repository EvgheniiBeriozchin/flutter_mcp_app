import 'package:flutter_mcp_app/src/mcp_tool_call.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpToolCall', () {
    test('reads tool arguments and result from the shell object', () {
      final call = McpToolCall.fromObject({
        'arguments': {'name': 'Ada'},
        'result': {'name': 'Ada', 'count': 2},
      });

      expect(call.arguments, {'name': 'Ada'});
      expect(call.result, {'name': 'Ada', 'count': 2});
      expect(call.string('name'), 'Ada');
    });

    test('falls back to the tool result when an argument is missing', () {
      final call = McpToolCall.fromObject({
        'arguments': <String, Object?>{},
        'result': {'name': 'Grace'},
      });

      expect(call.string('name'), 'Grace');
    });

    test('accepts the loosely typed maps dartify produces', () {
      final call = McpToolCall.fromObject(<Object?, Object?>{
        'arguments': <Object?, Object?>{'name': 'Linus'},
        'result': null,
      });

      expect(call.arguments, {'name': 'Linus'});
      expect(call.result, isNull);
    });

    test('is empty for a missing or non-object payload', () {
      expect(McpToolCall.fromObject(null).arguments, isEmpty);
      expect(McpToolCall.fromObject([1, 2]).arguments, isEmpty);
      expect(McpToolCall.fromObject(null).string('name'), isNull);
    });

    test('reads JavaScript numbers as integers', () {
      final call = McpToolCall.fromObject({
        'result': {'count': 3.0},
      });

      expect(call.integer('count'), 3);
    });

    test('only returns strings from string()', () {
      final call = McpToolCall.fromObject({
        'arguments': {'count': 12},
      });

      expect(call.string('count'), isNull);
      expect(call.arguments['count'], 12);
    });
  });
}
