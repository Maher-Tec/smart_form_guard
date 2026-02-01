# smart_form_guard

<p align="center">
  <img src="https://img.shields.io/pub/v/smart_form_guard?color=blue&logo=dart" alt="Pub Version"/>
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-brightgreen" alt="Platform"/>
  <img src="https://img.shields.io/badge/license-MIT-purple" alt="License"/>
</p>

<p align="center">
  <strong>🛡️ Forms that guide users instead of punishing them.</strong>
</p>

<p align="center">
  A smart Flutter form wrapper that validates fields, auto-focuses & scrolls to the first invalid field, and provides pleasant visual feedback with shake animations, soft glow effects, and real-time validation states.
</p>

---

## 🎬 Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/Maher-Tec/smart_form_guard/main/screens/demo.gif" width="300" alt="Smart Form Guard Demo"/>
</p>


---

## ✨ Why smart_form_guard?

| ❌ Traditional Forms | ✅ Smart Form Guard |
|---------------------|---------------------|
| Shows all errors at once | Progressive validation (one at a time) |
| User hunts for invalid fields | Auto-focuses & scrolls to errors |
| Static error messages | Shake animation + glow effects |
| No positive feedback | ✅ Green checkmarks when valid |
| Manual state management | Zero configuration needed |

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| 🎯 **Auto-focus** | Instantly focuses the first invalid field |
| 📜 **Auto-scroll** | Smoothly scrolls to off-screen errors |
| 🌊 **Shake Animation** | Eye-catching shake on validation failure |
| ✨ **Glow Effects** | Red glow for errors, green glow for valid |
| ✅ **Valid State** | Green borders & checkmarks when correct |
| 📳 **Haptic Feedback** | Subtle vibration on errors |
| 🔄 **Real-time Validation** | Optional autovalidate mode |
| 🗂️ **Rich Field Types** | Text, Email, Password, Phone, Dropdown, Checkbox, DatePicker |
| 📦 **Zero Config** | Works out of the box |

---

## 📦 Installation

```yaml
dependencies:
  smart_form_guard: ^2.2.0
```

```bash
flutter pub get
```

---

## 🎯 Quick Start

```dart
import 'package:smart_form_guard/smart_form_guard.dart';

SmartForm(
  onValid: () => print("Form is valid 🎉"),
  child: Column(
    children: [
      SmartField.email(
        controller: emailController,
        label: "Email",
      ),
      SmartField.password(
        controller: passwordController,
        label: "Password",
      ),
      SmartSubmitButton(
        text: "Create Account",
        icon: Icons.arrow_forward,
      ),
    ],
  ),
);
```

That's it! No boilerplate. No manual focus management. No manual scroll logic.

---

## 📖 Available Widgets

### SmartField Constructors

| Widget | Description |
|--------|-------------|
| `SmartField.email()` | Email with validation |
| `SmartField.password()` | Password with toggle & strength rules |
| `SmartField.required()` | Required text field |
| `SmartField.phone()` | Phone number validation |

### Additional Smart Widgets

| Widget | Description |
|--------|-------------|
| `SmartDropdown<T>()` | Dropdown with validation & icons |
| `SmartCheckbox()` | Checkbox for terms/agreements |
| `SmartDatePicker()` | Date selection with validation |
| `SmartRadioGroup<T>()` | Animated radio group with validation |
| `SmartSubmitButton()` | Submit with loading state |

---

## 🎨 Customization Examples

### Custom Validators

```dart
SmartField(
  controller: usernameController,
  label: 'Username',
  validator: SmartValidators.compose([
    SmartValidators.required('Username is required'),
    SmartValidators.minLength(3, 'At least 3 characters'),
    SmartValidators.pattern(
      RegExp(r'^[a-zA-Z0-9_]+$'),
      'Only letters, numbers, and underscores',
    ),
  ]),
  prefixIcon: Icons.person_outline,
)
```

### Password with Custom Rules

