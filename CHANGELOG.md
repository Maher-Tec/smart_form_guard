## 2.2.0

### New Features
- **Granular Email Validation**: SmartField.email() now provides specific error messages (e.g., "Email must contain '@'", "Invalid domain") instead of a generic error.
- **Persistent Valid State**: Fields now show a green validation glow whenever they are valid, providing persistent positive feedback.
- **Improved SmartRadioGroup**: Errors on radio groups now trigger a red border on the radio indicator and label text red color change.

### Improvements & Fixes
- **Robust Scroll-to-Error**: Fixed an issue where "scroll-to-top" was inaccurate when multiple errors appeared. Added post-frame layout detection for precise scrolling.
- **Shake Animation Fix**: Fixed a race condition where the shake animation wouldn't trigger if the form was re-validated quickly or already had an error state.
- **Real-time Defaults**: `SmartField.email()` now defaults to `AutovalidateMode.onUserInteraction` to give immediate feedback.

## 2.1.0

### New Features
- **Async Validation**: Support for asynchronous validators with automatic loading spinners for all fields.
- **SmartRadioGroup**: A polished, animated radio button group widget with full form integration.
- **Confirm Password**: `SmartField.confirmPassword()` factory constructor for matching password fields.

### Improvements
- **Loading Indicators**: All fields now display a loading spinner in the suffix area during async validation.
- **Refined Validation Logic**: SmartForm now prioritizes synchronous validation before executing async checks.

### UI Enhancements
- Fixed `SmartRadioGroup` text visibility issues in dark mode.
- Ensured radio button indicator is always visible even with icons.
- Added green accent color to `SmartRadioGroup` example.

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
