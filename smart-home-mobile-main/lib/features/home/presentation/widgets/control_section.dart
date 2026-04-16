import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/house_state_model.dart';
import '../providers/house_state_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ControlSection extends ConsumerWidget {
  final Controls controls;

  const ControlSection({super.key, required this.controls});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contrôles',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  LucideIcons.lightbulb,
                  color: controls.lightsSalon ? Colors.yellow : Colors.grey,
                ),
                title: const Text('Lumière Salon'),
                trailing: Switch(
                  value: controls.lightsSalon,
                  onChanged: (val) => api.toggleLight('salon', val),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  LucideIcons.lightbulb,
                  color: controls.lightsCuisine ? Colors.yellow : Colors.grey,
                ),
                title: const Text('Lumière Cuisine'),
                trailing: Switch(
                  value: controls.lightsCuisine,
                  onChanged: (val) => api.toggleLight('cuisine', val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Climatisation',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: controls.climatisationMode,
                      onChanged: (val) => api.setClimatisationMode(val!),
                      items: const [
                        DropdownMenuItem(value: 'AUTO', child: Text('AUTO')),
                        DropdownMenuItem(
                            value: 'MANUAL', child: Text('MANUAL')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ModeButton(
                      icon: LucideIcons.power,
                      label: 'OFF',
                      isSelected: controls.climatisation == 'OFF',
                      onPressed: () => api.setClimatisation('OFF'),
                    ),
                    _ModeButton(
                      icon: LucideIcons.snowflake,
                      label: 'COOL',
                      isSelected: controls.climatisation == 'COOL',
                      onPressed: () => api.setClimatisation('COOL'),
                    ),
                    _ModeButton(
                      icon: LucideIcons.flame,
                      label: 'HEAT',
                      isSelected: controls.climatisation == 'HEAT',
                      onPressed: () => api.setClimatisation('HEAT'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Intensité'),
                Slider(
                  value: controls.climatisationIntensity,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${controls.climatisationIntensity.round()}%',
                  onChanged: (val) => api.setClimIntensity(val),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[700]!,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
