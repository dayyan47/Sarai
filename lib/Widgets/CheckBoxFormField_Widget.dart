import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    Widget? title,
    required bool value,
    BuildContext? context,
    super.onSaved,
    super.validator,
    bool super.initialValue = false,
    ValueChanged<bool>? onChanged,
    super.autovalidateMode,
    bool enabled = true,
    bool dense = false,
    Color? errorColor,
    Color? activeColor,
    Color? checkColor,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    EdgeInsetsGeometry? contentPadding,
    bool autofocus = false,
    Widget? secondary,
  }) : super(
    builder: (FormFieldState<bool> state) {
      errorColor ??=
      (context == null ? Colors.red : Theme.of(context).colorScheme.error);

      return CheckboxListTile(
        title: title,
        dense: dense,
        activeColor: activeColor,
        checkColor: checkColor,
        value: value,
        onChanged: enabled
            ? (value) {
          state.didChange(value);
          if (onChanged != null) onChanged(value!);
        }
            : null,
        subtitle: state.hasError
            ? Text(
          state.errorText!,
          style: TextStyle(color: errorColor),
        )
            : null,
        controlAffinity: controlAffinity,
        secondary: secondary,
        contentPadding: contentPadding,
        autofocus: autofocus,
      );
    },
  );
}
