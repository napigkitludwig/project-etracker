import 'package:flutter/material.dart';

/// One entry in the app's primary navigation.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Route path; a location belongs to this destination when it starts with
  /// it (so `/projects/3` highlights "Projects").
  final String path;
}

/// Adaptive frame around every signed-in screen.
///
/// * phones (< 600 dp): bottom [NavigationBar],
/// * tablets (600–1100 dp): compact [NavigationRail],
/// * desktop (≥ 1100 dp): extended rail with the brand, like a sidebar.
///
/// Routing-agnostic: the router passes the current [location] and handles
/// [onSelect].
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.location,
    required this.onSelect,
    required this.child,
    this.brandName = '',
  });

  final List<ShellDestination> destinations;
  final String location;
  final ValueChanged<ShellDestination> onSelect;
  final Widget child;

  /// Shown at the top of the extended rail.
  final String brandName;

  int get _selectedIndex {
    for (int i = 0; i < destinations.length; i++) {
      if (location == destinations[i].path ||
          location.startsWith('${destinations[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int selected = _selectedIndex;

    if (width < 600) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (int index) => onSelect(destinations[index]),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: <NavigationDestination>[
            for (final ShellDestination destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      );
    }

    final bool extended = width >= 1100;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            extended: extended,
            minExtendedWidth: 220,
            selectedIndex: selected,
            onDestinationSelected: (int index) => onSelect(destinations[index]),
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.track_changes,
                      color: theme.colorScheme.onTertiary,
                      size: 20,
                    ),
                  ),
                  if (extended) ...<Widget>[
                    const SizedBox(width: 10),
                    Text(
                      brandName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            destinations: <NavigationRailDestination>[
              for (final ShellDestination destination in destinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(destination.label),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
          Expanded(child: child),
        ],
      ),
    );
  }
}
