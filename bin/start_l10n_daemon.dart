import 'dart:io';

void main() async {
  final isRootContext = FileSystemEntity.isDirectorySync('shared/l10n');
  final workingDir = isRootContext ? 'shared/l10n' : '.';

  final process = await Process.start(
    'dart',
    ['run', 'bin/l10n.dart', '--watch'],
    workingDirectory: workingDir,
    mode: ProcessStartMode.detached,
  );

  print('🚀 L10n Watcher daemon started in background!');
  print('📍 Working Directory: $workingDir');
  print('🆔 Process PID: ${process.pid}');
}
