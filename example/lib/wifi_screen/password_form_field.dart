import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onSaved,
  });
  final String initialValue;
  final ValueChanged<String> onChanged;
  final FormFieldSetter<String> onSaved;

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool isObscureText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 8) {
          return 'The minimum password length is 8';
        }
        return null;
      },
      decoration: InputDecoration(
        suffixIcon: TextButton(
          onPressed: () {
            setState(() {
              isObscureText = !isObscureText;
            });
          },
          child: Icon(
            isObscureText ? Icons.remove_red_eye : Icons.lock_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
