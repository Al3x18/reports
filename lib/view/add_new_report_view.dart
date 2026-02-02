import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/utils/alert_dialogs.dart';

class AddNewReportView extends ConsumerStatefulWidget {
  const AddNewReportView({super.key});

  @override
  ConsumerState<AddNewReportView> createState() => _AddNewReportViewState();
}

class _AddNewReportViewState extends ConsumerState<AddNewReportView> {
  final formKey = GlobalKey<FormState>();
  String title = '';
  String place = '';
  String reportDescription = '';

  @override
  void initState() {
    super.initState();
    ref.read(addReportViewModelProvider.notifier).loadCurrentUserName();
  }

  void closeView() => Navigator.of(context).pop();

  Future<void> submitReport() async {
    final state = formKey.currentState;
    if (state == null || !state.validate()) return;
    state.save();

    final error = await ref.read(addReportViewModelProvider.notifier).submitReport(
          title: title,
          place: place,
          reportDescription: reportDescription,
        );

    if (!mounted) return;
    if (error == null) {
      closeView();
    } else {
      AlertDialogs().fatalErrorDialogMessage(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vm = ref.watch(addReportViewModelProvider);
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Add new report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Author row - simple inline, no card
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 20, color: onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text(
                    'Author',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.nameOfUser,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Report title',
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: focusedBorder,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title required';
                  }
                  return null;
                },
                onSaved: (newValue) => title = newValue ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Place',
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: focusedBorder,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location, color: colorScheme.primary),
                    onPressed: () =>
                        AlertDialogs().notImplementedAlertCompiled(context),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Place required';
                  }
                  return null;
                },
                onSaved: (newValue) => place = newValue ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: focusedBorder,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description required';
                  }
                  return null;
                },
                onSaved: (newValue) => reportDescription = newValue ?? '',
              ),
              if (vm.selectedImage != null) ...[
                const SizedBox(height: 16),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        vm.selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => ref
                              .read(addReportViewModelProvider.notifier)
                              .clearSelectedImage(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.close, size: 20, color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (vm.selectedImage == null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          ref
                              .read(addReportViewModelProvider.notifier)
                              .selectPhotoFromLibrary();
                        },
                        icon: const Icon(Icons.photo_library_outlined, size: 20),
                        label: const Text('Add photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          ref
                              .read(addReportViewModelProvider.notifier)
                              .takePhotoWithCamera();
                        },
                        icon: const Icon(Icons.photo_camera_outlined, size: 20),
                        label: const Text('Take photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: vm.isLoading ? null : submitReport,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: vm.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          ),
                        )
                      : const Text('Submit report'),
                ),
              ),
              if (!vm.isLoading) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: closeView,
                    child: const Text('Close'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
