# smart_form_guard

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Package-blue?logo=flutter" alt="Flutter Package"/>
  <img src="https://img.shields.io/badge/version-0.1.0-green" alt="Version"/>
  <img src="https://img.shields.io/badge/license-MIT-purple" alt="License"/>
</p>

> **Forms that guide users instead of punishing them.**

A smart Flutter form wrapper that validates fields, auto-focuses & scrolls to the first invalid field, and provides pleasant visual feedback with shake animations and soft glow effects.

## ✨ Features

- 🎯 **Auto-focus** first invalid field on submit
- 📜 **Auto-scroll** to off-screen errors
- 🌊 **Shake animation** for invalid fields
- ✨ **Soft glow** effect on errors
- 🔄 **Progressive validation** (one error at a time)
- 📦 **Zero configuration** for common use cases
- 🎨 **Customizable** styling and behavior

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_form_guard: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:smart_form_guard/smart_form_guard.dart';

SmartForm(
  onValid: () => print("Form is valid 🎉"),
  child: Column(
    children: [
      SmartField.email(
        controller: emailCtrl,
        label: "Email",
      ),
      SmartField.password(
        controller: passCtrl,
        label: "Password",
      ),
      SmartSubmitButton(
        text: "Create account",
      ),
    ],
  ),
);
```

## 📖 API Reference

### SmartForm

The main wrapper for your form fields.

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | Form content (required) |
| `onValid` | `VoidCallback?` | Called when form is valid |
| `onInvalid` | `VoidCallback?` | Called when validation fails |
| `controller` | `SmartFormController?` | Optional external controller |

### SmartField

Input field with built-in validation and animations.

#### Factory Constructors

| Constructor | Description |
|-------------|-------------|
| `SmartField.email()` | Email input with validation |
| `SmartField.password()` | Password with visibility toggle |
| `SmartField.required()` | Required text field |
| `SmartField.phone()` | Phone number input |

#### Common Properties

| Property | Type | Default |
|----------|------|---------|
| `controller` | `TextEditingController` | Required |
| `label` | `String?` | null |
| `hint` | `String?` | null |
| `enabled` | `bool` | true |

### SmartSubmitButton

Triggers form validation on press.

| Property | Type | Default |
|----------|------|---------|
| `text` | `String` | Required |
| `onPressed` | `VoidCallback?` | null |
| `icon` | `IconData?` | null |
| `showLoading` | `bool` | true |

### SmartValidators

Utility class with common validators.

```dart
// Compose multiple validators
SmartValidators.compose([
  SmartValidators.required('Field is required'),
  SmartValidators.email('Invalid email'),
]);

// Available validators
SmartValidators.required()
SmartValidators.email()
SmartValidators.password(minLength: 8, requireUppercase: true)
SmartValidators.phone()
SmartValidators.minLength(5)
SmartValidators.maxLength(100)
SmartValidators.pattern(RegExp(r'...'))
```

## 🎨 Customization

### Custom Field

```dart
SmartField(
  controller: controller,
  label: 'Custom Field',
  validator: SmartValidators.compose([
    SmartValidators.required(),
    SmartValidators.minLength(3),
  ]),
  prefixIcon: Icons.star,
  decoration: InputDecoration(...),
)
```

### Custom Submit Button

```dart
SmartSubmitButton(
  text: 'Submit',
  backgroundColor: Colors.indigo,
  textColor: Colors.white,
  borderRadius: 16,
  icon: Icons.send,
)
```

## 🧪 Testing

```bash
flutter test
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

Made with ❤️ for the Flutter community
