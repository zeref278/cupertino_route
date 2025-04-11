# Cupertino Route

A Flutter package that enhances navigation with a customizable drag-to-go-back gesture that works from anywhere on the screen, providing a more intuitive and iOS-like navigation experience.

## Features

- 🔙 **Drag from Anywhere**: Navigate back by dragging from anywhere on the screen, not just from the edge
- 🎨 **Beautiful Animations**: Smooth, physics-based animations for transitions
- 📐 **Flexible Integration**: Works with existing navigation systems and state management solutions
- 📱 **Native Feel**: Provides an iOS-like experience on any platform

## Getting Started

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  cupertino_route: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Demo!

[gif](https://github.com/zeref278/cupertino_route/raw/main/media/demo.gif)

## Usage

```dart
import 'package:cupertino_route/cupertino_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Wrap your route in CupertinoRoute to enable drag-from-anywhere feature
      onGenerateRoute: (settings) {
        return CupertinoRoute(
          settings: settings,
          builder: (context) {
            // Your page content
            return YourPage();
          },
        );
      },
      home: HomePage(),
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
