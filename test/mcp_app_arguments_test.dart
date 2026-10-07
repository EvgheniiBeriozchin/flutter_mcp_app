import 'package:flutter_mcp_app/src/mcp_app_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpAppArguments', () {
    test('reads tool arguments and result from the shell object', () {
      final launch = McpAppArguments.fromObject({
        'arguments': {'name': 'Ada'},
        'result': {'name': 'Ada', 'count': 2},
      });

      expect(launch.arguments, {'name': 'Ada'});
      expect(launch.result, {'name': 'Ada', 'count': 2});
      expect(launch.string('name'), 'Ada');
    });

    test('falls back to the tool result when an argument is missing', () {
      final launch = McpAppArguments.fromObject({
        'arguments': <String, Object?>{},
        'result': {'name': 'Grace'},
      });

      expect(launch.string('name'), 'Grace');
    });

    test('accepts the loosely typed maps dartify produces', () {
      final launch = McpAppArguments.fromObject(<Object?, Object?>{
        'arguments': <Object?, Object?>{'name': 'Linus'},
        'result': null,
      });

      expect(launch.arguments, {'name': 'Linus'});
      expect(launch.result, isNull);
    });

    test('is empty for a missing or non-object payload', () {
      expect(McpAppArguments.fromObject(null).arguments, isEmpty);
      expect(McpAppArguments.fromObject([1, 2]).arguments, isEmpty);
      expect(McpAppArguments.fromObject(null).string('name'), isNull);
    });

    test('reads JavaScript numbers as integers', () {
      final launch = McpAppArguments.fromObject({
        'result': {'count': 3.0},
      });

      expect(launch.integer('count'), 3);
    });

    test('only returns strings from string()', () {
      final launch = McpAppArguments.fromObject({
        'arguments': {'count': 12},
      });

      expect(launch.string('count'), isNull);
      expect(launch.arguments['count'], 12);
    });
  });
}
