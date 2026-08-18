import 'dart:async';
import 'dart:io';

void main(List<String> args) async {
  final isWatch = args.contains('--watch') || args.contains('-w');

  // Detect whether running from root or inside shared/l10n
  final isRootContext = FileSystemEntity.isDirectorySync('shared/l10n');
  final workingDir = isRootContext ? 'shared/l10n' : '.';
  final arbDirPath = isRootContext ? 'shared/l10n/lib/l10n' : 'lib/l10n';

  final arbDir = Directory(arbDirPath);

  if (!arbDir.existsSync()) {
    print('⚠️ Directory not found: ${arbDir.path}');
    print('Creating directory...');
    arbDir.createSync(recursive: true);
  }

  // Initial build on startup
  await _generateAndFix(workingDir);

  if (!isWatch) {
    print('\n✨ One-time generation complete.');
    return;
  }

  print('\n👀 Watching ${arbDir.path} for .arb changes... (Press Ctrl+C to stop)');

  Timer? debounceTimer;

  // Listen to file change events inside shared/l10n/lib/l10n
  arbDir.watch(recursive: true).listen((event) {
    if (event.path.endsWith('.arb')) {
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        final time = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
        print('\n📝 [$time] Change detected in ${event.path}');
        await _generateAndFix(workingDir);
      });
    }
  });
}

bool _isProcessing = false;

Future<void> _generateAndFix(String workingDir) async {
  if (_isProcessing) return;
  _isProcessing = true;

  try {
    print('⏳ 1/2 Running intl_utils:generate...');
    final genProcess = await Process.run(
      'dart',
      ['run', 'intl_utils:generate'],
      workingDirectory: workingDir,
    );

    if (genProcess.exitCode == 0) {
      print('✅ Generation complete.');
    } else {
      print('❌ Generation failed:\n${genProcess.stderr}');
      return;
    }

    print('⚡ 2/2 Running dart fix...');
    final fixProcess = await Process.run(
      'dart',
      ['fix', '--apply', '--code=migrate_design_widgets'],
      workingDirectory: workingDir,
    );

    if (fixProcess.exitCode == 0) {
      final stdout = fixProcess.stdout.toString().trim();
      if (stdout.isNotEmpty) {
        print(stdout);
      }
      print('🎉 Applied migrate_design_widgets fix successfully.');
    } else {
      print('⚠️ dart fix failed:\n${fixProcess.stderr}');
    }
  } catch (e) {
    print('❌ Error during workflow: $e');
  } finally {
    _isProcessing = false;
  }
}