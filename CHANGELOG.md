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
