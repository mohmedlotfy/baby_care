import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/routine_controller.dart';
import '../../../controllers/infant_profile_controller.dart';
import '../../../services/notification_service.dart';

import '../../../controllers/navigation_controller.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  // Local state to track dismissed notifications in this session
  final RxList<String> hiddenIds = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    final routineCtrl = Get.find<RoutineController>();
    final profileCtrl = Get.find<InfantProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التنبيهات',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3436)),
          onPressed: () => Get.back(),
        ),
        actions: [],
      ),
      body: Obx(() {
        final upcomingVaccines = routineCtrl.vaccines.where((v) => !v.isDone && !hiddenIds.contains(v.id)).toList();
        final doneVaccines = routineCtrl.vaccines.where((v) => v.isDone && !hiddenIds.contains(v.id)).toList();
        final recentFeedings = routineCtrl.feedingLog.where((f) => !hiddenIds.contains(f.id)).take(5).toList();

        final hasNotifications = upcomingVaccines.isNotEmpty || recentFeedings.isNotEmpty;

        if (!hasNotifications) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Removed test banner
              const SizedBox(height: 8),

              // Upcoming vaccines
              if (upcomingVaccines.isNotEmpty) ...[
                _buildSectionTitle('💉 تطعيمات قادمة', upcomingVaccines.length),
                const SizedBox(height: 10),
                ...upcomingVaccines.map((v) {
                  final daysLeft = v.vaccineDate.difference(DateTime.now()).inDays;
                  return _buildNotificationCard(
                    id: v.id ?? '',
                    title: v.name,
                    subtitle: 'الموعد: ${DateFormat('yyyy-MM-dd hh:mm a').format(v.vaccineDate)}',
                    badge: daysLeft <= 0 ? 'اليوم!' : 'بعد $daysLeft يوم',
                    badgeColor: daysLeft <= 1 ? const Color(0xFFE84118) : const Color(0xFFE8A44C),
                    icon: Icons.vaccines_rounded,
                    iconColor: const Color(0xFF42A5F5),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // Done vaccines
              if (doneVaccines.isNotEmpty) ...[
                _buildSectionTitle('✅ تطعيمات مكتملة', doneVaccines.length),
                const SizedBox(height: 10),
                ...doneVaccines.map((v) => _buildNotificationCard(
                  id: v.id ?? '',
                  title: v.name,
                  subtitle: 'تم في: ${DateFormat('yyyy-MM-dd').format(v.vaccineDate)}',
                  badge: 'مكتمل',
                  badgeColor: const Color(0xFF5DB075),
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF5DB075),
                  isDone: true,
                )),
                const SizedBox(height: 20),
              ],

              // Recent feedings
              if (recentFeedings.isNotEmpty) ...[
                _buildSectionTitle('🍼 آخر الرضعات', recentFeedings.length),
                const SizedBox(height: 10),
                ...recentFeedings.map((f) => _buildNotificationCard(
                  id: f.id ?? '',
                  title: 'رضاعة ${f.type}',
                  subtitle: '${f.amount} • ${DateFormat('hh:mm a').format(f.feedingTime)}',
                  badge: _timeAgo(f.feedingTime),
                  badgeColor: const Color(0xFF42A5F5),
                  icon: Icons.child_friendly_rounded,
                  iconColor: f.type == 'طبيعي' ? const Color(0xFF5DB075) : const Color(0xFF42A5F5),
                )),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // Removed _buildTestBanner()

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_rounded, color: Color(0xFFB2BEC3), size: 64),
          const SizedBox(height: 20),
          Text('لا توجد تنبيهات', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436))),
          const SizedBox(height: 8),
          Text(
            'أضيفي تطعيمات ورضعات من صفحة "الجدول"\nوستظهر التنبيهات هنا تلقائياً',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF636E72)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await NotificationService().showNow(
                id: 99999,
                title: 'اختبار الإشعارات ✅',
                body: 'الإشعارات تعمل بنجاح!',
              );
              Get.snackbar('تم', 'تحقق من شريط الإشعارات', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF5DB075), colorText: Colors.white);
            },
            icon: const Icon(Icons.notifications_active_rounded, size: 18),
            label: Text('اختبار الإشعارات', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    ),
  );

  Widget _buildSectionTitle(String title, int count) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF5DB075).withAlpha(30), borderRadius: BorderRadius.circular(12)),
        child: Text('$count', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF5DB075))),
      ),
      Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436))),
    ],
  );

  Widget _buildNotificationCard({
    required String id,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    bool isDone = false,
  }) => GestureDetector(
    onTap: () {
      Get.back();
      // Tab 3 is Routine/Schedule tab
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changeTab(3);
      }
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFFB2BEC3), size: 18),
            onPressed: () => hiddenIds.add(id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const Spacer(),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: GoogleFonts.cairo(
                  fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436),
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ), textAlign: TextAlign.right),
                Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF636E72)), textAlign: TextAlign.right),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withAlpha(30), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    ),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
