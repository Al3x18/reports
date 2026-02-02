import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/create_account_view.dart';
import 'package:reports/view/forgot_password_view.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/utils/app_version_control.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailFormController = TextEditingController();
  final TextEditingController passwordFormController = TextEditingController();

  bool passwordObscureText = true;
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    ref.read(loginViewModelProvider.notifier).loadAppVersion();
    ref.read(loginViewModelProvider.notifier).loadRememberMe();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppVersionControl().checkAppVersion(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginVm = ref.watch(loginViewModelProvider);
    final authVm = ref.watch(authViewModelProvider);
    final isAuthenticating = authVm.isLoading;
    final dark = Theme.of(context).brightness == Brightness.dark;

    void login() async {
      final state = formKey.currentState;
      if (state == null || !state.validate()) return;
      state.save();
      if (!context.mounted) return;
      FocusScope.of(context).unfocus();

      final result = await ref
          .read(authViewModelProvider.notifier)
          .signInWithEmailAndPassword(email: email, password: password);

      if (!context.mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(right: 18, left: 18),
            content: Text(
              result.errorMessage ?? 'Authentication failed',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      }
    }

    void downloadLatestAppVersion() async {
      if (Platform.isAndroid) {
        final latest = await AppVersionControl().latestVersionAvailable;
        if (ref.read(loginViewModelProvider).isLatestVersion(latest)) {
          if (!context.mounted) return;
          AlertDialogs().snackBarAlertNotToCompile(
            context,
            'You already have the latest version installed.',
          );
        } else {
          ref.read(loginViewModelProvider.notifier).setDownloadButtonPressed(true);
          if (!context.mounted) return;
          AppVersionControl().downloadNewVersion(context);
          await Future.delayed(const Duration(seconds: 4));
          ref.read(loginViewModelProvider.notifier).setDownloadButtonPressed(false);
        }
      } else {
        AlertDialogs().snackBarAlertNotToCompile(
          context,
          'This feature is only available for Android devices.',
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                  Text('Log In into Reports App',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8.0),
                  Text(
                    'Enter your e-mail and password then press login',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailFormController,
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
                        controller: passwordFormController,
                        obscureText: passwordObscureText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.key),
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                            onLongPressStart: (_) {
                              setState(() => passwordObscureText = false);
                            },
                            onLongPressEnd: (_) {
                              setState(() => passwordObscureText = true);
                            },
                            child: const Icon(Icons.remove_red_eye_outlined),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          return null;
                        },
                        onSaved: (newValue) => password = newValue ?? '',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox.adaptive(
                                activeColor: const Color.fromARGB(255, 217, 192, 80),
                                checkColor: Colors.black,
                                value: loginVm.rememberBoxValue,
                                onChanged: (value) {
                                  ref
                                      .read(loginViewModelProvider.notifier)
                                      .saveRememberMe(value ?? false);
                                },
                              ),
                              const Text('Remember Me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordView(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 216, 185, 48),
                              ),
                            ),
                          ),
                        ],
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
                          onPressed: login,
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
                              : const Text('Log In'),
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
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateAccountView(),
                                    ),
                                  );
                                  emailFormController.clear();
                                  passwordFormController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                          child: const Text('Create an Account'),
                        ),
                      ),
                      const SizedBox(height: 0.6),
                      Text(
                        'App version: ${loginVm.appVersion}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: downloadLatestAppVersion,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 5),
                            loginVm.isDownloadButtonPressed
                                ? const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 1.2,
                                      backgroundColor: Colors.grey,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Download latest app version',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 21.4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Divider(
                      color: !isAuthenticating
                          ? (dark ? Colors.grey : Colors.black)
                          : (dark
                              ? const Color.fromARGB(100, 158, 158, 158)
                              : const Color.fromARGB(100, 0, 0, 0)),
                      thickness: 0.5,
                      indent: 60,
                      endIndent: 5,
                    ),
                  ),
                  Text(
                    'Or Sign In With',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: !isAuthenticating
                          ? (dark ? Colors.white : Colors.black)
                          : (dark
                              ? const Color.fromARGB(150, 255, 255, 255)
                              : const Color.fromARGB(150, 0, 0, 0)),
                    ),
                  ),
                  Flexible(
                    child: Divider(
                      color: !isAuthenticating
                          ? (dark ? Colors.grey : Colors.black)
                          : (dark
                              ? const Color.fromARGB(100, 158, 158, 158)
                              : const Color.fromARGB(100, 0, 0, 0)),
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () =>
                        AlertDialogs().snackBarAlertNotImplementedFeature(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.8,
                          color: !isAuthenticating
                              ? (dark ? Colors.white : Colors.black)
                              : (dark
                                  ? const Color.fromARGB(100, 255, 255, 255)
                                  : const Color.fromARGB(100, 0, 0, 0)),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image(
                          width: 24,
                          height: 24,
                          image: AssetImage('assets/images/google_logo.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () =>
                        AlertDialogs().snackBarAlertNotImplementedFeature(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.8,
                          color: !isAuthenticating
                              ? (dark ? Colors.white : Colors.black)
                              : (dark
                                  ? const Color.fromARGB(100, 255, 255, 255)
                                  : const Color.fromARGB(100, 0, 0, 0)),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image(
                          width: 24,
                          height: 24,
                          image: AssetImage('assets/images/facebook_logo.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
