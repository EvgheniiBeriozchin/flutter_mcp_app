/// How the MCP Apps host launched the app: the tool call's arguments and,
/// once it arrived, the tool's result.
///
/// Read it with [McpApp.launch].
class McpAppArguments {
  /// Creates launch data from the tool [arguments] and [result].
  const McpAppArguments({this.arguments = const {}, this.result});

  /// The arguments the model passed to the tool.
  final Map<String, Object?> arguments;

  /// The tool result's `structuredContent`, or null if it hadn't arrived when
  /// the app started. Use `data-start="result"` on the shell script to wait
  /// for it.
  final Map<String, Object?>? result;

  /// Reads launch data from a decoded `{arguments, result}` object, or returns
  /// empty launch data if [launch] isn't one.
  static McpAppArguments fromObject(Object? launch) {
    if (launch is! Map) return const McpAppArguments();
    return McpAppArguments(
      arguments: asMap(launch['arguments']) ?? const {},
      result: asMap(launch['result']),
    );
  }

  /// Converts a loosely typed map, such as one from `dartify()`, into a map
  /// with string keys, or returns null if [value] isn't a map.
  static Map<String, Object?>? asMap(Object? value) => value is Map
      ? {for (final entry in value.entries) '${entry.key}': entry.value}
      : null;

  /// The string value of [key] in the [arguments], falling back to the
  /// [result], or null if neither holds a string.
  String? string(String key) {
    final value = arguments[key] ?? result?[key];
    return value is String ? value : null;
  }

  /// The integer value of [key] in the [arguments], falling back to the
  /// [result], or null if neither holds a number.
  int? integer(String key) {
    final value = arguments[key] ?? result?[key];
    return value is num ? value.toInt() : null;
  }
}
