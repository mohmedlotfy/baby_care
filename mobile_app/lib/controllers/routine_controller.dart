import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/routine_vaccine_model.dart';
import '../core/models/routine_feeding_model.dart';
import '../services/notification_service.dart';
import 'infant_profile_controller.dart';
import 'package:intl/intl.dart';

class RoutineController extends GetxController {
  final vaccines = <RoutineVaccineModel>[].obs;
  final feedingLog = <RoutineFeedingModel>[].obs;
  final isLoading = false.obs;

  RoutineVaccineModel? get nextVaccine {
    return vaccines.firstWhereOrNull((v) => !v.isDone);
  }

  RoutineFeedingModel? get lastFeeding {
    return feedingLog.isNotEmpty ? feedingLog.first : null;
  }

  @override
  void onInit() {
    super.onInit();
    final infantProfile = Get.find<InfantProfileController>();
    
    if (infantProfile.infantId.value.isNotEmpty) {
      fetchAllData();
    }
    
    ever(infantProfile.infantId, (String id) {
      if (id.isNotEmpty) fetchAllData();
    });
  }

  Future<void> fetchAllData() async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      isLoading.value = true;
      
      // Fetch Vaccines
      final vaccinesSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('vaccines')
          .orderBy('vaccine_date', descending: false)
          .get();
          
      vaccines.value = vaccinesSnap.docs
          .map((doc) => RoutineVaccineModel.fromMap(doc.data(), doc.id))
          .toList();

      // Fetch Feedings
      final feedingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('feedings')
          .orderBy('feeding_time', descending: true)
          .get();
          
      feedingLog.value = feedingSnap.docs
          .map((doc) => RoutineFeedingModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      debugPrint('Error fetching routine data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addVaccine({
    required String name,
    required DateTime date,
    required TimeOfDay? time,
    required String description,
    required String ageAtVaccine,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    
    if (user == null) {
      Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
      return;
    }
    if (infantProfile.infantId.value.isEmpty) {
      Get.snackbar('خطأ', 'لم يتم تحديد بيانات الطفل بعد. اذهب لصفحة السجل وأدخل بيانات طفلك', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade400, colorText: Colors.white);
      debugPrint('infantId is empty! Cannot add vaccine.');
      return;
    }

    try {
      isLoading.value = true;
      
      // Calculate exactly when to notify
      DateTime notificationTime = DateTime(date.year, date.month, date.day, time?.hour ?? 9, time?.minute ?? 0);
      
      int notificationId = Random().nextInt(100000);

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('vaccines')
          .doc();

      final vaccine = RoutineVaccineModel(
        id: docRef.id,
        userId: user.uid,
        infantId: infantProfile.infantId.value,
        name: name,
        description: description,
        vaccineDate: notificationTime,
        ageAtVaccine: ageAtVaccine,
        isDone: false,
        notificationId: notificationId,
      );

      await docRef.set(vaccine.toMap());

      // Schedule notification (best-effort, don't fail the whole operation)
      try {
        if (notificationTime.isAfter(DateTime.now())) {
          await NotificationService().scheduleNotification(
            id: notificationId,
            title: 'تذكير بموعد تطعيم 💉',
            body: 'موعد تطعيم طفلك ($name) قد حان.',
            scheduledDate: notificationTime,
          );
        }
      } catch (notifError) {
        debugPrint('Notification scheduling failed (non-critical): $notifError');
      }

      await fetchAllData();
      Get.snackbar('نجاح', 'تم إضافة التطعيم وجدولة التنبيه بنجاح ✅', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF5DB075), colorText: Colors.white);
    } catch (e) {
      debugPrint('addVaccine error: $e');
      Get.snackbar('خطأ', 'فشل: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editVaccine({
    required String vaccineId,
    required String name,
    required DateTime date,
    required TimeOfDay? time,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      isLoading.value = true;
      DateTime updatedTime = DateTime(date.year, date.month, date.day, time?.hour ?? 9, time?.minute ?? 0);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('vaccines')
          .doc(vaccineId)
          .update({
        'name': name,
        'description': description,
        'vaccine_date': Timestamp.fromDate(updatedTime),
      });

      await fetchAllData();
      Get.snackbar('نجاح', 'تم تعديل التطعيم بنجاح ✅', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF5DB075), colorText: Colors.white);
    } catch (e) {
      debugPrint('editVaccine error: $e');
      Get.snackbar('خطأ', 'فشل تعديل التطعيم', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFeeding({
    required String type,
    required String amount,
    required int remindAfterMinutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();

    if (user == null) {
      Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white);
      return;
    }
    if (infantProfile.infantId.value.isEmpty) {
      Get.snackbar('خطأ', 'لم يتم تحديد بيانات الطفل. اذهب لصفحة السجل وأدخل بيانات طفلك أولاً', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade400, colorText: Colors.white);
      debugPrint('infantId is empty! Cannot add feeding.');
      return;
    }

    try {
      isLoading.value = true;
      final now = DateTime.now();

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('feedings')
          .doc();

      final feeding = RoutineFeedingModel(
        id: docRef.id,
        userId: user.uid,
        infantId: infantProfile.infantId.value,
        type: type,
        amount: amount,
        feedingTime: now,
      );

      await docRef.set(feeding.toMap());

      // Schedule next feeding notification (best-effort)
      try {
        if (remindAfterMinutes > 0) {
          final nextFeedingTime = now.add(Duration(minutes: remindAfterMinutes));
          final timeStr = remindAfterMinutes == 1 ? 'دقيقة واحدة' : (remindAfterMinutes >= 60 ? '${remindAfterMinutes ~/ 60} ساعات' : '$remindAfterMinutes دقيقة');
          await NotificationService().scheduleNotification(
            id: Random().nextInt(100000),
            title: 'وقت الرضاعة 🍼',
            body: 'لقد مرت $timeStr منذ آخر رضعة. حان وقت الرضاعة الآن.',
            scheduledDate: nextFeedingTime,
          );
        }
      } catch (notifError) {
        debugPrint('Notification scheduling failed (non-critical): $notifError');
      }

      await fetchAllData();
      Get.snackbar('نجاح', 'تم تسجيل الرضعة بنجاح', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF5DB075), colorText: Colors.white);
    } catch (e) {
      debugPrint('addFeeding error: $e');
      Get.snackbar('خطأ', 'فشل: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade400, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleVaccineStatus(String id, bool currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('vaccines')
          .doc(id)
          .update({'is_done': !currentStatus});
      
      // If marked as done, cancel the notification
      if (!currentStatus) {
        final vaccine = vaccines.firstWhereOrNull((v) => v.id == id);
        if (vaccine != null) {
          await NotificationService().cancelNotification(vaccine.notificationId);
        }
      }

      await fetchAllData();
    } catch (e) {
      debugPrint('Error toggling vaccine status: $e');
    }
  }

  Future<void> deleteVaccine(String id, int notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    final infantProfile = Get.find<InfantProfileController>();
    if (user == null || infantProfile.infantId.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('infants')
          .doc(infantProfile.infantId.value)
          .collection('vaccines')
          .doc(id)
          .delete();
          
      await NotificationService().cancelNotification(notificationId);
      await fetchAllData();
    } catch (e) {
      debugPrint('Error deleting vaccine: $e');
    }
  }
}
