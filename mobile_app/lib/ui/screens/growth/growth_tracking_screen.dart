import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/growth_controller.dart';
import '../../../controllers/infant_profile_controller.dart';
import '../../../core/utils/growth_standards.dart';

class GrowthTrackingScreen extends StatelessWidget {
  const GrowthTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GrowthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    // Weight Chart
                    Obx(() => _buildChartSection(controller, 'منحنى الوزن (كجم)', true)),
                    const SizedBox(height: 20),
                    // Height Chart
                    Obx(() => _buildChartSection(controller, 'منحنى الطول (سم)', false)),
                    const SizedBox(height: 24),
                    // Alert
                    Obx(() => controller.showAlert.value ? _buildAlertCard(controller) : const SizedBox()),
                    Obx(() => controller.showAlert.value ? const SizedBox(height: 20) : const SizedBox()),
                    // Input Form
                    _buildInputSection(controller),
                    const SizedBox(height: 20),
                    // History
                    Obx(() => _buildHistorySection(controller, context)),
                    const SizedBox(height: 30),
                  ],
                ),
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
          'رعاية الطفل - متابعة النمو',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ],
    ),
  );

  Widget _buildHeaderCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF5DB075), Color(0xFF4A9A63)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: const Color(0xFF5DB075).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Icon(Icons.show_chart_rounded, color: Colors.white, size: 28)),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'متابعة نمو طفلك',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'سجلي القياسات وتابعي النمو بصرياً',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildChartSection(GrowthController controller, String title, bool isWeight) {
    final data = controller.measurements.reversed.toList();
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(
              isWeight ? Icons.monitor_weight_outlined : Icons.straighten_rounded,
              color: const Color(0xFFB2BEC3),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
            ),
            const SizedBox(height: 6),
            Text(
              'لم يتم إضافة قياسات بعد\nأضيفي أول قياس لطفلك من الأسفل',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF636E72), height: 1.6),
            ),
          ],
        ),
      );
    }

    final maxVal = data.map((d) => isWeight ? d.weight : d.height).reduce(max) * 1.2;
    
    final infantProfile = Get.find<InfantProfileController>();
    final gender = infantProfile.selectedGender.value;
    final latestAge = data.last.ageInMonths;
    final standards = isWeight 
        ? GrowthStandards.getWeightStandard(latestAge, gender)
        : GrowthStandards.getHeightStandard(latestAge, gender);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isWeight ? Icons.monitor_weight_outlined : Icons.straighten_rounded,
                color: const Color(0xFF5DB075),
                size: 20,
              ),
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((entry) {
                final val = isWeight ? entry.weight : entry.height;
                final heightFactor = maxVal > 0 ? (val / maxVal) : 0.5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isWeight ? val.toStringAsFixed(1) : val.toStringAsFixed(0),
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5DB075),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 80 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isWeight
                                  ? [const Color(0xFF8DC5A2).withOpacity(0.5), const Color(0xFF5DB075)]
                                  : [const Color(0xFF81D4FA).withOpacity(0.5), const Color(0xFF42A5F5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'شهر ${entry.ageInMonths}',
                          style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF636E72)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // WHO standard note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'المعدل الطبيعي: ${standards['min']} - ${standards['max']} ${isWeight ? 'كجم' : 'سم'} (لشهر $latestAge)',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF636E72)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(GrowthController controller) => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: controller.alertColor.value.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: controller.alertColor.value.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(
          controller.alertColor.value == const Color(0xFF5DB075) ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
          color: controller.alertColor.value,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            controller.alertMessage.value ?? '',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF2D3436), height: 1.5),
          ),
        ),
      ],
    ),
  );

  Widget _buildInputSection(GrowthController controller) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    child: Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'إضافة قياس جديد',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
                  decoration: _inputDeco('الطول (سم)', Icons.straighten_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'مطلوب';
                    final h = double.tryParse(v.trim());
                    if (h == null || h < 30 || h > 120) return 'قيمة غير صحيحة';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller.weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF2D3436)),
                  decoration: _inputDeco('الوزن (كجم)', Icons.monitor_weight_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'مطلوب';
                    final w = double.tryParse(v.trim());
                    if (w == null || w < 0.5 || w > 25) return 'قيمة غير صحيحة';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.addMeasurement,
              icon: controller.isLoading.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add_rounded, size: 20),
              label: Text(controller.isLoading.value ? 'جاري الحفظ...' : 'إضافة القياس', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5DB075),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
          ),
        ],
      ),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFFB2BEC3)),
    prefixIcon: Icon(icon, color: const Color(0xFFB2BEC3), size: 20),
    filled: true,
    fillColor: const Color(0xFFF7F5F2),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  Widget _buildHistorySection(GrowthController controller, BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'سجل القياسات',
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
        ),
        const SizedBox(height: 12),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('الإجراء', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5DB075)))),
              Expanded(flex: 1, child: Text('الطول', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5DB075)))),
              Expanded(flex: 1, child: Text('الوزن', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5DB075)))),
              Expanded(flex: 1, child: Text('الفترة', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5DB075)))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...controller.measurements.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFFE8E8E8).withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showEditDialog(context, controller, entry.id!, entry.weight, entry.height),
                        child: const Icon(Icons.edit_rounded, color: Color(0xFFE8A44C), size: 18),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, controller, entry.id!),
                        child: const Icon(Icons.delete_rounded, color: Color(0xFFE8847C), size: 18),
                      ),
                    ],
                  )
                ),
                Expanded(flex: 1, child: Text('${entry.height.toStringAsFixed(0)} سم', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF2D3436)))),
                Expanded(flex: 1, child: Text('${entry.weight.toStringAsFixed(1)} كجم', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF2D3436)))),
                Expanded(flex: 1, child: Text('شهر ${entry.ageInMonths}', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436)))),
              ],
            ),
          ),
        )),
      ],
    ),
  );

  void _confirmDelete(BuildContext context, GrowthController controller, String id) {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.right),
        content: Text('هل أنت متأكد من حذف هذا القياس؟', style: GoogleFonts.cairo(fontSize: 14), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMeasurement(id);
            },
            child: Text('حذف', style: GoogleFonts.cairo(color: const Color(0xFFE8847C))),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, GrowthController controller, String id, double currentWeight, double currentHeight) {
    final weightCtrl = TextEditingController(text: currentWeight.toString());
    final heightCtrl = TextEditingController(text: currentHeight.toString());
    
    Get.dialog(
      AlertDialog(
        title: Text('تعديل القياس', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'الوزن (كجم)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'الطول (سم)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newW = double.tryParse(weightCtrl.text) ?? currentWeight;
              final newH = double.tryParse(heightCtrl.text) ?? currentHeight;
              Get.back();
              controller.updateMeasurement(id, newW, newH);
            },
            child: Text('حفظ', style: GoogleFonts.cairo(color: const Color(0xFF5DB075))),
          ),
        ],
      ),
    );
  }
}
