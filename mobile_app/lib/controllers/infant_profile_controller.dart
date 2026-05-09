import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../core/models/infant_model.dart';

class InfantProfileController extends GetxController {
  // ─── Text Editing Controllers ────────────────────────────────────
  final babyNameController = TextEditingController();
  final birthWeightController = TextEditingController();

  // ─── Observable State ────────────────────────────────────────────
  final isLoading = false.obs;
  final selectedGender = 'أنثى'.obs; // Default: female
  final selectedDate = Rxn<DateTime>();
  final profileImagePath = ''.obs;
  final isSaved = false.obs;
  final infantId = ''.obs; // To be used by other controllers

  // ─── Form Key ────────────────────────────────────────────────────
  final profileFormKey = GlobalKey<FormState>();

  // ─── Date Display ────────────────────────────────────────────────
  String get formattedDate {
    if (selectedDate.value == null) return '';
    final d = selectedDate.value!;
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  // ─── Calculate age from birthdate ────────────────────────────────
  String get babyAge {
    if (selectedDate.value == null) return '';
    final now = DateTime.now();
    final birth = selectedDate.value!;
    int months = (now.year - birth.year) * 12 + (now.month - birth.month);
    if (now.day < birth.day) months--;
    if (months < 1) {
      final days = now.difference(birth).inDays;
      return '$days يوم';
    } else if (months < 12) {
      return '$months شهر';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) return '$years سنة';
      return '$years سنة و $remainingMonths شهر';
    }
  }

  // ─── Pick Image ──────────────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        profileImagePath.value = pickedFile.path;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ─── Set Gender ──────────────────────────────────────────────────
  void setGender(String gender) => selectedGender.value = gender;

  // ─── Pick Date ───────────────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'AE'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5DB075),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3436),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // ─── Save Profile ───────────────────────────────────────────────
  Future<void> saveProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    if (selectedDate.value == null) {
      Get.snackbar(
        'تنبيه',
        'الرجاء اختيار تاريخ الميلاد',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'خطأ',
          'يجب تسجيل الدخول أولاً للمتابعة.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }

      String? savedImagePath;

      // حفظ الصورة في Firebase Storage
      if (profileImagePath.value.isNotEmpty) {
        if (!profileImagePath.value.startsWith('http')) {
          try {
            final File imageFile = File(profileImagePath.value);
            final String fileName = 'infants/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
            
            final UploadTask uploadTask = storageRef.putFile(imageFile);
            final TaskSnapshot snapshot = await uploadTask;
            savedImagePath = await snapshot.ref.getDownloadURL();
            debugPrint('✅ Image uploaded: $savedImagePath');
          } catch (imgError) {
            debugPrint('❌ Image upload failed: $imgError');
            savedImagePath = null; // لا تحفظ المسار المحلي
            Get.snackbar(
              'تنبيه',
              'تم حفظ البيانات بنجاح لكن فشل رفع الصورة. تأكدي من تفعيل Firebase Storage.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade400,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
        } else {
          savedImagePath = profileImagePath.value; // Already a URL
        }
      }

      // تجهيز بيانات الطفل
      final infant = InfantModel(
        userId: user.uid,
        name: babyNameController.text.trim(),
        dateOfBirth: selectedDate.value!,
        gender: selectedGender.value == 'أنثى' ? 'female' : 'male',
        birthWeightKg: double.tryParse(birthWeightController.text.trim()) ?? 0.0,
        imageUrl: savedImagePath,
      );

      // حفظ في Firestore داخل Collection الـ users ثم infants
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc();

      Map<String, dynamic> infantData = infant.toMap();
      infantData['id'] = docRef.id;

      await docRef.set(infantData);

      isSaved.value = true;
      infantId.value = docRef.id;

      Get.snackbar(
        'نجاح',
        'تم حفظ بيانات الطفل بنجاح!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5DB075),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );

      // التوجيه إلى الشاشة الرئيسية
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error saving infant profile: $e');
      Get.snackbar(
        'خطأ - تفاصيل:',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Load existing profile if any ────────────────────────────────
  Future<void> loadExistingProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // جلب بيانات طفل المستخدم إذا كانت مسجلة مسبقاً
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        final infant = InfantModel.fromMap(data);

        babyNameController.text = infant.name;
        birthWeightController.text = infant.birthWeightKg.toString();
        selectedDate.value = infant.dateOfBirth;
        selectedGender.value = infant.gender == 'female' ? 'أنثى' : 'ذكر';

        if (infant.imageUrl != null && infant.imageUrl!.isNotEmpty) {
          profileImagePath.value = infant.imageUrl!;
        }

        isSaved.value = true;
        infantId.value = snapshot.docs.first.id;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // فشل صامت، غالباً المستخدم جديد وليس لديه بيانات مسجلة مسبقاً
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadExistingProfile();
  }

  // ─── Cleanup ─────────────────────────────────────────────────────
  @override
  void onClose() {
    babyNameController.dispose();
    birthWeightController.dispose();
    super.onClose();
  }
}
