import 'package:flutter/material.dart';

/// Widget pour le toggle Sign In / Sign Up
/// Gère l'état actif/inactif des deux onglets
class AuthToggleTabs extends StatelessWidget {
  final bool isSignUp;
  final ValueChanged<bool> onToggle;

  const AuthToggleTabs({
    super.key,
    required this.isSignUp,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2e1c) : const Color(0xFFe8ece8),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Sign In Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isSignUp
                      ? (isDark ? const Color(0xFF2a4e2d) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: !isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: !isSignUp
                          ? (isDark
                              ? Colors.white
                              : const Color(0xFF102212))
                          : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sign Up Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                decoration: BoxDecoration(
                  color: isSignUp
                      ? (isDark ? const Color(0xFF2a4e2d) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSignUp
                          ? (isDark
                              ? Colors.white
                              : const Color(0xFF102212))
                          : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

