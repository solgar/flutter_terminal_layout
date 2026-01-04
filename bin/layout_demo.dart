import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'dart:io';

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          height: 5,
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Text(' FLUTTER TERMINAL LAYOUT DEMO ', color: Colors.white),
                  Spacer(),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
        Container(height: 1), // Margin
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.red,
                  // Height removed to allow filling parent Expanded
                  child: Column(
                    children: [
                      Text(' Left Panel ', color: Colors.white),
                      Spacer(),
                      Text(' Bottom Left ', color: Colors.white),
                    ],
                  ),
                ),
              ),
              Container(width: 1), // Gap
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.green,
                  // Height removed to allow filling parent Expanded
                  child: Column(
                    children: [
                      Text(' Right Panel (Flex 2) ', color: Colors.black),
                      Container(
                        color: Colors.cyan,
                        child: Text(
                          'Verry long text to check, test and implement text wrapping and overflow. Lorem ipsum.',
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        color: Colors.cyan,
                        child: Text(
                          'Verry long text to check, test and implement text wrapping and overflow. Lorem ipsum.',
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        color: Colors.cyan,
                        child: Text(
                          'Verry long text to check, test and implement text wrapping and overflow. Lorem ipsum.',
                          color: Colors.black,
                        ),
                      ),
                      // Container(height: 1, color: Colors.black),
                      Spacer(),
                      Text(' Content Line 2 ', color: Colors.black),
                      Text(' Content Line 3 ', color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Spacer expanded Row takes all space
        Container(
          color: Colors.yellow,
          height: 1,
          child: Row(
            children: [
              Text(' Footer Status: OK ', color: Colors.black),
              Spacer(),
              Text(' v1.0.0 ', color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}

void logToFile(String message) {
  final file = File('demo.log');
  final timestamp = DateTime.now().toIso8601String();
  file.writeAsStringSync('[$timestamp] $message\n', mode: FileMode.append);
}

void logSttyState(String label) {
  try {
    // Run via sh to redirect /dev/tty to stdin so stty checks the actual terminal
    final result = Process.runSync('sh', ['-c', 'stty -a < /dev/tty']);
    logToFile('$label stty -a:\n${result.stdout}');
    if (result.stderr.toString().isNotEmpty) {
      logToFile('$label stty stderr: ${result.stderr}');
    }
  } catch (e) {
    logToFile('$label: failed to run stty: $e');
  }
}

Future<void> mainA() async {
  logToFile('Starting demo application');
  logSttyState('Start');
  // Enable alt buffer
  stdout.write(Ansi.enableAltBuffer);
  // Clear screen
  stdout.write(Ansi.clearScreen);
  // Hide cursor
  stdout.write(Ansi.hideCursor);

  try {
    logToFile('Has terminal: ${stdin.hasTerminal}');
    await runApp(DemoApp());
  } catch (e) {
    logToFile('Error occurred: $e');
    print(e);
  } finally {
    logToFile('Entering finally block');
    logSttyState('Pre-cleanup');
    // Cleanup
    logToFile('Cleanup: hasTerminal=${stdin.hasTerminal}');

    // Forceful restore using stty (Linux/Mac) via /dev/tty
    try {
      final process = await Process.start('sh', [
        '-c',
        'stty echo icanon < /dev/tty',
      ], mode: ProcessStartMode.inheritStdio);
      final exitCode = await process.exitCode;
      logToFile('stty exit code: $exitCode');
    } catch (e) {
      logToFile('Failed to run stty: $e');
    }
    stdout.write(Ansi.showCursor);
    stdout.write(Ansi.disableAltBuffer);
    await stdout.flush();
    logSttyState('Post-cleanup');
    logToFile('Demo application finished');
  }
}
