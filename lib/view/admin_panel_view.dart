import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/users_list_view.dart';
import 'package:reports/utils/alert_dialogs.dart';

class AdminPanelView extends ConsumerStatefulWidget {
  const AdminPanelView({super.key});

  @override
  ConsumerState<AdminPanelView> createState() => _AdminPanelViewState();
}

class _AdminPanelViewState extends ConsumerState<AdminPanelView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminViewModelProvider.notifier).loadMasterDeletingState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(adminViewModelProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (vm.errorMessage != null && mounted) {
      final message = vm.errorMessage ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AlertDialogs().fatalErrorDialogMessage(context, message);
        }
      });
    }

    void onSwitchChanged(bool value) async {
      await ref
          .read(adminViewModelProvider.notifier)
          .changeMasterDeletingStatus(value);
      ref.read(adminViewModelProvider.notifier).loadMasterDeletingState();
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
                opacity: vm.isLoading ? 0.6 : 1,
                child: SwitchListTile.adaptive(
                  value: vm.masterDeletingState,
                  title: const Text('Enable Master Deleting'),
                  subtitle: const Text(
                    'Allow the admin account to delete all reports',
                  ),
                  onChanged: vm.isLoading ? null : onSwitchChanged,
                ),
              ),
          const SizedBox(height: 2.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: dark ? Colors.white : Colors.black,
                  side: BorderSide(
                    width: 2,
                    color: dark ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UsersListView(),
                    ),
                  );
                },
                child: const Text(
                  'Manage Users',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
