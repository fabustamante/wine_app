import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wine_app/core/theme/app_theme.dart';
import 'package:wine_app/core/theme/theme_provider.dart';
import 'package:wine_app/presentation/components/drawer_menu.dart';
import 'package:wine_app/services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  final AuthService auth;

  const SettingsScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeCtrl = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Modo oscuro
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable or disable Dark Mode'),
              value: theme.isDarkMode,
              onChanged: (v) => themeCtrl.toggleDarkMode(v),
            ),
          ),
          const SizedBox(height: 16),

          // Selector de color primario
          Text(
            'Select Theme Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: primaryColors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final color = primaryColors[index];
              final isSelected = index == theme.selectedColor;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => themeCtrl.changeColor(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    if (isSelected)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: color.shade700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => themeCtrl.resetToDefaults(),
            icon: const Icon(Icons.restore),
            label: const Text('Reset Theme'),
          ),
        ],
      ),
      drawer: DrawerMenu(auth: auth),
    );
  }
}
