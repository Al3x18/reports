import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/widgets/general_loading.dart';
import 'package:reports/view/widgets/report_widget.dart';

typedef OpenReportDetails = void Function(
  String title,
  String author,
  String place,
  String date,
  String description,
  String imageUrl,
);

class MyReportsView extends ConsumerWidget {
  const MyReportsView({super.key, required this.openReportDetails});

  final OpenReportDetails openReportDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(myReportsViewModelProvider);
    final stream = vm.currentUserReportsStream;

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GeneralLoadingScreen();
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No Data Found'));
        }

        final loadedData = data.get('reportsList') as List<dynamic>? ?? [];

        if (loadedData.isEmpty) {
          return const Center(
            child: Text('No Reports Found for Current User.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            itemCount: loadedData.length,
            itemBuilder: (context, index) {
              final report = loadedData[index] as Map<String, dynamic>;
              return Dismissible(
                key: ValueKey(report),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(CupertinoIcons.trash, color: Colors.white),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showAdaptiveDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog.adaptive(
                      title: const Text(
                        'Do You Really Want to Delete this Report?',
                      ),
                      content: const Text(
                        'Warning: This action cannot be undone!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(myReportsViewModelProvider.notifier)
                                .deleteReport(report);
                            Navigator.of(ctx).pop(true);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: InkWell(
                  onTap: () {
                    final title = report['title'] as String? ?? 'No title';
                    final author = report['author'] as String? ?? '';
                    final place = report['place'] as String? ?? '';
                    final description = report['description'] as String? ?? '';
                    final date = report['dateOfSubmission'] as String? ?? '';
                    final imageUrl = report['imageUrl'] as String? ?? '';
                    openReportDetails(
                      title,
                      author,
                      place,
                      date,
                      description,
                      imageUrl,
                    );
                  },
                  child: ReportWidget(
                    title: report['title'] as String? ?? 'No title',
                    reportPlace: report['place'] as String? ?? '',
                    reportDate: report['dateOfSubmission'] as String? ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
