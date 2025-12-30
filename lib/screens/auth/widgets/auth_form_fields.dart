import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour les champs du formulaire d'authentification
/// Gère Full Name, Email, Password, Confirm Password avec toggle visibility
class AuthFormFields extends StatefulWidget {
  final bool isSignUp;
  final TextEditingController? fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final VoidCallback? onForgotPassword;

  const AuthFormFields({
    super.key,
    required this.isSignUp,
    this.fullNameController,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    this.onForgotPassword,
  });

  @override
  State<AuthFormFields> createState() => _AuthFormFieldsState();
}

class _AuthFormFieldsState extends State<AuthFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name (uniquement pour Sign Up)
        if (widget.isSignUp && widget.fullNameController != null) ...[
          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: widget.fullNameController!,
            hintText: 'John Doe',
            icon: Icons.person,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
        ],

        // Email Address
        _buildLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.emailController,
          hintText: 'breeder@farm.com',
          icon: Icons.mail,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        // Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: _buildLabel('Password'),
            ),
            if (!widget.isSignUp && widget.onForgotPassword != null)
              GestureDetector(
                onTap: widget.onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNeonGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: widget.passwordController,
          isObscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        // Confirm Password (uniquement pour Sign Up)
        if (widget.isSignUp && widget.confirmPasswordController != null) ...[
          _buildLabel('Confirm Password'),
          const SizedBox(height: 8),
          _buildConfirmPasswordField(
            controller: widget.confirmPasswordController!,
            isObscure: _obscureConfirmPassword,
            onToggle: () =>
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey.shade200 : const Color(0xFF111812),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2e1c) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2a4e2d) : const Color(0xFFdbe6dc),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF111812),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2e1c) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2a4e2d) : const Color(0xFFdbe6dc),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF111812),
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility : Icons.visibility_off,
              color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField({
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2e1c) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2a4e2d) : const Color(0xFFdbe6dc),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF111812),
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          prefixIcon: Icon(
            Icons.lock_reset,
            color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility : Icons.visibility_off,
              color: isDark ? const Color(0xFF4a704e) : const Color(0xFF618965),
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

