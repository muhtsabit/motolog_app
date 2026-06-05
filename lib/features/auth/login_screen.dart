import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/auth_text_field.dart';
import '../../shared/widgets/or_divider.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_actions.dart';
import '../../core/services/auth_services.dart';
import '../../core/utils/auth_redirect.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService.instance.loginManual(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    await AuthRedirect.navigate(context, userId: result.data!.id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 480 ? 400.0 : screenWidth - 48.0;
    final hPad = (screenWidth - contentWidth) / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AuthHeader(
            title: 'Selamat Datang',
            subtitle: 'Masuk ke akun MotoLog Anda',
            contentWidth: contentWidth,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppConstants.spaceLG,
                hPad,
                MediaQuery.paddingOf(context).bottom + AppConstants.spaceLG,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthTextField(
                      label: 'Email',
                      hint: 'contoh@email.com',
                      controller: _emailCtrl,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!v.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    AuthTextField(
                      label: 'Kata Sandi',
                      hint: 'Masukkan kata sandi',
                      controller: _passwordCtrl,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Kata sandi tidak boleh kosong';
                        }
                        if (v.length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spaceXS,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    AuthPrimaryButton(
                      label: 'Masuk',
                      isLoading: _isLoading,
                      onPressed: _onLogin,
                    ),
                    const SizedBox(height: AppConstants.spaceLG),
                    const OrDivider(),
                    const SizedBox(height: AppConstants.spaceLG),
                    const AuthGoogleButton(),
                    const SizedBox(height: AppConstants.spaceLG),
                    AuthBottomLink(
                      question: 'Belum punya akun? ',
                      actionLabel: 'Daftar',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
