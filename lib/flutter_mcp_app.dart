/// Run a Flutter web app as an MCP App inside AI chats such as Claude.
///
/// Start with [McpApp.ensureInitialized], read the tool call that opened the
/// app from [McpApp.initialToolCall], and talk to the host with
/// [McpApp.reportHeight], [McpApp.openLink], [McpApp.callServerTool] and
/// [McpApp.sendMessage].
library;

export 'package:flutter_mcp_app/src/mcp_app.dart';
export 'package:flutter_mcp_app/src/mcp_app_exception.dart';
export 'package:flutter_mcp_app/src/mcp_tool_call.dart';
export 'package:flutter_mcp_app/src/mcp_tool_result.dart';
