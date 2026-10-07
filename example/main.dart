import 'package:flutter/material.dart';
import 'package:flutter_mcp_app/flutter_mcp_app.dart';

void main() {
  McpApp.ensureInitialized();
  runApp(GreetingApp(name: McpApp.initialToolCall.string('name') ?? 'there'));
  McpApp.reportHeight(GreetingApp.height);
}

class GreetingApp extends StatelessWidget {
  const GreetingApp({super.key, required this.name});

  static const height = 200.0;

  final String name;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => McpApp.openLink('https://flutter.dev'),
            child: Text('Hello, $name'),
          ),
        ),
      ),
    );
  }
}
