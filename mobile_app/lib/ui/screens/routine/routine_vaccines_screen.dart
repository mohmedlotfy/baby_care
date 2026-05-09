import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/routine_controller.dart';
import '../../../controllers/infant_profile_controller.dart';
import '../../../core/models/routine_vaccine_model.dart';
import '../../../core/models/routine_feeding_model.dart';
import 'package:intl/intl.dart';

class RoutineVaccinesScreen extends StatefulWidget {
  const RoutineVaccinesScreen({super.key});

  @override
  State<RoutineVaccinesScreen> createState() => _RoutineVaccinesScreenState();
}

class _RoutineVaccinesScreenState extends State<RoutineVaccinesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RoutineController routineCtrl = Get.find<RoutineController>();
  final InfantProfileController profileCtrl = Get.find<InfantProfileController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _selectedFeedingType = 'طبيعي';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildVaccinesTab(),
                  _buildFeedingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'رعاية الطفل - التنظيم اليومي',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ],
    ),
  );

  Widget _buildTabBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: const Color(0xFF5DB075),
        borderRadius: BorderRadius.circular(14),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF636E72),
      labelStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.all(4),
      tabs: const [
        Tab(text: 'التطعيمات 💉'),
        Tab(text: 'الرضاعة 🍼'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // VACCINES TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildVaccinesTab() => Obx(() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildVaccineProgressCard(),
        const SizedBox(height: 20),
        _buildNextVaccineAlert(),
        const SizedBox(height: 20),
        Text(
          'جدول التطعيمات',
          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
        ),
        const SizedBox(height: 12),
        if (routineCtrl.vaccines.isEmpty) _buildEmptyVaccinesState(),
        ...routineCtrl.vaccines.map((v) => _buildVaccineCard(v)),
        const SizedBox(height: 16),
        _buildAddVaccineButton(),
        const SizedBox(height: 20),
      ],
    ),
  ));

  Widget _buildEmptyVaccinesState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      children: [
        const Icon(Icons.vaccines_rounded, color: Color(0xFFB2BEC3), size: 48),
        const SizedBox(height: 12),
        Text('لم يتم إضافة تطعيمات بعد', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))),
        const SizedBox(height: 4),
        Text('أضيفي تطعيمات طفلك لمتابعة الجدول', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
      ],
    ),
  );

  Widget _buildAddVaccineButton() => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: () => _showAddVaccineDialog(),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text('إضافة تطعيم', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5DB075),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  void _showAddVaccineDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay? selectedTime;
    
    String calculateAgeAtDate(DateTime vaccineDate) {
      if (profileCtrl.selectedDate.value == null) return '-';
      final birth = profileCtrl.selectedDate.value!;
      int months = (vaccineDate.year - birth.year) * 12 + (vaccineDate.month - birth.month);
      if (vaccineDate.day < birth.day) months--;
      if (months < 1) return '${vaccineDate.difference(birth).inDays} يوم';
      if (months < 12) return '$months شهر';
      return '${months ~/ 12} سنة';
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('إضافة تطعيم جديد', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFieldLabel('اسم التطعيم'),
                TextField(controller: nameCtrl, textAlign: TextAlign.right, decoration: _inputDecoration('مثل: تطعيم ٤ أشهر')),
                const SizedBox(height: 12),
                
                _buildFieldLabel('تاريخ التطعيم'),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      locale: const Locale('ar', 'AE'),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF5DB075), size: 20),
                        const Spacer(),
                        Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', style: GoogleFonts.cairo(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildFieldLabel('وقت التنبيه (اختياري)'),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Color(0xFF5DB075), size: 20),
                        const Spacer(),
                        Text(selectedTime == null ? 'لم يتم التحديد' : selectedTime!.format(context), style: GoogleFonts.cairo(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildFieldLabel('عمر الطفل عند التطعيم (تلقائي)'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: _boxDecoration(bgColor: const Color(0xFFF5F5F5)),
                  child: Text(calculateAgeAtDate(selectedDate), textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF636E72))),
                ),
                const SizedBox(height: 12),
                
                _buildFieldLabel('ملاحظات'),
                TextField(controller: descCtrl, textAlign: TextAlign.right, decoration: _inputDecoration('أي ملاحظات إضافية')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF636E72)))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  Get.snackbar(
                    'تنبيه',
                    'من فضلك أدخلي اسم التطعيم أولاً',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFFE8A44C),
                    colorText: Colors.white,
                    icon: const Icon(Icons.warning_rounded, color: Colors.white),
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                if (routineCtrl.isLoading.value) return;
                routineCtrl.addVaccine(
                  name: nameCtrl.text.trim(),
                  date: selectedDate,
                  time: selectedTime,
                  description: descCtrl.text.trim(),
                  ageAtVaccine: calculateAgeAtDate(selectedDate),
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('إضافة', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 4, right: 4),
    child: Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFFB2BEC3)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
  );

  BoxDecoration _boxDecoration({Color? bgColor}) => BoxDecoration(
    color: bgColor ?? Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE8E8E8)),
  );

  Widget _buildVaccineProgressCard() {
    final done = routineCtrl.vaccines.where((v) => v.isDone).length;
    final total = routineCtrl.vaccines.length;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5DB075), Color(0xFF4A9A63)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF5DB075).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done/$total', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('التطعيمات المكتملة', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('أحسنتِ! استمري 💪', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextVaccineAlert() {
    final next = routineCtrl.nextVaccine;
    if (next == null) return const SizedBox.shrink();

    final daysLeft = next.vaccineDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8A44C).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE8A44C), borderRadius: BorderRadius.circular(20)),
            child: Text(
              daysLeft <= 0 ? 'اليوم' : 'بعد $daysLeft يوم',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('⏰ التطعيم القادم', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436))),
              Text(next.name, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineCard(RoutineVaccineModel vaccine) {
    final dateStr = DateFormat('yyyy-MM-dd').format(vaccine.vaccineDate);
    final timeStr = DateFormat('hh:mm a').format(vaccine.vaccineDate);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => routineCtrl.deleteVaccine(vaccine.id!, vaccine.notificationId),
            child: const Icon(Icons.delete_rounded, color: Color(0xFFE84118), size: 22),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _showEditVaccineDialog(vaccine),
            child: const Icon(Icons.edit_rounded, color: Color(0xFF42A5F5), size: 22),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => routineCtrl.toggleVaccineStatus(vaccine.id!, vaccine.isDone),
            child: Icon(
              vaccine.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: vaccine.isDone ? const Color(0xFF5DB075) : const Color(0xFFB2BEC3),
              size: 24,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vaccine.name,
                  style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436),
                    decoration: vaccine.isDone ? TextDecoration.lineThrough : null,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  '${vaccine.description} • ${vaccine.ageAtVaccine} • $dateStr $timeStr',
                  style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF636E72)),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.vaccines_rounded, color: Color(0xFF5DB075), size: 24),
        ],
      ),
    );
  }

  void _showEditVaccineDialog(RoutineVaccineModel vaccine) {
    final nameCtrl = TextEditingController(text: vaccine.name);
    final descCtrl = TextEditingController(text: vaccine.description);
    DateTime selectedDate = vaccine.vaccineDate;
    TimeOfDay? selectedTime = TimeOfDay(hour: vaccine.vaccineDate.hour, minute: vaccine.vaccineDate.minute);

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل التطعيم', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFieldLabel('اسم التطعيم'),
                TextField(controller: nameCtrl, textAlign: TextAlign.right, decoration: _inputDecoration('اسم التطعيم')),
                const SizedBox(height: 12),

                _buildFieldLabel('تاريخ التطعيم'),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      locale: const Locale('ar', 'AE'),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF5DB075), size: 20),
                        const Spacer(),
                        Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', style: GoogleFonts.cairo(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildFieldLabel('وقت التنبيه'),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Color(0xFF5DB075), size: 20),
                        const Spacer(),
                        Text(selectedTime == null ? 'لم يتم التحديد' : selectedTime!.format(context), style: GoogleFonts.cairo(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildFieldLabel('ملاحظات'),
                TextField(controller: descCtrl, textAlign: TextAlign.right, decoration: _inputDecoration('أي ملاحظات إضافية')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF636E72)))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  Get.snackbar('تنبيه', 'أدخلي اسم التطعيم', snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8A44C), colorText: Colors.white);
                  return;
                }
                routineCtrl.editVaccine(
                  vaccineId: vaccine.id!,
                  name: nameCtrl.text.trim(),
                  date: selectedDate,
                  time: selectedTime,
                  description: descCtrl.text.trim(),
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('حفظ التعديل', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FEEDING TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFeedingTab() => Obx(() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFeedingSummary(),
        const SizedBox(height: 20),
        _buildFeedingTypeSelector(),
        const SizedBox(height: 20),
        _buildNextFeedingAlert(),
        const SizedBox(height: 20),
        Text(
          'سجل الرضاعة اليوم',
          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
        ),
        const SizedBox(height: 12),
        if (routineCtrl.feedingLog.isEmpty) _buildEmptyFeedingState(),
        ...routineCtrl.feedingLog.map((f) => _buildFeedingCard(f)),
        const SizedBox(height: 16),
        _buildAddFeedingButton(),
        const SizedBox(height: 20),
      ],
    ),
  ));

  Widget _buildEmptyFeedingState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      children: [
        const Icon(Icons.child_friendly_rounded, color: Color(0xFFB2BEC3), size: 48),
        const SizedBox(height: 12),
        Text('لم يتم تسجيل رضعات بعد', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))),
        const SizedBox(height: 4),
        Text('سجلي رضعات طفلك لمتابعة التغذية', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
      ],
    ),
  );

  Widget _buildFeedingSummary() {
    final today = DateTime.now();
    final total = routineCtrl.feedingLog.where((f) => 
      f.feedingTime.year == today.year && 
      f.feedingTime.month == today.month && 
      f.feedingTime.day == today.day
    ).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$total', style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ملخص اليوم', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('إجمالي عدد الرضعات المسجلة اليوم', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTypeSelector() => Row(
    children: [
      Expanded(child: _buildFeedingTypeBtn('صناعي', Icons.baby_changing_station, const Color(0xFF42A5F5))),
      const SizedBox(width: 12),
      Expanded(child: _buildFeedingTypeBtn('طبيعي', Icons.child_friendly_rounded, const Color(0xFF5DB075))),
    ],
  );

  Widget _buildFeedingTypeBtn(String type, IconData icon, Color color) => GestureDetector(
    onTap: () => setState(() => _selectedFeedingType = type),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _selectedFeedingType == type ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _selectedFeedingType == type ? color : const Color(0xFFE8E8E8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: _selectedFeedingType == type ? color : const Color(0xFFB2BEC3)),
          const SizedBox(width: 6),
          Text(type, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedFeedingType == type ? color : const Color(0xFF636E72))),
        ],
      ),
    ),
  );

  Widget _buildNextFeedingAlert() {
    final last = routineCtrl.lastFeeding;
    if (last == null) return const SizedBox.shrink();

    final diff = DateTime.now().difference(last.feedingTime);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF42A5F5), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'منذ $hours ساعة و $mins دقيقة',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('🍼 آخر رضعة', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436))),
              Text(last.type, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingCard(RoutineFeedingModel feeding) {
    final timeStr = DateFormat('hh:mm a').format(feeding.feedingTime);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF5DB075), size: 22),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text(feeding.amount, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('رضاعة ${feeding.type}', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(timeStr, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF636E72))),
            ],
          ),
          const SizedBox(width: 10),
          Icon(feeding.type == 'طبيعي' ? Icons.child_friendly_rounded : Icons.baby_changing_station, color: feeding.type == 'طبيعي' ? const Color(0xFF5DB075) : const Color(0xFF42A5F5), size: 22),
        ],
      ),
    );
  }

  Widget _buildAddFeedingButton() => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: () => _showAddFeedingDialog(),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text('تسجيل رضعة الآن', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    ),
  );

  void _showAddFeedingDialog() {
    final amountCtrl = TextEditingController();
    int selectedMinutes = 120; // Default remind after 2 hours

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تسجيل رضعة جديدة', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('النوع: $_selectedFeedingType', style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF636E72))),
              const SizedBox(height: 12),
              TextField(controller: amountCtrl, textAlign: TextAlign.right, decoration: _inputDecoration(_selectedFeedingType == 'طبيعي' ? 'المدة (مثل: ١٥ دقيقة)' : 'الكمية (مثل: ١٢٠ مل)')),
              const SizedBox(height: 16),
              _buildFieldLabel('تذكيري بالرضعة القادمة بعد:'),
              DropdownButton<int>(
                value: selectedMinutes,
                isExpanded: true,
                items: [0, 1, 60, 120, 180, 240, 300].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        value == 0 ? 'لا تقم بتذكيري' : 
                        value == 1 ? 'بعد دقيقة واحدة (للتجربة)' : 
                        'بعد ${value ~/ 60} ساعات'
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedMinutes = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF636E72)))),
            ElevatedButton(
              onPressed: () {
                if (amountCtrl.text.trim().isNotEmpty) {
                  routineCtrl.addFeeding(
                    type: _selectedFeedingType,
                    amount: amountCtrl.text.trim(),
                    remindAfterMinutes: selectedMinutes,
                  );
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DB075), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('تسجيل', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }
}
