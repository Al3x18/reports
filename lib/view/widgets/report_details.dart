import 'package:flutter/material.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/view/widgets/image_container_reports_details.dart';

class ReportDetails extends StatelessWidget {
  const ReportDetails({
    super.key,
    required this.author,
    required this.title,
    required this.place,
    required this.date,
    required this.description,
    required this.imageUrl,
  });

  final String author;
  final String title;
  final String place;
  final String description;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final accentColor = colorScheme.primary;

    void closeDetails() => Navigator.of(context).pop();

    void openPlaceInMap() {
      AlertDialogs().notImplementedAlertCompiled(context);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Report details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Author',
                              value: author,
                              theme: theme,
                              onSurfaceVariant: onSurfaceVariant,
                            ),
                            const SizedBox(height: 14),
                            _DetailRow(
                              icon: Icons.description_outlined,
                              label: 'Title',
                              value: title,
                              theme: theme,
                              onSurfaceVariant: onSurfaceVariant,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined, size: 20, color: onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Place',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        place,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.map_outlined, color: accentColor),
                                  onPressed: openPlaceInMap,
                                  style: IconButton.styleFrom(
                                    backgroundColor: accentColor.withValues(alpha: 0.12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _DetailRow(
                              icon: Icons.schedule_rounded,
                              label: 'Date of submission',
                              value: date,
                              theme: theme,
                              onSurfaceVariant: onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes_outlined, size: 20, color: onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              ReportDetailsImageContainer(imageUrl: imageUrl),
            ],
            const SizedBox(height: 24),
            Center(
              child: FilledButton.tonal(
                onPressed: closeDetails,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.onSurfaceVariant,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
