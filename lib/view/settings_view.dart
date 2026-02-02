import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/app_theme_view.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider).themeMode;
    String themeString = '';
    switch (themeMode.toString().toLowerCase()) {
      case 'thememode.system':
        themeString = 'Use System Settings';
        break;
      case 'thememode.light':
        themeString = 'Light Mode';
        break;
      case 'thememode.dark':
        themeString = 'Dark Mode';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: const Text('Set App Theme'),
            subtitle: Text(themeString),
            leading: const Icon(Icons.color_lens),
            trailing: const Icon(Icons.arrow_forward_ios, size: 19),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AppThemeView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
