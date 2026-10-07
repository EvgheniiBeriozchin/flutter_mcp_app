import 'package:flutter_mcp_app/src/mcp_app_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpAppArguments', () {
    test('reads tool arguments and result from the shell object', () {
      final launch = McpAppArguments.fromObject({
        'arguments': {'game': 'hex'},
        'result': {'game': 'hex', 'count': 2},
      });

      expect(launch.arguments, {'game': 'hex'});
      expect(launch.result, {'game': 'hex', 'count': 2});
      expect(launch.string('game'), 'hex');
    });

    test('falls back to the tool result when an argument is missing', () {
      final launch = McpAppArguments.fromObject({
        'arguments': <String, Object?>{},
        'result': {'game': 'wordmanteau'},
      });

      expect(launch.string('game'), 'wordmanteau');
    });

    test('accepts the loosely typed maps dartify produces', () {
      final launch = McpAppArguments.fromObject(<Object?, Object?>{
        'arguments': <Object?, Object?>{'game': 'ukodus'},
        'result': null,
      });

      expect(launch.arguments, {'game': 'ukodus'});
      expect(launch.result, isNull);
    });

    test('is empty for a missing or non-object payload', () {
      expect(McpAppArguments.fromObject(null).arguments, isEmpty);
      expect(McpAppArguments.fromObject([1, 2]).arguments, isEmpty);
      expect(McpAppArguments.fromObject(null).string('game'), isNull);
    });

    test('reads JavaScript numbers as integers', () {
      final launch = McpAppArguments.fromObject({
        'result': {'levelNumber': 103.0},
      });

      expect(launch.integer('levelNumber'), 103);
    });

    test('only returns strings from string()', () {
      final launch = McpAppArguments.fromObject({
        'arguments': {'level': 12},
      });

      expect(launch.string('level'), isNull);
      expect(launch.arguments['level'], 12);
    });
  });
}
