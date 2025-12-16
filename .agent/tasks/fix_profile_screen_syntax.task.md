# [x] Fix syntax errors in `lib/screens/profile_screen.dart` to resolve build failures

## Context

Recent modifications to `ProfileScreen` to implement profile persistence and live updates introduced syntax errors (mismatched braces/parentheses) in two locations:

1. The `profile_type` ListTile's `trailing` DropdownButton `onChanged` callback.
2. The `_buildProfileTypeSummary` method's `Container` child list.

## Errors

- `lib/screens/profile_screen.dart:949:19: Error: Can't find ']' to match '['.`
- `lib/screens/profile_screen.dart:559:21: Error: Expected ')' before this.`

## Plan

1. **Fix `profile_type` ListTile**:
   - Locate the `ListTile` for `profile_type`.
   - Correctly close the `DropdownButton`, `Consumer`, and `ListTile` widgets.
   - Ensure the `onChanged` callback logic is properly enclosed.

2. **Fix `_buildProfileTypeSummary`**:
   - Locate the `_buildProfileTypeSummary` method.
   - Verify the `Container` -> `Column` -> `children` nesting.
   - Ensure all opening brackets `[` and braces `{` are matched.

3. **Verification**:
   - Run `flutter analyze lib/screens/profile_screen.dart` to verify fixes.
