import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/growth_record_model.dart';
import '../core/utils/growth_standards.dart';
import 'infant_profile_controller.dart';

class GrowthController extends GetxController {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final measurements = <GrowthRecordModel>[].obs;
  
  // Alert State
  final alertMessage = RxnString();
  final alertColor = const Color(0xFF5DB075).obs;
  final showAlert = false.obs;

  @override
  void onInit() {
    super.onInit();
    final infantProfile = Get.find<InfantProfileController>();
    
    // جلب البيانات فوراً إذا كان المعرف متوفراً
    if (infantProfile.infantId.value.isNotEmpty) {
      fetchMeasurements();
    }
    
    // الاستماع لأي تغيير في المعرف (عندما ينتهي التطبيق من تحميل الملف الشخصي)
    ever(infantProfile.infantId, (String id) {
      if (id.isNotEmpty) {
        fetchMeasurements();
      }
    });
  }

  @override
  void onClose() {
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  void _updateAlertStatus(double weight, int ageInMonths, String gender) {
    final standard = GrowthStandards.getWeightStandard(ageInMonths, gender);
    final minW = standard['min']!;
    final maxW = standard['max']!;

    if (weight < minW) {
      alertMessage.value = '⚠️ وزن الطفل ($weight كجم) أقل من المعدل الطبيعي ($minW كجم). يُنصح بمراجعة طبيب الأطفال.';
      alertColor.value = const Color(0xFFE8847C);
    } else if (weight > maxW) {
      alertMessage.value = '⚠️ وزن الطفل ($weight كجم) أعلى من المعدل الطبيعي ($maxW كجم). يُنصح بمراجعة طبيب الأطفال.';
      alertColor.value = const Color(0xFFE8A44C);
    } else {
      alertMessage.value = '✅ وزن الطفل طبيعي ومناسب لعمره. استمري بالتغذية السليمة!';
      alertColor.value = const Color(0xFF5DB075);
    }
    showAlert.value = true;
  }

  Future<void> fetchMeasurements() async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('growth_records')
          .orderBy('date', descending: true)
          .get();

      measurements.value = snapshot.docs
          .map((doc) => GrowthRecordModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Update alert based on the latest measurement
      if (measurements.isNotEmpty) {
        final latest = measurements.first;
        _updateAlertStatus(latest.weight, latest.ageInMonths, infantProfile.selectedGender.value);
      }
    } catch (e) {
      debugPrint('Error fetching measurements: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMeasurement() async {
    if (!formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    
    if (user == null || infantProfile.infantId.value.isEmpty) {
      Get.snackbar('خطأ', 'الرجاء تسجيل بيانات الطفل أولاً');
      return;
    }

    if (infantProfile.selectedDate.value == null) {
      Get.snackbar('خطأ', 'تاريخ ميلاد الطفل غير متوفر');
      return;
    }

    final weight = double.tryParse(weightController.text.trim()) ?? 0;
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final ageInMonths = _calculateAgeInMonths(infantProfile.selectedDate.value!);

    try {
      isLoading.value = true;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('growth_records')
          .doc();

      final record = GrowthRecordModel(
        id: docRef.id,
        userId: user.uid,
        infantId: infantProfile.infantId.value,
        weight: weight,
        height: height,
        ageInMonths: ageInMonths,
        date: DateTime.now(),
      );

      await docRef.set(record.toMap());

      weightController.clear();
      heightController.clear();

      await fetchMeasurements(); // Refresh list and update alert
      
      Get.snackbar(
        'نجاح',
        'تم إضافة القياس بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5DB075),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error adding measurement: $e');
      Get.snackbar('خطأ', 'فشل في إضافة القياس');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeasurement(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('growth_records')
          .doc(id)
          .delete();
          
      measurements.removeWhere((m) => m.id == id);
      
      if (measurements.isNotEmpty) {
        final latest = measurements.first;
        _updateAlertStatus(latest.weight, latest.ageInMonths, infantProfile.selectedGender.value);
      } else {
        showAlert.value = false;
      }
      
      Get.snackbar(
        'نجاح',
        'تم حذف القياس بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5DB075),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting measurement: $e');
      Get.snackbar('خطأ', 'فشل في الحذف');
    }
  }

  Future<void> updateMeasurement(String id, double newWeight, double newHeight) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('growth_records')
          .doc(id)
          .update({
        'weight': newWeight,
        'height': newHeight,
      });
      
      await fetchMeasurements();
      
      Get.snackbar(
        'نجاح',
        'تم تعديل القياس بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5DB075),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating measurement: $e');
      Get.snackbar('خطأ', 'فشل في التعديل');
    }
  }
}
