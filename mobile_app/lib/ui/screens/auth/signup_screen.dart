import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: c.signupFormKey,
            child: Column(
              children: [
                SizedBox(height: h * 0.03),
                _logo(),
                const SizedBox(height: 16),
                _txt('إنشاء حساب جديد', 28, FontWeight.w800, const Color(0xFF2D3436)),
                const SizedBox(height: 8),
                _txt('انضم إلينا لرعاية طفلك بأفضل طريقة', 14, FontWeight.w400, const Color(0xFF636E72)),
                SizedBox(height: h * 0.03),

                _label('الاسم الكامل'),
                const SizedBox(height: 8),
                _nameField(c),
                const SizedBox(height: 18),

                _label('البريد الإلكتروني'),
                const SizedBox(height: 8),
                _emailField(c),
                const SizedBox(height: 18),

                _label('كلمة المرور'),
                const SizedBox(height: 8),
                _passField(c, c.passwordController, c.obscurePassword, c.togglePasswordVisibility, 'أدخل كلمة المرور'),
                const SizedBox(height: 18),

                _label('تأكيد كلمة المرور'),
                const SizedBox(height: 8),
                _passField(c, c.confirmPasswordController, c.obscureConfirmPassword, c.toggleConfirmPasswordVisibility, 'أعد إدخال كلمة المرور'),
                const SizedBox(height: 28),

                _signupBtn(c),
                const SizedBox(height: 24),
                _loginLink(c),
                const SizedBox(height: 12),
                _guestBtn(),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() => Container(
    width: 64, height: 64,
    decoration: BoxDecoration(
      color: const Color(0xFF8DC5A2), shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: const Color(0xFF8DC5A2).withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 6))],
    ),
    child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 28),
  );

  Widget _txt(String t, double s, FontWeight w, Color c) =>
      Text(t, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: s, fontWeight: w, color: c, height: 1.5));

  Widget _label(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(t, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))),
  );

  InputDecoration _deco(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFB2BEC3)),
    prefixIcon: Icon(icon, color: const Color(0xFFB2BEC3), size: 22),
    suffixIcon: suffix, filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF8DC5A2), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _nameField(AuthController c) => TextFormField(
    controller: c.fullNameController, textAlign: TextAlign.right,
    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
    decoration: _deco('أدخل اسمك الكامل', Icons.person_outline_rounded),
    validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم' : null,
  );

  Widget _emailField(AuthController c) => TextFormField(
    controller: c.emailController, keyboardType: TextInputType.emailAddress,
    textDirection: TextDirection.ltr, textAlign: TextAlign.right,
    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
    decoration: _deco('example@mail.com', Icons.mail_outline_rounded),
    validator: (v) {
      if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
      if (!GetUtils.isEmail(v)) return 'بريد إلكتروني غير صحيح';
      return null;
    },
  );

  Widget _passField(AuthController c, TextEditingController ctrl, RxBool obs, VoidCallback toggle, String hint) => Obx(() => TextFormField(
    controller: ctrl, obscureText: obs.value,
    textDirection: TextDirection.ltr, textAlign: TextAlign.right,
    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
    decoration: _deco(hint, Icons.lock_outline_rounded,
      suffix: IconButton(onPressed: toggle, icon: Icon(obs.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFB2BEC3), size: 22)),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
      if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
      return null;
    },
  ));

  Widget _signupBtn(AuthController c) => Obx(() => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton(
      onPressed: c.isLoading.value ? null : c.signUp,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: c.isLoading.value
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Text('إنشاء حساب', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
    ),
  ));

  Widget _loginLink(AuthController c) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('لديك حساب بالفعل؟', style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF636E72))),
    TextButton(
      onPressed: () { c.clearSignupFields(); Get.back(); },
      child: Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF5DB075))),
    ),
  ]);

  Widget _guestBtn() => TextButton(
    onPressed: () => Get.offAllNamed('/home'),
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF636E72),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_back_rounded, size: 18),
        const SizedBox(width: 8),
        Text(
          'الدخول كضيف (تخطي التسجيل)',
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
        ),
      ],
    ),
  );
}
