import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            key: c.loginFormKey,
            child: Column(
              children: [
                SizedBox(height: h * 0.04),
                _buildLogo(),
                const SizedBox(height: 20),
                _title('رعاية الطفل'),
                const SizedBox(height: 8),
                _subtitle('مرحباً بك في عالم الرعاية الهادئة لطفلك\nالصغير'),
                SizedBox(height: h * 0.04),
                _label('البريد الإلكتروني'),
                const SizedBox(height: 8),
                _emailField(c),
                const SizedBox(height: 20),
                _label('كلمة المرور'),
                const SizedBox(height: 8),
                _passwordField(c),
                const SizedBox(height: 8),
                _forgotBtn(c),
                const SizedBox(height: 24),
                _loginBtn(c),
                const SizedBox(height: 28),
                _divider(),
                const SizedBox(height: 20),
                _socialRow(),
                const SizedBox(height: 32),
                _signupLink(c),
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

  Widget _buildLogo() => Container(
    width: 72, height: 72,
    decoration: BoxDecoration(
      color: const Color(0xFF8DC5A2), shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: const Color(0xFF8DC5A2).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: const Center(child: Text('☺', style: TextStyle(fontSize: 32))),
  );

  Widget _title(String t) => Text(t, style: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436)));

  Widget _subtitle(String t) => Text(t, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF636E72), height: 1.6));

  Widget _label(String t) => Align(alignment: Alignment.centerRight, child: Text(t, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))));

  InputDecoration _inputDeco({required String hint, required IconData icon, Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFB2BEC3)),
    prefixIcon: Icon(icon, color: const Color(0xFFB2BEC3), size: 22),
    suffixIcon: suffix, filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF8DC5A2), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _emailField(AuthController c) => TextFormField(
    controller: c.emailController, keyboardType: TextInputType.emailAddress,
    textDirection: TextDirection.ltr, textAlign: TextAlign.right,
    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
    decoration: _inputDeco(hint: 'example@mail.com', icon: Icons.mail_outline_rounded),
    validator: (v) {
      if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
      if (!GetUtils.isEmail(v)) return 'الرجاء إدخال بريد إلكتروني صحيح';
      return null;
    },
  );

  Widget _passwordField(AuthController c) => Obx(() => TextFormField(
    controller: c.passwordController, obscureText: c.obscurePassword.value,
    textDirection: TextDirection.ltr, textAlign: TextAlign.right,
    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
    decoration: _inputDeco(
      hint: '••••••••', icon: Icons.lock_outline_rounded,
      suffix: IconButton(onPressed: c.togglePasswordVisibility, icon: Icon(c.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFB2BEC3), size: 22)),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
      if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      return null;
    },
  ));

  Widget _forgotBtn(AuthController c) => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: c.forgotPassword,
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      child: Text('نسيت كلمة المرور؟', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF636E72))),
    ),
  );

  Widget _loginBtn(AuthController c) => Obx(() => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton(
      onPressed: c.isLoading.value ? null : c.login,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: c.isLoading.value
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
    ),
  ));

  Widget _divider() => Row(children: [
    Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('أو المتابعة عبر', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF636E72)))),
    Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
  ]);

  Widget _socialRow() => Row(children: [
    Expanded(child: _socialBtn('جوجل', const FaIcon(FontAwesomeIcons.google, size: 18, color: Color(0xFFDB4437)))),
    const SizedBox(width: 16),
    Expanded(child: _socialBtn('آبل  iOS', const FaIcon(FontAwesomeIcons.apple, size: 20, color: Color(0xFF2D3436)))),
  ]);

  Widget _socialBtn(String label, Widget icon) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: () => Get.snackbar('قريباً', 'قيد التطوير', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E8E8))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [icon, const SizedBox(width: 10), Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436)))]),
      ),
    ),
  );

  Widget _signupLink(AuthController c) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('ليس لديك حساب؟', style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF636E72))),
    TextButton(onPressed: () { c.clearLoginFields(); Get.toNamed('/signup'); },
      child: Text('إنشاء حساب جديد', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF5DB075)))),
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
