import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../models/portee.dart';

class SevrageHeader extends StatelessWidget {
  final Portee portee;
  final VoidCallback onBack;

  const SevrageHeader({super.key, required this.portee, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.primaryGreen),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppTheme.textOnPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sevrage de la portée', style: AppTheme.titleLarge),
                Text(
                  'Née le ${DateFormat('dd/MM/yyyy').format(portee.dateMiseBasReelle)} • ${portee.ageEnJours} jours',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textOnPrimary70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
