import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/add_new_report_view.dart';
import 'package:reports/view/admin_panel_view.dart';
import 'package:reports/view/info_view.dart';
import 'package:reports/view/my_reports_view.dart';
import 'package:reports/view/settings_view.dart';
import 'package:reports/delegates/my_search_delegate.dart';
import 'package:reports/view/widgets/general_loading.dart';
import 'package:reports/utils/app_version_control.dart';
import 'package:reports/view/widgets/all_reports_v2.dart';
import 'package:reports/view/widgets/report_details.dart';
import 'package:reports/view/widgets/side_drawer.dart';
import 'package:reports/view/widgets/theme_mode_modal_sheet.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsViewModelProvider.notifier).loadCurrentUserProfile();
      AppVersionControl().checkAppVersion(context);
    });
  }

  void openReportDetails(
    BuildContext context,
    String title,
    String author,
    String place,
    String date,
    String desc,
    String imageUrl,
  ) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (ctx) => SingleChildScrollView(
        child: ReportDetails(
          title: title,
          author: author,
          place: place,
          date: date,
          description: desc,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  void addReport(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (ctx) => const SingleChildScrollView(
        child: AddNewReportView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsVm = ref.watch(reportsViewModelProvider);
    final usersStream = ref.read(reportsViewModelProvider).usersStream;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (!reportsVm.isConnected) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No connection available.\n'
                      'Check your internet connection and try again.',
                    ),
                    const SizedBox(height: 28),
                    TextButton(
                      onPressed: () => ref.read(reportsViewModelProvider.notifier).checkConnectivity(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GeneralLoadingScreen();
        }

        final snapshotData = snapshot.data;
        if (!snapshot.hasData || snapshotData == null || snapshotData.docs.isEmpty) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 252, 245, 237),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 252, 245, 237),
              title: const Text('Reports List'),
              actions: [
                IconButton(
                  onPressed: () => addReport(context),
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () => ref.read(reportsViewModelProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
            ),
            body: const Center(child: Text('No reports found.')),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 252, 245, 237),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 252, 245, 237),
              title: const Text('Error Page'),
            ),
            body: Center(
              child: Column(
                children: [
                  const Text('Something went wrong.'),
                  ElevatedButton(
                    onPressed: () => ref.read(reportsViewModelProvider.notifier).logout(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        final loadedReports = snapshotData.docs;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              reportsVm.selectedIndex == 0
                  ? 'Reports List'
                  : reportsVm.selectedIndex == 1
                      ? 'My Reports'
                      : reportsVm.selectedIndex == 2
                          ? 'Admin Panel'
                          : reportsVm.selectedIndex == 3
                              ? 'Settings'
                              : 'Info',
            ),
            actions: [
              IconButton(
                onPressed: () => showThemeModeModalSheet(context, ref),
                icon: const Icon(Icons.tune_outlined),
              ),
              if (reportsVm.selectedIndex == 0)
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: MySearchDelegate(
                        reports: loadedReports,
                        openReportDetails: (
                          String title,
                          String author,
                          String place,
                          String date,
                          String description,
                          String imageUrl,
                        ) =>
                            openReportDetails(
                          context,
                          title,
                          author,
                          place,
                          date,
                          description,
                          imageUrl,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
            ],
          ),
          floatingActionButton: reportsVm.selectedIndex == 0 || reportsVm.selectedIndex == 1
              ? FloatingActionButton(
                  tooltip: 'Add new report',
                  backgroundColor: dark ? Colors.white : Colors.blue,
                  foregroundColor: dark ? Colors.black : Colors.white,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    addReport(context);
                  },
                  child: const Icon(Icons.add, size: 25),
                )
              : null,
          drawer: SideDrawer(
            nameOfUser: reportsVm.nameOfUser,
            isAdmin: reportsVm.isUserAdmin,
            loadedReports: loadedReports,
            onItemTapped: (index) => ref.read(reportsViewModelProvider.notifier).selectedIndex = index,
            selectedIndex: reportsVm.selectedIndex,
            onThemeTap: () => showThemeModeModalSheet(context, ref),
            onLogout: () {
              Navigator.of(context).pop(); // close drawer
              showAdaptiveDialog(
                context: context,
                builder: (ctx) => AlertDialog.adaptive(
                  title: const Text('Really want to logout?'),
                  content: const Text('Do you still remember your password?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(reportsViewModelProvider.notifier).logout();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          body: IndexedStack(
            index: reportsVm.selectedIndex,
            children: [
              AllReportsV2(
                loadedReports: loadedReports,
                openReportDetails: (
                  String title,
                  String author,
                  String place,
                  String date,
                  String description,
                  String imageUrl,
                ) =>
                    openReportDetails(
                  context,
                  title,
                  author,
                  place,
                  date,
                  description,
                  imageUrl,
                ),
              ),
              MyReportsView(
                openReportDetails: (
                  String title,
                  String author,
                  String place,
                  String date,
                  String description,
                  String imageUrl,
                ) =>
                    openReportDetails(
                  context,
                  title,
                  author,
                  place,
                  date,
                  description,
                  imageUrl,
                ),
              ),
              const AdminPanelView(),
              const SettingsView(),
              const InfoView(),
            ],
          ),
        );
      },
    );
  }
}
