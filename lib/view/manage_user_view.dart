import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageUserView extends ConsumerStatefulWidget {
  const ManageUserView({super.key, required this.userDetails});

  final Map<String, dynamic> userDetails;

  @override
  ConsumerState<ManageUserView> createState() => _ManageUserViewState();
}

class _ManageUserViewState extends ConsumerState<ManageUserView> {
  static const bool deactivateDeleteUser = true;

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
    final vm = ref.watch(
      manageUserViewModelProvider(widget.userDetails),
    );
    final notifier = ref.read(
      manageUserViewModelProvider(widget.userDetails).notifier,
    );

    if (vm.errorMessage != null && mounted) {
      final message = vm.errorMessage ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AlertDialogs().fatalErrorDialogMessage(context, message);
        }
      });
    }

    void showDeleteDialog() {
      final navigator = Navigator.of(context);
      showAdaptiveDialog(
        context: context,
        builder: (ctx) => AlertDialog.adaptive(
          title: const Text('Do you want to delete the user?'),
          content: const Text(
            'This action will remove the user and all his data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final deleted = await notifier.deleteUser();
                if (mounted && deleted) navigator.pop();
              },
              child: const Text(
                'CONFIRM',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text(
              'UID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(vm.userDetails['uid'] as String? ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'NAME',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(vm.userDetails['name'] as String? ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text(
              'EMAIL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(vm.userDetails['email'] as String? ?? ''),
            trailing: IconButton(
              onPressed: () =>
                  launchEmail(vm.userDetails['email'] as String? ?? ''),
              icon: const Icon(Icons.mail_outline_outlined),
            ),
          ),
          ListTile(
            leading: vm.isBlocked
                ? const Icon(Icons.lock)
                : const Icon(Icons.lock_open),
            title: const Text(
              'USER BLOCKED',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: vm.isBlocked
                ? const Text('YES', style: TextStyle(color: Colors.red))
                : const Text('NO'),
          ),
          ListTile(
            leading: vm.isAdmin
                ? const Icon(Icons.admin_panel_settings)
                : const Icon(Icons.admin_panel_settings_outlined),
            title: const Text(
              'IS ADMIN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: vm.isAdmin
                ? const Text('YES', style: TextStyle(color: Colors.red))
                : const Text('NO'),
          ),
          ListTile(
            leading: (vm.userDetails['isMasterDeletingActive'] as bool? ?? false)
                ? const Icon(Icons.warning)
                : const Icon(Icons.warning_amber_outlined),
            title: const Text(
              'MASTER DELETING ACTIVE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: (vm.userDetails['isMasterDeletingActive'] as bool? ?? false)
                ? const Text('YES', style: TextStyle(color: Colors.red))
                : const Text('NO'),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text(
              'REPORTS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Number of reports registered: ${(vm.userDetails['reportsList'] as List<dynamic>?)?.length ?? 0}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () =>
                AlertDialogs().snackBarAlertNotImplementedFeature(context),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => notifier.updateBlocked(!vm.isBlocked),
                child: Row(
                  children: [
                    !vm.isBlocked
                        ? const Icon(Icons.lock, size: 14, color: Colors.red)
                        : const Icon(Icons.lock_open_outlined, size: 14),
                    const SizedBox(width: 3),
                    !vm.isBlocked
                        ? const Text('BLOCK USER',
                            style: TextStyle(color: Colors.red))
                        : const Text('UNLOCK USER',
                            style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => notifier.updateAdmin(!vm.isAdmin),
                child: Row(
                  children: [
                    !vm.isAdmin
                        ? const Icon(Icons.admin_panel_settings_outlined,
                            size: 14)
                        : const Icon(Icons.admin_panel_settings, size: 14),
                    const SizedBox(width: 3),
                    !vm.isAdmin
                        ? const Text('MAKE ADMIN',
                            style: TextStyle(color: Colors.blue))
                        : const Text('REMOVE ADMIN STATUS',
                            style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!deactivateDeleteUser)
            TextButton(
              onPressed: showDeleteDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_outlined,
                      size: 18, color: Colors.redAccent),
                  SizedBox(width: 2),
                  Text(
                    'DELETE USER',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
