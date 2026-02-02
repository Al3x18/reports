import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/viewModel/info_view_model.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/utils/app_version_control.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoView extends ConsumerStatefulWidget {
  const InfoView({super.key});

  @override
  ConsumerState<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends ConsumerState<InfoView> {
  @override
  void initState() {
    super.initState();
    ref.read(infoViewModelProvider.notifier).loadAppVersion();
    ref.read(infoViewModelProvider.notifier).loadLatestVersionAvailable();
  }

  Future<void> launchEmail(String emailAddress) async {
    try {
      final email = Uri(scheme: 'mailto', path: emailAddress);
      await launchUrl(email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(infoViewModelProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    'Reports App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text('Version: ${vm.version}'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: () => launchEmail(InfoViewModel.devEmailAddress),
              child: const ListTile(
                title: Text(
                  'Report a Bug',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Send an email to developers'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mail_outlined),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
            ),
            InkWell(
              child: ListTile(
                title: const Text(
                  'Download Latest Version',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Latest version available: ${vm.latestVersionAvailable}',
                ),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
              onTap: () {
                if (Platform.isAndroid) {
                  AppVersionControl().downloadNewVersion(context);
                }
                if (Platform.isIOS) {
                  AlertDialogs().snackBarAlertNotToCompile(
                    context,
                    'This feature is only available for Android devices.',
                  );
                }
              },
            ),
            const Spacer(),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Developed By:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    InfoViewModel.devName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
