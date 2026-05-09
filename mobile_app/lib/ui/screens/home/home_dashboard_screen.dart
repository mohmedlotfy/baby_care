import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/infant_profile_controller.dart';
import '../../../controllers/routine_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../notifications/notifications_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<InfantProfileController>();
    final routineCtrl = Get.find<RoutineController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                _buildTopBar(profileCtrl),
                const SizedBox(height: 24),
                _buildBabyStatusCard(profileCtrl, routineCtrl),
                const SizedBox(height: 24),
                _buildActionGrid(context),
                const SizedBox(height: 28),
                _buildSectionTitle('تنبيهات هامة'),
                const SizedBox(height: 14),
                _buildAlertsSection(routineCtrl),
                const SizedBox(height: 28),
                _buildQuickTips(),
                const SizedBox(height: 100),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(InfantProfileController ctrl) {
    final routineCtrl = Get.find<RoutineController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => NotificationsScreen()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Icon(Icons.notifications_none_rounded, color: Color(0xFF636E72), size: 24)),
              ),
              // Red badge if upcoming vaccines exist
              if (routineCtrl.vaccines.any((v) => !v.isDone))
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: Color(0xFFE84118), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${routineCtrl.vaccines.where((v) => !v.isDone).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('مرحباً بك', style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF636E72))),
              Text('رعاية الطفل', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF5DB075))),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF8DC5A2), Color(0xFF5DB075)])),
            child: const Center(child: Icon(Icons.child_care_rounded, color: Colors.white, size: 28)),
          ),
        ],
      ),
      ],
    );
  }

  Widget _buildBabyStatusCard(InfantProfileController ctrl, RoutineController routine) {
    final hasName = ctrl.babyNameController.text.isNotEmpty;
    final lastMeal = routine.lastFeeding;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF5DB075).withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(hasName ? '👶' : '👋', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasName ? 'مرحباً، أنا ${ctrl.babyNameController.text}' : 'مرحباً بكِ في رعاية الطفل',
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  lastMeal != null 
                    ? 'آخر نشاط: رضاعة ${lastMeal.type} (الساعة ${lastMeal.feedingTime.hour}:${lastMeal.feedingTime.minute.toString().padLeft(2, '0')})'
                    : 'سجلي بيانات طفلك للبدء',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: _buildActionCard('تتبع النمو', Icons.show_chart_rounded, const Color(0xFF5DB075), const Color(0xFFE8F5ED), 2)),
          const SizedBox(width: 14),
          Expanded(child: _buildCryAnalyzerCard()),
        ],
      ),
      const SizedBox(height: 14),
      _buildRoutineCard(),
    ],
  );

  Widget _buildActionCard(String title, IconData icon, Color color, Color bgColor, int tabIndex) => GestureDetector(
    onTap: () => Get.find<NavigationController>().changeTab(tabIndex),
    child: Container(
      height: 110, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );

  Widget _buildCryAnalyzerCard() => GestureDetector(
    onTap: () => Get.find<NavigationController>().changeTab(1),
    child: Container(
      height: 110, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8DC5A2), Color(0xFF5DB075)]), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('محلل الصراخ', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('افهم احتياجات طفلك فوراً', style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withOpacity(0.85))),
          ]),
        ],
      ),
    ),
  );

  Widget _buildRoutineCard() => GestureDetector(
    onTap: () => Get.find<NavigationController>().changeTab(3),
    child: Container(
      width: double.infinity, height: 80, padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFE8A44C))),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('التنظيم اليومي', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
          Text('التطعيمات والرضاعة والنوم', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF636E72))),
        ]),
      ]),
    ),
  );

  Widget _buildSectionTitle(String title) => Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700));

  Widget _buildAlertsSection(RoutineController routine) {
    final nextVac = routine.nextVaccine;
    if (nextVac == null) return _buildEmptyAlertsCard();

    final daysLeft = nextVac.vaccineDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
            child: Text(daysLeft <= 0 ? 'اليوم' : 'بعد $daysLeft يوم', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFE8A44C))),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('التطعيم القادم', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(nextVac.name, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF42A5F5).withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(Icons.vaccines_rounded, color: Color(0xFF42A5F5))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAlertsCard() => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      const Icon(Icons.notifications_off_outlined, color: Color(0xFFB2BEC3), size: 40),
      const SizedBox(height: 12),
      Text('لا توجد تنبيهات حالياً', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
      Text('سجلي مواعيد الرضاعة والتطعيمات\nمن صفحة "الجدول" وسيتم تنبيهك تلقائياً', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
    ]),
  );

  Widget _buildQuickTips() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5DB075), Color(0xFF4A9A63)]), borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('نصائح سريعة', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(width: 8),
        const Icon(Icons.lightbulb_outline_rounded, color: Colors.white70, size: 22),
      ]),
      const SizedBox(height: 14),
      _buildTipItem('سجلي بيانات طفلك من صفحة "السجل"'),
      _buildTipItem('أضيفي مواعيد الرضاعة والتطعيمات من "الجدول"'),
      _buildTipItem('استخدمي "محلل الصراخ" لفهم احتياجات طفلك'),
    ]),
  );

  Widget _buildTipItem(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Flexible(child: Text(text, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.9)))),
      const SizedBox(width: 8),
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
    ]),
  );
}
