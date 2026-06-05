import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_services.dart';
import '../../shared/widgets/auth_text_field.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_actions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false; // toggle view: form ↔ sukses

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
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    final result = await context.read<AuthService>().forgotPassword(
      email: _emailCtrl.text.trim(),
    );

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Terjadi kesalahan.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
      );
    }
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
            title: 'Lupa Kata Sandi',
            subtitle: _emailSent
                ? 'Email reset telah dikirim'
                : 'Masukkan email akun Anda',
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
              child: _emailSent
                  ? _EmailSentView(
                      email: _emailCtrl.text.trim(),
                      onBackToLogin: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      onResend: () => setState(() => _emailSent = false),
                    )
                  : _ForgotPasswordForm(
                      formKey: _formKey,
                      emailCtrl: _emailCtrl,
                      isLoading: _isLoading,
                      onSend: _onSend,
                      onBack: () => Navigator.pop(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

//Form ForgotPass
class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spaceXS),
                Expanded(
                  child: Text(
                    'Kami akan mengirim link reset kata sandi ke email Anda.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.info,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          AuthTextField(
            label: 'Email',
            hint: 'contoh@email.com',
            controller: emailCtrl,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spaceLG),

          AuthPrimaryButton(
            label: 'Kirim Link Reset',
            isLoading: isLoading,
            onPressed: onSend,
          ),
          const SizedBox(height: AppConstants.spaceMD),

          AuthBottomLink(
            question: '',
            actionLabel: 'Kembali ke Login',
            onTap: onBack,
          ),
        ],
      ),
    );
  }
}

class _EmailSentView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onResend;

  const _EmailSentView({
    required this.email,
    required this.onBackToLogin,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spaceXL),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: AppConstants.spaceLG),
        const Text(
          'Email Terkirim!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSM),
        Text(
          'Link reset kata sandi telah dikirim ke',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXS),
        Text(
          'Periksa folder spam jika tidak muncul di kotak masuk.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXL),

        AuthPrimaryButton(
          label: 'Kembali ke Login',
          isLoading: false,
          onPressed: onBackToLogin,
        ),
        const SizedBox(height: AppConstants.spaceMD),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'Tidak menerima email? '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onResend,
                    child: const Text(
                      'Kirim Ulang',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
