import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';

class AppThemeView extends ConsumerStatefulWidget {
  const AppThemeView({super.key});

  @override
  ConsumerState<AppThemeView> createState() => _AppThemeViewState();
}

class _AppThemeViewState extends ConsumerState<AppThemeView> {
  bool isSelectedSystem = false;
  bool isSelectedLight = false;
  bool isSelectedDark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelection(ref.read(themeViewModelProvider).themeMode);
    });
  }

  void _syncSelection(ThemeMode mode) {
    setState(() {
      isSelectedSystem = mode == ThemeMode.system;
      isSelectedLight = mode == ThemeMode.light;
      isSelectedDark = mode == ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeViewModelProvider).themeMode;
    if (!isSelectedSystem && !isSelectedLight && !isSelectedDark) {
      _syncSelection(themeMode);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Theme'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Use System Settings'),
            leading: const Icon(Icons.sync_rounded),
            trailing: isSelectedSystem ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedSystem = true;
                isSelectedLight = false;
                isSelectedDark = false;
              });
              ref
                  .read(themeViewModelProvider.notifier)
                  .setThemeMode(ThemeMode.system);
            },
          ),
          ListTile(
            title: const Text('Light Mode'),
            leading: const Icon(Icons.wb_sunny_outlined),
            trailing: isSelectedLight ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedLight = true;
                isSelectedSystem = false;
                isSelectedDark = false;
              });
              ref
                  .read(themeViewModelProvider.notifier)
                  .setThemeMode(ThemeMode.light);
            },
          ),
          ListTile(
            title: const Text('Dark Mode'),
            leading: const Icon(Icons.nightlight_outlined),
            trailing: isSelectedDark ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedDark = true;
                isSelectedSystem = false;
                isSelectedLight = false;
              });
              ref
                  .read(themeViewModelProvider.notifier)
                  .setThemeMode(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}
