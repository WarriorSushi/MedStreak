import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/game/domain/models/medical_parameter.dart';
import '../../../../features/settings/application/providers/settings_provider.dart';

/// Settings screen that allows the user to customize their experience
/// Includes toggles for unit system (SI vs Conventional) and sex context (Male vs Female)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Game Preferences'),
              const SizedBox(height: 16),

              // Unit System Preference
              _buildUnitSystemSelector(context, settings, ref),
              const SizedBox(height: 24),

              // Sex Context Preference
              _buildSexContextSelector(context, settings, ref),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'App Settings'),
              const SizedBox(height: 16),

              // Dark Mode Toggle
              _buildSettingToggle(
                context: context,
                title: 'Dark Mode',
                subtitle: 'Use dark theme for the app',
                value: settings.darkMode,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleDarkMode(),
                icon: Icons.dark_mode,
              ),
              const SizedBox(height: 16),

              // Notifications Toggle
              _buildSettingToggle(
                context: context,
                title: 'Notifications',
                subtitle: 'Enable push notifications',
                value: settings.notificationsEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleNotifications(),
                icon: Icons.notifications,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'About'),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                onTap: () {
                  /* Show app info */
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a section header with a divider
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  /// Builds the unit system selector (SI vs Conventional)
  Widget _buildUnitSystemSelector(
    BuildContext context,
    SettingsState settings,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit System',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Choose between SI and Conventional units',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                context: context,
                title: 'SI Units',
                subtitle: 'mmol/L, µmol/L',
                isSelected: settings.unitSystem == UnitSystem.si,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setUnitSystem(UnitSystem.si),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectionCard(
                context: context,
                title: 'Conventional',
                subtitle: 'mg/dL, ng/mL',
                isSelected: settings.unitSystem == UnitSystem.conventional,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setUnitSystem(UnitSystem.conventional),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the sex context selector (Male vs Female vs Neutral)
  Widget _buildSexContextSelector(
    BuildContext context,
    SettingsState settings,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Ranges',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Select which reference ranges to use',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                context: context,
                title: 'Male',
                subtitle: 'Male reference ranges',
                isSelected: settings.sexContext == SexContext.male,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setSexContext(SexContext.male),
                icon: Icons.male,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectionCard(
                context: context,
                title: 'Female',
                subtitle: 'Female reference ranges',
                isSelected: settings.sexContext == SexContext.female,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setSexContext(SexContext.female),
                icon: Icons.female,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectionCard(
                context: context,
                title: 'Neutral',
                subtitle: 'Average ranges',
                isSelected: settings.sexContext == SexContext.neutral,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setSexContext(SexContext.neutral),
                icon: Icons.people,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a selection card for options like unit system or sex context
  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardTheme.color,
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.8)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a toggle setting with title, subtitle, and icon
  Widget _buildSettingToggle({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
