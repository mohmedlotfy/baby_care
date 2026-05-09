import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/infant_profile_controller.dart';
import '../../../controllers/routine_controller.dart';
import '../notifications/notifications_screen.dart';

class InfantProfileScreen extends StatelessWidget {
  const InfantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InfantProfileController>();
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ─────────────────────────────────────────
            _buildTopBar(),
            // ─── Scrollable Content ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: c.profileFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.02),
                      _buildHeartIcon(),
                      const SizedBox(height: 16),
                      _buildWelcomeTitle(),
                      const SizedBox(height: 8),
                      _buildWelcomeSubtitle(),
                      SizedBox(height: h * 0.03),
                      _buildPhotoSection(c),
                      SizedBox(height: h * 0.03),
                      _buildNameField(c),
                      const SizedBox(height: 20),
                      _buildDateField(c, context),
                      const SizedBox(height: 20),
                      _buildGenderSelector(c),
                      const SizedBox(height: 20),
                      _buildWeightField(c),
                      const SizedBox(height: 16),
                      _buildInfoTip(),
                      const SizedBox(height: 28),
                      _buildSaveButton(c),
                      SizedBox(height: h * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    final routineCtrl = Get.isRegistered<RoutineController>() ? Get.find<RoutineController>() : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification bell
          GestureDetector(
            onTap: () => Get.to(() => NotificationsScreen()),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF636E72), size: 22),
                ),
                if (routineCtrl != null)
                  Obx(() {
                    final count = routineCtrl.vaccines.where((v) => !v.isDone).length;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(color: Color(0xFFE84118), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        // App Name + Avatar
        Row(
          children: [
            Text(
              'رعاية الطفل',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8DC5A2), Color(0xFF5DB075)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF5DB075).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Center(
                child: Icon(Icons.child_care_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HEART ICON
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeartIcon() => Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      color: const Color(0xFFE8847C).withOpacity(0.15),
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Icon(Icons.favorite_rounded, color: Color(0xFFE8847C), size: 30),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // WELCOME TITLE & SUBTITLE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWelcomeTitle() => Text(
    'مرحباً بك يا أمي',
    style: GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF2D3436),
    ),
  );

  Widget _buildWelcomeSubtitle() => Text(
    'دعينا نبدأ رحلة العناية بطفلك الجميل من خلال تسجيل بياناته\nالأساسية.',
    textAlign: TextAlign.center,
    style: GoogleFonts.cairo(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF636E72),
      height: 1.7,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // PHOTO SECTION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPhotoSection(InfantProfileController c) => Obx(() => GestureDetector(
    onTap: () => _showImagePickerOptions(c),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Photo circle
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8E8E8).withOpacity(0.5),
            border: Border.all(color: const Color(0xFFD5D5D5), width: 1.5),
            image: c.profileImagePath.value.isNotEmpty
                ? DecorationImage(
                    image: c.profileImagePath.value.startsWith('http')
                        ? NetworkImage(c.profileImagePath.value) as ImageProvider
                        : FileImage(File(c.profileImagePath.value)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: c.profileImagePath.value.isEmpty
              ? const Center(
                  child: Icon(Icons.add_a_photo_outlined, color: Color(0xFFB2BEC3), size: 36),
                )
              : null,
        ),
        // Edit badge
        Positioned(
          bottom: 4,
          right: 0,
          left: 60,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8DC5A2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8DC5A2).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: const Center(
              child: Icon(Icons.edit_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    ),
  ));

  void _showImagePickerOptions(InfantProfileController c) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختاري مصدر الصورة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: () {
                    c.pickImage(ImageSource.gallery);
                    Get.back();
                  },
                ),
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () {
                    c.pickImage(ImageSource.camera);
                    Get.back();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5DB075).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5DB075), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // NAME FIELD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildNameField(InfantProfileController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        'اسم طفلك',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3436),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: c.babyNameController,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
        decoration: InputDecoration(
          hintText: 'مثال: يوسف أو سارة',
          hintStyle: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFB2BEC3)),
          prefixIcon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFFB2BEC3), size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8DC5A2), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8847C)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال اسم الطفل' : null,
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════
  // DATE FIELD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildDateField(InfantProfileController c, BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        'تاريخ الميلاد',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3436),
        ),
      ),
      const SizedBox(height: 8),
      Obx(() => GestureDetector(
        onTap: () => c.pickDate(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFFB2BEC3), size: 20),
              const Spacer(),
              Text(
                c.formattedDate.isEmpty ? 'mm/dd/yyyy' : c.formattedDate,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: c.formattedDate.isEmpty ? const Color(0xFFB2BEC3) : const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.date_range_outlined, color: Color(0xFFB2BEC3), size: 20),
            ],
          ),
        ),
      )),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════
  // GENDER SELECTOR
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildGenderSelector(InfantProfileController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        'النوع',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3436),
        ),
      ),
      const SizedBox(height: 8),
      Obx(() => Row(
        children: [
          // Male
          Expanded(
            child: GestureDetector(
              onTap: () => c.setGender('ذكر'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: c.selectedGender.value == 'ذكر'
                      ? const Color(0xFF5DB075).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: c.selectedGender.value == 'ذكر'
                        ? const Color(0xFF5DB075)
                        : const Color(0xFFE8E8E8),
                    width: c.selectedGender.value == 'ذكر' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.face_6_rounded,
                      size: 20,
                      color: c.selectedGender.value == 'ذكر'
                          ? const Color(0xFF5DB075)
                          : const Color(0xFFB2BEC3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ذكر',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.selectedGender.value == 'ذكر'
                            ? const Color(0xFF5DB075)
                            : const Color(0xFF636E72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Female
          Expanded(
            child: GestureDetector(
              onTap: () => c.setGender('أنثى'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: c.selectedGender.value == 'أنثى'
                      ? const Color(0xFFE8847C).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: c.selectedGender.value == 'أنثى'
                        ? const Color(0xFFE8847C)
                        : const Color(0xFFE8E8E8),
                    width: c.selectedGender.value == 'أنثى' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.face_3_rounded,
                      size: 20,
                      color: c.selectedGender.value == 'أنثى'
                          ? const Color(0xFFE8847C)
                          : const Color(0xFFB2BEC3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'أنثى',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.selectedGender.value == 'أنثى'
                            ? const Color(0xFFE8847C)
                            : const Color(0xFF636E72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════
  // WEIGHT FIELD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWeightField(InfantProfileController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        'الوزن عند الولادة (كجم)',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3436),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: c.birthWeightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
        style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
        decoration: InputDecoration(
          hintText: 'مثال: 3.5',
          hintStyle: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFB2BEC3)),
          prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Color(0xFFB2BEC3), size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8DC5A2), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8847C)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الوزن';
          final weight = double.tryParse(v.trim());
          if (weight == null || weight <= 0 || weight > 10) {
            return 'الرجاء إدخال وزن صحيح (بين 0.5 و 10 كجم)';
          }
          return null;
        },
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════
  // INFO TIP BOX
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildInfoTip() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF5DB075), Color(0xFF4A9A63)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF5DB075).withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'هل تعلمين؟ تسجيل الوزن بدقة يساعدنا على',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                'متابعة نمو طفلك بشكل صحي وتقديم أفضل النصائح لكِ.',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // SAVE BUTTON
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSaveButton(InfantProfileController c) => Obx(() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: c.isLoading.value ? null : c.saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3D6B4F),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: const Color(0xFF3D6B4F).withOpacity(0.3),
      ),
      child: c.isLoading.value
          ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              'حفظ ومتابعة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
    ),
  ));
}
