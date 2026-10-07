/// A request from the app to the MCP Apps host failed.
///
/// Thrown by [McpApp.callServerTool] and [McpApp.sendMessage] when the host
/// rejects the request, the shell refuses to relay it, or the app runs outside
/// an MCP Apps host.
class McpAppException implements Exception {
  /// Creates an exception with the host's JSON-RPC error [code] and [message].
  const McpAppException(this.message, {this.code});

  /// Builds an exception from a JSON-RPC error object, or any other value the
  /// host rejected with.
  factory McpAppException.fromError(Object? error) {
    if (error is Map) {
      final code = error['code'];
      return McpAppException(
        '${error['message'] ?? 'Request failed'}',
        code: code is num ? code.toInt() : null,
      );
    }
    return McpAppException('$error');
  }

  /// A human-readable description from the host or the shell.
  final String message;

  /// The JSON-RPC error code, when the host sent one.
  final int? code;

  @override
  String toString() =>
      'McpAppException${code == null ? '' : '($code)'}: $message';
}
