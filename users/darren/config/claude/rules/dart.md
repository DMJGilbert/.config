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

## Security

- Use `flutter_secure_storage` for tokens and keys — not `SharedPreferences` (unencrypted on most platforms)
- Never hardcode API keys or secrets in source — load from environment or secure storage at runtime
- Enforce HTTPS; never override `badCertificateCallback` in production `HttpClient`
- Treat all data from HTTP responses, deep links, and WebView as untrusted input
- Isolate CPU-intensive crypto work with `dart:isolate` to avoid blocking the main thread

## Validation

1. `dart format .`
2. `dart analyze`
3. `flutter test`
4. Test on target platforms
