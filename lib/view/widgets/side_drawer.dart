import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({
    super.key,
    required this.nameOfUser,
    required this.loadedReports,
    required this.onItemTapped,
    required this.selectedIndex,
    required this.isAdmin,
    required this.onLogout,
    this.onThemeTap,
  });

  final String nameOfUser;
  final int selectedIndex;
  final bool isAdmin;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedReports;
  final Function(int index) onItemTapped;
  final VoidCallback onLogout;
  final VoidCallback? onThemeTap;

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 24,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nameOfUser,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.isAdmin) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 12,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Admin',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                _DrawerTile(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: widget.selectedIndex == 0,
                  onTap: () {
                    widget.onItemTapped(0);
                    Navigator.of(context).pop();
                  },
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                _DrawerTile(
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  label: 'My Reports',
                  selected: widget.selectedIndex == 1,
                  onTap: () {
                    widget.onItemTapped(1);
                    Navigator.of(context).pop();
                  },
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                if (widget.isAdmin)
                  _DrawerTile(
                    icon: Icons.admin_panel_settings_outlined,
                    selectedIcon: Icons.admin_panel_settings_rounded,
                    label: 'Admin Panel',
                    selected: widget.selectedIndex == 2,
                    onTap: () {
                      widget.onItemTapped(2);
                      Navigator.of(context).pop();
                    },
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                const Divider(height: 24),
                if (widget.onThemeTap != null)
                  _DrawerTile(
                    icon: Icons.palette_outlined,
                    selectedIcon: Icons.palette_rounded,
                    label: 'Theme',
                    selected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onThemeTap!();
                    },
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                _DrawerTile(
                  icon: Icons.info_outline_rounded,
                  selectedIcon: Icons.info_rounded,
                  label: 'Info',
                  selected: widget.selectedIndex == 4,
                  onTap: () {
                    widget.onItemTapped(4);
                    Navigator.of(context).pop();
                  },
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const Divider(height: 24),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  selected: false,
                  onTap: widget.onLogout,
                  theme: theme,
                  colorScheme: colorScheme,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
    this.isDestructive = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDestructive
        ? colorScheme.error
        : (selected ? colorScheme.primary : colorScheme.onSurface);
    final effectiveIcon = (selected && selectedIcon != null) ? selectedIcon! : icon;

    return ListTile(
      leading: Icon(
        effectiveIcon,
        size: 24,
        color: effectiveColor,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: effectiveColor,
        ),
      ),
      selected: selected && !isDestructive,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }
}
