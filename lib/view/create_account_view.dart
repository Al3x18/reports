import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';

const String invalidPasswordWarning =
    'The password must contain:\nAt least one large letter (A,B,C...)\n'
    'At least one small letter (a,b,c...)\nAt least one number (1,2,3...)\n'
    'At least one special character (!,@,%...)\nAnd MUST be at least 8 characters long';

class CreateAccountView extends ConsumerStatefulWidget {
  const CreateAccountView({super.key});

  @override
  ConsumerState<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends ConsumerState<CreateAccountView> {
  final formKey = GlobalKey<FormState>();
  bool passwordObscureText = true;
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    final regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (!regex.hasMatch(value)) return 'Invalid password, check the field below';
    return null;
  }

  Future<void> createAccount() async {
    final state = formKey.currentState;
    if (state == null || !state.validate()) return;
    state.save();

    if (password != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(right: 18, left: 18),
          content: Text(
            'The passwords entered do not match, try again.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );
      return;
    }

    final result = await ref.read(createAccountViewModelProvider.notifier).createAccount(
          name: name,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        );

    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(right: 18, left: 18),
          content: Text(
            result.errorMessage ?? 'Registration failed',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createVm = ref.watch(createAccountViewModelProvider);
    final isAuthenticating = createVm.isAuthenticating;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !isAuthenticating,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const Image(
                          image: AssetImage('assets/images/reports_in_app_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: Image(
                          image: AssetImage(dark
                              ? 'assets/images/reports_logo_d.png'
                              : 'assets/images/reports_logo_l.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Create a New Account',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8.0),
                Text('Complete the form below to create a new account',
                    style: Theme.of(context).textTheme.bodyMedium),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Your Complete Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length < 4) {
                              return 'Please enter a valid Name and Surname';
                            }
                            return null;
                          },
                          onSaved: (newValue) => name = newValue ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.send_rounded),
                            labelText: 'E-Mail',
                          ),
                          validator: (value) {
                            if (value == null || !EmailValidator.validate(value)) {
                              return 'Please enter a valid e-mail address';
                            }
                            return null;
                          },
                          onSaved: (newValue) => email = newValue ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          obscureText: passwordObscureText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.key),
                            labelText: 'Password',
                            suffixIcon: GestureDetector(
                              onLongPressStart: (_) =>
                                  setState(() => passwordObscureText = false),
                              onLongPressEnd: (_) =>
                                  setState(() => passwordObscureText = true),
                              child: const Icon(Icons.remove_red_eye_outlined),
                            ),
                          ),
                          validator: validatePassword,
                          onSaved: (newValue) => password = (newValue ?? '').trim(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          obscureText: passwordObscureText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.key),
                            labelText: 'Confirm Password',
                            suffixIcon: GestureDetector(
                              onLongPressStart: (_) =>
                                  setState(() => passwordObscureText = false),
                              onLongPressEnd: (_) =>
                                  setState(() => passwordObscureText = true),
                              child: const Icon(Icons.remove_red_eye_outlined),
                            ),
                          ),
                          validator: (value) {
                            final r = validatePassword(value);
                            if (r == 'Invalid password, check the field below') {
                              return invalidPasswordWarning;
                            }
                            return r;
                          },
                          onSaved: (newValue) =>
                              confirmPassword = (newValue ?? '').trim(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  const Color.fromARGB(255, 237, 207, 73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: createAccount,
                            child: isAuthenticating
                                ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                      backgroundColor: Colors.black,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.black),
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: !isAuthenticating
                                  ? (dark ? Colors.white : Colors.black)
                                  : (dark
                                      ? const Color.fromARGB(100, 255, 255, 255)
                                      : const Color.fromARGB(150, 0, 0, 0)),
                              side: BorderSide(
                                width: 2,
                                color: !isAuthenticating
                                    ? (dark ? Colors.white : Colors.black)
                                    : (dark
                                        ? const Color.fromARGB(100, 255, 255, 255)
                                        : const Color.fromARGB(100, 0, 0, 0)),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: isAuthenticating
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_ios_new, size: 16),
                                SizedBox(width: 4),
                                Text('Go Back'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
