import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/navigation_controller.dart';
import 'home/home_dashboard_screen.dart';
import 'cry_analyzer_screen.dart';
import 'growth/growth_tracking_screen.dart';
import 'routine/routine_vaccines_screen.dart';
import 'profile/infant_profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();

    final List<Widget> pages = [
      const HomeDashboardScreen(),
      const CryAnalyzerScreen(),
      const GrowthTrackingScreen(),
      const RoutineVaccinesScreen(),
      const InfantProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Try going back to previous tab first
        if (navCtrl.goBack()) {
          return false;
        }
        
        // If no history but not on Home, go to Home
        if (navCtrl.currentIndex.value != 0) {
          navCtrl.currentIndex.value = 0;
          return false;
        }
        
        // If on Home and no history, show exit confirmation dialog
        final shouldExit = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('تأكيد الخروج', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
              content: Text('هل أنت متأكد أنك تريد الخروج من التطبيق؟', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 15)),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('بقاء', style: GoogleFonts.cairo(color: const Color(0xFF636E72))),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE84118), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('خروج', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        },
        child: Obx(() => Scaffold(
          body: IndexedStack(
            index: navCtrl.currentIndex.value,
            children: pages,
          ),
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              indicatorColor: const Color(0xFF5DB075).withOpacity(0.12),
              selectedIndex: navCtrl.currentIndex.value,
              onDestinationSelected: (index) {
                navCtrl.changeTab(index);
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                _buildNavItem(0, Icons.apps_rounded, 'الرئيسية', navCtrl),
                _buildNavItem(1, Icons.graphic_eq_rounded, 'المحلل', navCtrl),
                _buildNavItem(2, Icons.show_chart_rounded, 'النمو', navCtrl),
                _buildNavItem(3, Icons.calendar_month_rounded, 'الجدول', navCtrl),
                _buildNavItem(4, Icons.description_outlined, 'السجل', navCtrl),
              ],
            ),
          ),
        )),
    );
  }

  NavigationDestination _buildNavItem(int index, IconData icon, String label, NavigationController navCtrl) {
    final isSelected = navCtrl.currentIndex.value == index;
    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF5DB075) : const Color(0xFFB2BEC3),
      ),
      label: label,
    );
  }
}
