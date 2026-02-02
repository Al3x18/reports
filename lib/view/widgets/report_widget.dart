import 'package:flutter/material.dart';

class ReportWidget extends StatelessWidget {
  const ReportWidget({
    super.key,
    this.author = "",
    required this.title,
    required this.reportPlace,
    required this.reportDate,
  });

  final String author;
  final String? reportPlace;
  final String? reportDate;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = reportDate ?? '';
    final completeDate = dateStr.split(" ");
    final shortDateWithHour = completeDate.length >= 4
        ? "${completeDate[0]} ${completeDate[1]} ${completeDate[3]}"
        : dateStr;

    final accentColor = colorScheme.primary;
    final surfaceVariant = colorScheme.surfaceContainerHighest;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (author.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 16, color: onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              reportPlace ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: surfaceVariant.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded, size: 14, color: onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  shortDateWithHour,
                                  style: theme.textTheme.labelSmall?.copyWith(color: onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
