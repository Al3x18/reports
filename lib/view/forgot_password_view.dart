import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String email = '';

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final state = formKey.currentState;
    if (state == null || !state.validate()) return;
    final emailToSend = emailController.text.trim();
    if (emailToSend.isEmpty) return;

    final result = await ref.read(authViewModelProvider.notifier).sendPasswordResetEmail(emailToSend);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final isSuccess = result.success;
    final message = isSuccess
        ? 'If an account is associated with this email, you will receive a password reset link in a few minutes. Please check your spam folder.'
        : (result.errorMessage?.isEmpty ?? true ? 'An error occurred.' : result.errorMessage!);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBg = isSuccess
        ? (isDark ? Colors.grey[800] : Colors.grey[200])
        : (isDark ? Colors.red.shade900 : Colors.red.shade700);
    final snackTextColor = isSuccess
        ? (isDark ? Colors.white : Colors.black)
        : Colors.white;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: snackTextColor),
        ),
        backgroundColor: snackBg,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !auth.isLoading,
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
                          image: AssetImage(dark ? 'assets/images/reports_logo_d.png' : 'assets/images/reports_logo_l.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Forgot Password?', style: Theme.of(context).textTheme.headlineMedium),
                Text('Enter your e-mail below to reset your password', style: Theme.of(context).textTheme.bodyMedium),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: emailController,
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: const Color.fromARGB(255, 237, 207, 73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: auth.isLoading ? null : resetPassword,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                      backgroundColor: Colors.black,
                                      valueColor: AlwaysStoppedAnimation(Colors.black),
                                    ),
                                  )
                                : const Text('Reset Password'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: auth.isLoading ? Colors.grey : (dark ? Colors.white : Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(
                                width: 2,
                                color: auth.isLoading ? Colors.grey : (dark ? Colors.white : Colors.black),
                              ),
                            ),
                            onPressed: auth.isLoading ? null : () => Navigator.of(context).pop(),
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
