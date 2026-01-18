# flutterlike_tui

## Project Overview

`flutterlike_tui` is a Dart framework for building Terminal User Interfaces (TUIs) using an architecture strongly inspired by Flutter. It implements the core Flutter Rendering Pipeline (`Widget` -> `Element` -> `RenderObject`), adapting it for terminal character cells instead of pixels.

**Key Features:**
*   **Flutter-like API:** Uses `StatelessWidget`, `StatefulWidget`, `setState`, and `BuildContext`.
*   **Layout Protocol:** Implements `BoxConstraints`, `Flex`, `Stack`, and other familiar layout primitives.
*   **Rendering Pipeline:** Uses `RenderObject` for layout and painting, with a `Canvas` abstraction that renders to a virtual buffer and diffs changes before writing to stdout (ANSI).
*   **Event Handling:** Supports keyboard and mouse input (via ANSI escape sequences) and propagates them through a hit-test process.

## Architecture

The system mimics Flutter's three trees:
1.  **Widget Tree:** Immutable descriptions of the UI.
2.  **Element Tree:** The mutable instantiation of widgets that manages state and lifecycle.
3.  **RenderObject Tree:** The mutable object tree responsible for layout (geometry) and painting.

### Core Files
*   **`lib/src/widgets/framework.dart`**: Contains the base classes `Widget`, `Element`, `State`, `BuildContext`, and the main `TerminalApp` runner.
*   **`lib/src/rendering/render_object.dart`**: Defines `RenderObject`, `BoxConstraints`, and the layout protocol.
*   **`lib/src/core/terminal.dart`**: Handles low-level terminal interaction (raw mode, size detection, stdin/stdout).

## Directory Structure

*   **`bin/`**: Executable entry points and demos.
    *   `main_demo.dart`: The primary showcase application combining multiple demos.
*   **`lib/src/core/`**: Low-level infrastructure (ANSI codes, Events, Terminal wrapper).
*   **`lib/src/rendering/`**: Layout and painting logic (`RenderObject` subclasses like `RenderFlex`, `RenderStack`).
*   **`lib/src/widgets/`**: Composable widgets (`Container`, `Column`, `Row`, `Text`, `ListView`).

## Building and Running

This is a pure Dart package.

**Prerequisites:**
*   Dart SDK (version ^3.10.4 as per `pubspec.yaml`)

**Run the Main Demo:**
```bash
dart bin/main_demo.dart
```

**Run Specific Demos:**
You can run other files in `bin/` individually, e.g.:
```bash
dart bin/counter_demo.dart
dart bin/layout_demo.dart
```

## Development Conventions

*   **State Management:** Use `StatefulWidget` and `setState` for local state.
*   **Layout:**
    *   Use `Flex`, `Column`, `Row` for linear layouts.
    *   Use `Stack` and `Positioned` for overlapping content.
    *   Custom layout logic belongs in `RenderObject` subclasses.
*   **Input:**
    *   Wrap widgets in `Listener` or `KeyboardListener` to handle events.
    *   Input events are typed (e.g., `KeyDownEvent`, `PointerDownEvent`).
*   **Debugging:**
    *   The `TerminalApp` writes a `render.log` file in the current directory with frame stats and session info.
    *   **Avoid `print()`**: Since the app takes over stdout/rendering, standard `print` calls will mess up the UI. Use a file logger or writing to stderr if necessary (though stderr might also interfere depending on the terminal).

## Common Tasks

**Creating a New Widget:**
Follow the standard Flutter pattern:
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Text('Hello'),
    );
  }
}
```

**Handling Keys:**
```dart
KeyboardListener(
  onKeyEvent: (bytes) {
    if (bytes[0] == Keys.q) {
      // Handle 'q' press
    }
  },
  child: ...
)
```
