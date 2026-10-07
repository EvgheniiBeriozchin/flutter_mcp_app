/// A tool call as the app sees it: the arguments the model passed and, once
/// it arrived, the tool's result.
///
/// [McpApp.initialToolCall] is the call that opened the app.
class McpToolCall {
  /// Creates a tool call from its [arguments] and [result].
  const McpToolCall({this.arguments = const {}, this.result});

  /// The arguments the model passed to the tool.
  final Map<String, Object?> arguments;

  /// The tool result's `structuredContent`, or null if it hadn't arrived when
  /// the app started. Use `data-start="result"` on the shell script to wait
  /// for it.
  final Map<String, Object?>? result;

  /// Reads a tool call from a decoded `{arguments, result}` object, or returns
  /// an empty one if [call] isn't one.
  static McpToolCall fromObject(Object? call) {
    if (call is! Map) return const McpToolCall();
    return McpToolCall(
      arguments: asMap(call['arguments']) ?? const {},
      result: asMap(call['result']),
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
