import 'package:flutter_mcp_app/src/mcp_app_arguments.dart';

/// The result of an MCP tool call made by the app, as returned by
/// [McpApp.callServerTool].
class McpToolResult {
  /// Creates a result from its parts.
  const McpToolResult({
    this.content = const [],
    this.structuredContent,
    this.isError = false,
  });

  /// Reads an MCP `CallToolResult` object.
  factory McpToolResult.fromObject(Object? result) {
    if (result is! Map) return const McpToolResult();
    final content = result['content'];
    return McpToolResult(
      content: [
        if (content is List)
          for (final item in content)
            if (McpAppArguments.asMap(item) case final Map<String, Object?> map)
              map,
      ],
      structuredContent: McpAppArguments.asMap(result['structuredContent']),
      isError: result['isError'] == true,
    );
  }

  /// The result's content blocks, such as `{"type": "text", "text": "..."}`.
  final List<Map<String, Object?>> content;

  /// The result's machine-readable payload, if the tool returned one.
  final Map<String, Object?>? structuredContent;

  /// Whether the tool reported a failure.
  final bool isError;

  /// The text of all `text` content blocks, joined by newlines, or null if
  /// there are none.
  String? get text {
    final texts = [
      for (final item in content)
        if (item['type'] == 'text' && item['text'] is String)
          item['text']! as String,
    ];
    return texts.isEmpty ? null : texts.join('\n');
  }
}
