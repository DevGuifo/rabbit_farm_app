import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Carte moderne avec glassmorphism optionnel
class BunnyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool useGlass;
  final Color? backgroundColor;
  final bool showBorder;

  const BunnyCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.useGlass = false,
    this.backgroundColor,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      decoration: BoxDecoration(
        color: useGlass
            ? Colors.white.withOpacity(0.1)
            : (backgroundColor ?? AppTheme.cardLight),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: showBorder
            ? Border.all(color: AppTheme.border, width: 1)
            : null,
        boxShadow: useGlass ? null : AppTheme.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Bouton primaire moderne
class BunnyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final BunnyButtonType type;

  const BunnyButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.type = BunnyButtonType.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppTheme.spacing8),
              ],
              Text(text),
            ],
          );

    Widget button;

    switch (type) {
      case BunnyButtonType.primary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
      case BunnyButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
      case BunnyButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
        break;
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum BunnyButtonType { primary, secondary, text }

/// Badge de statut coloré
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool small;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.type,
    this.small = false,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (type) {
      case StatusBadgeType.success:
        return AppTheme.success.withOpacity(0.1);
      case StatusBadgeType.warning:
        return AppTheme.warning.withOpacity(0.1);
      case StatusBadgeType.error:
        return AppTheme.error.withOpacity(0.1);
      case StatusBadgeType.info:
        return AppTheme.info.withOpacity(0.1);
      case StatusBadgeType.neutral:
        return AppTheme.textSecondary.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case StatusBadgeType.success:
        return AppTheme.success;
      case StatusBadgeType.warning:
        return AppTheme.warning;
      case StatusBadgeType.error:
        return AppTheme.error;
      case StatusBadgeType.info:
        return AppTheme.info;
      case StatusBadgeType.neutral:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppTheme.spacing8 : AppTheme.spacing12,
        vertical: small ? AppTheme.spacing4 : AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Text(
        label,
        style: (small ? AppTheme.labelSmall : AppTheme.labelMedium).copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusBadgeType { success, warning, error, info, neutral }

/// Section header avec titre et action optionnelle
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: AppTheme.spacing12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headingSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Statistique card avec icône
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryGreen;

    return BunnyCard(
      onTap: onTap,
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: cardColor, size: 28),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Empty state avec illustration
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing32),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryGreen.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              BunnyButton(
                text: actionLabel!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Info row (label : valeur)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool bold;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.spacing8),
          ],
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action rapide (icône + label)
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double? iconSize;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing12,
          horizontal: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize ?? 28),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte utilitaire avec gradient et icône
class UtilityCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const UtilityCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: AppTheme.spacing16),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headingSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Flèche
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// TextField personnalisé avec styling cohérent
class BunnyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const BunnyTextField({
    Key? key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
      ),
    );
  }
}

/// Dropdown personnalisé avec styling cohérent
class BunnyDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const BunnyDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.itemLabel,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

/// Widget de chargement plein écran
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              Text(
                message!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Overlay de chargement transparent
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(AppTheme.spacing32),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          message!,
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