```dart
SmartField.password(
  controller: passwordController,
  label: 'Password',
  minLength: 10,
  requireUppercase: true,
  requireLowercase: true,
  requireDigit: true,
  requireSpecialChar: true,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

### Styled Dropdown

```dart
SmartDropdown<String>(
  label: 'Country',
  hint: 'Select your country',
  prefixIcon: Icons.public,
  value: selectedCountry,
  items: countries.map((c) => DropdownMenuItem(
    value: c.code,
    child: Row(children: [
      Text(c.flag),
      SizedBox(width: 8),
      Text(c.name),
    ]),
  )).toList(),
  validator: (v) => v == null ? 'Required' : null,
  onChanged: (v) => setState(() => selectedCountry = v),
)
```

### Async Validation

```dart
SmartField(
  label: 'Username',
  validator: (v) => v!.isEmpty ? 'Required' : null,
  asyncValidator: (v) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API
    if (v == 'admin') return 'Username taken';
    return null;
  },
)
```

### Smart Radio Group

```dart
SmartRadioGroup<String>(
  label: 'Role',
  options: [
    SmartRadioOption(value: 'dev', label: 'Developer', icon: Icons.code),
    SmartRadioOption(value: 'des', label: 'Designer', icon: Icons.brush),
  ],
  onChanged: (val) => print(val),
  validator: (v) => v == null ? 'Select a role' : null,
)
```

---

## ⚙️ SmartForm Options

| Property | Type | Description |
|----------|------|-------------|
| `child` | `Widget` | Form content (required) |
| `onValid` | `VoidCallback?` | Called when form passes validation |
| `onInvalid` | `VoidCallback?` | Called when validation fails |
| `controller` | `SmartFormController?` | External controller for advanced use |
| `enableHapticFeedback` | `bool` | Enable/disable haptics (default: true) |

---

## 🔧 SmartValidators

Pre-built validators with customizable messages:

```dart
SmartValidators.required([message])
SmartValidators.email([message])
SmartValidators.phone([message])
SmartValidators.minLength(length, [message])
SmartValidators.maxLength(length, [message])
SmartValidators.pattern(regex, [message])
SmartValidators.password(
  minLength: 8,
  requireUppercase: true,
  requireLowercase: true,
  requireDigit: true,
  requireSpecialChar: false,
)

// Combine multiple:
SmartValidators.compose([...validators])
```

---

## 🧪 Testing

```bash
flutter test
```

All core functionality is covered with unit tests.

---

## 📋 Version 2.2.0 Highlights
- ✅ **Granular Email Validation**: Real-time feedback for specific errors (e.g. missing '@', invalid domain).
- ✅ **Persistent Valid State**: Green glow now appears whenever a field is valid, ensuring clear positive feedback.
- ✅ **Real-time Validation**: `SmartField.email()` now defaults to `AutovalidateMode.onUserInteraction` for immediate feedback.
- ✅ **UI Fixes**: Enhanced `SmartRadioGroup` error states with red outlines and labels.

## 📋 Version 2.1.0 Highlights
- ✅ **Async Validation**: Validate fields asynchronously with built-in loading spinners.
- ✅ **New Widget**: `SmartRadioGroup` - A premium, animated radio group.
- ✅ **New Field**: `SmartField.confirmPassword()` - Built-in password confirmation logic.
- ✅ **Enhanced Widgets**: Loading indicators added to all fields.

## 📋 Version 2.0.0 Highlights
- ✅ **New Widgets**: SmartDropdown, SmartCheckbox, SmartDatePicker
- ✅ **Valid State UI**: Green borders, glows, and checkmarks
- ✅ **Haptic Feedback**: Subtle vibrations on validation errors
- ✅ **Autovalidate Mode**: Real-time validation support
- ✅ **Generic Validators**: Type-safe validation for any field type
- ✅ **Premium Dropdown**: Icons, elevation, and smooth animations

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for the Flutter community
</p>

<p align="center">
  <a href="https://github.com/Maher-Tec/smart_form_guard">⭐ Star on GitHub</a> •
  <a href="https://github.com/Maher-Tec/smart_form_guard/issues">🐛 Report Bug</a> •
  <a href="https://pub.dev/packages/smart_form_guard">📦 View on pub.dev</a>
</p>
