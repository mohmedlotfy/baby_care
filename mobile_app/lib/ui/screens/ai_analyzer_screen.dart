import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AiAnalyzerScreen extends StatelessWidget {
  const AiAnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل البكاء بالذكاء الاصطناعي'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.2),
              ),
              child: const Icon(Icons.mic, size: 80, color: AppTheme.accentColor),
            ),
            const SizedBox(height: 30),
            const Text(
              'استمع إلى بكاء طفلك',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'اضغطي على الزر أدناه لبدء التسجيل. سيقوم الذكاء الاصطناعي بتحليل الصوت لمعرفة ما إذا كان الطفل جائعاً، متعباً، أو يتألم.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // سيتم إضافة كود التسجيل هنا
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              child: const Text('بدء التسجيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
