---
paths:
  - "**/*.dart"
  - "pubspec.yaml"
  - "pubspec.lock"
---

# Dart/Flutter Rules

## Style
- Format with `dart format` (auto-applied via hooks)
- Follow Effective Dart guidelines
- Use `dart analyze` for lints
- Prefer `final` over `var`

## Flutter
- Keep widgets small and focused
- Use `const` constructors and widgets
- Extract reusable widgets
- Prefer composition over inheritance
- Use `ListView.builder` for long lists

## State Management
- Use Riverpod for complex state
- Keep state close to where it's used
- Avoid global mutable state
- Use `ref.watch` for reactive updates

## Validation
1. `dart format .`
2. `dart analyze`
3. `flutter test`
4. Test on target platforms
