import 'dart:io';

import 'package:flutter_mcp_app/src/bootstrap_template.dart';

void main(List<String> args) {
  final file = File(BootstrapTemplate.path);
  if (file.existsSync() && !args.contains('--force')) {
    stderr.writeln(
      '${BootstrapTemplate.path} already exists. Re-run with --force to replace it.',
    );
    exitCode = 1;
    return;
  }
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(BootstrapTemplate.contents);
  stdout.writeln(
    'Wrote ${BootstrapTemplate.path}: no service worker, and the shell\'s '
    'configuration when the flutter_mcp_app shell is present.',
  );
}
