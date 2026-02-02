import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/viewModel/add_report_view_model.dart';
import 'package:reports/viewModel/admin_view_model.dart';
import 'package:reports/viewModel/auth_view_model.dart';
import 'package:reports/viewModel/create_account_view_model.dart';
import 'package:reports/viewModel/info_view_model.dart';
import 'package:reports/viewModel/login_view_model.dart';
import 'package:reports/viewModel/manage_user_view_model.dart';
import 'package:reports/viewModel/my_reports_view_model.dart';
import 'package:reports/viewModel/reports_view_model.dart';
import 'package:reports/viewModel/theme_view_model.dart';

/// Theme ViewModel provider. Override with saved theme in main.
final themeViewModelProvider =
    ChangeNotifierProvider<ThemeViewModel>((ref) => ThemeViewModel(initialMode: ThemeMode.system));

/// Auth ViewModel provider (no dependencies).
final authViewModelProvider =
    ChangeNotifierProvider<AuthViewModel>((ref) => AuthViewModel());

/// Login ViewModel provider.
final loginViewModelProvider =
    ChangeNotifierProvider<LoginViewModel>((ref) => LoginViewModel());

/// Create Account ViewModel provider (depends on auth).
final createAccountViewModelProvider = ChangeNotifierProvider<CreateAccountViewModel>(
  (ref) => CreateAccountViewModel(authViewModel: ref.watch(authViewModelProvider)),
);

/// Reports ViewModel provider. Auto-dispose to cancel connectivity subscription.
final reportsViewModelProvider =
    ChangeNotifierProvider.autoDispose<ReportsViewModel>((ref) {
  final vm = ReportsViewModel();
  ref.onDispose(() => vm.cancelConnectivitySubscription());
  return vm;
});

/// Admin ViewModel provider.
final adminViewModelProvider =
    ChangeNotifierProvider<AdminViewModel>((ref) => AdminViewModel());

/// My Reports ViewModel provider.
final myReportsViewModelProvider =
    ChangeNotifierProvider<MyReportsViewModel>((ref) => MyReportsViewModel());

/// Add Report ViewModel provider (scoped to the modal, can be autoDispose).
final addReportViewModelProvider =
    ChangeNotifierProvider.autoDispose<AddReportViewModel>(
  (ref) => AddReportViewModel(),
);

/// Manage User ViewModel provider - family by user details (uid as key).
final manageUserViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<ManageUserViewModel,
        Map<String, dynamic>>((ref, userDetails) {
  return ManageUserViewModel(userDetails: userDetails);
});

/// Info ViewModel provider.
final infoViewModelProvider =
    ChangeNotifierProvider<InfoViewModel>((ref) => InfoViewModel());
