## 2.0.2

- Update `intl` dependency to ^0.20.0 for latest version support
- Fix deprecated `value` parameter in DropdownButtonFormField (use `initialValue`)

## 2.0.1

- Fix demo GIF not displaying on pub.dev (use absolute GitHub URL)

## 2.0.0

Major update with new field types, core refactoring, and UX enhancements.

### New Features
- **SmartDropdown**: A smart-styled dropdown button with validation.
- **SmartCheckbox**: A smart checkbox tile with error message support.
- **SmartDatePicker**: A smart wrapper for choosing dates.
- **Autovalidate Mode**: Added support for `AutovalidateMode` in `SmartField`.
- **Haptic Feedback**: Forms now provide subtle haptic feedback on validation errors.

### Improvements & Refactoring
- **Generic Registration**: The core registration system now supports any data type, making it easier to build custom smart fields.
- **Dependency Update**: Added `intl` for better date formatting in `SmartDatePicker`.
- **Better API**: `SmartValidators` now use generics for cleaner type checking.

---

## 0.1.0

Initial release of smart_form_guard — forms that guide users instead of punishing them.

### Features

- **SmartForm**: Form wrapper that owns validation and controller logic
- **SmartField**: Pre-built field types with built-in validation
  - `SmartField.email()` — Email input with validation
  - `SmartField.password()` — Password with visibility toggle and strength validation
  - `SmartField.required()` — Required text field
  - `SmartField.phone()` — Phone number input
- **SmartValidators**: Composable validators with human-friendly messages
  - `required`, `email`, `password`, `phone`, `minLength`, `maxLength`, `pattern`
  - `compose()` for combining multiple validators
- **SmartSubmitButton**: Submit button that triggers validation
- **Auto-focus**: First invalid field receives focus on submit
- **Auto-scroll**: Scrolls to off-screen errors smoothly
- **Shake animation**: Visual feedback for invalid fields
- **Soft glow effect**: Subtle visual indicator on errors
