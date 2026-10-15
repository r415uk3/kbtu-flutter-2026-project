import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();

  final _emailFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  // folds the keyboard when the user taps outside a field
  void _hideKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _done = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return; // Cancel was pressed, keep the old date
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthText.clear();
      _passwordLength = 0;
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              onTapOutside: _hideKeyboard,
              validator: (v) {
                if ((v ?? '').trim().length < 2) {
                  return 'Name is too short';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onTapOutside: _hideKeyboard,
              validator: (v) {
                final text = (v ?? '').trim();
                final at = text.indexOf('@');
                // needs an @ and a dot somewhere after it
                if (at == -1 || text.indexOf('.', at) == -1) {
                  return 'Email looks wrong';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onTapOutside: _hideKeyboard,
              onChanged: (v) {
                setState(() {
                  _passwordLength = v.length;
                });
              },
              validator: (v) {
                if ((v ?? '').length < 8) {
                  return 'Password is too short';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('$_passwordLength of 8'),
            ),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signUp(),
              onTapOutside: _hideKeyboard,
              validator: (v) {
                if (v != _password.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _group,
              decoration: const InputDecoration(labelText: 'Group'),
              items: [
                for (final g in groups)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (g) {
                setState(() {
                  _group = g;
                });
              },
              validator: (g) => g == null ? 'Choose a group' : null,
            ),
            TextFormField(
              controller: _birthText,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
              validator: (_) => _birth == null ? 'Pick your birth date' : null,
            ),
            CheckboxListTile(
              title: const Text('I agree to the rules'),
              value: _agreed,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) {
                setState(() {
                  _agreed = v ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _agreed ? _signUp : null,
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SummaryCard(
            name: _name.text,
            email: _email.text,
            group: _group ?? '',
            birthDate: _birthText.text,
          ),
          TextButton(onPressed: _startOver, child: const Text('Start over')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );
}
