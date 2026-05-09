import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: ضع رابط الـ API الخاص بك هنا 
  // مثال: إذا كنت تستخدم OpenAI أو Gemini يمكنك وضع الرابط ومفتاح API هنا
  static const String _chatbotApiUrl = 'https://api.example.com/chat';
  
  static Future<String> sendMessageToAI(String message) async {
    try {
      /*
      // مثال على كود حقيقي للاتصال بـ API
      final response = await http.post(
        Uri.parse(_chatbotApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }
      */

      // محاكاة لرد الذكاء الاصطناعي لحين ربط الـ API الحقيقي الخاص بك
      await Future.delayed(const Duration(seconds: 1)); // محاكاة وقت الاتصال بالشبكة
      
      if (message.contains('حرارة') || message.contains('سخن')) {
        return 'إذا كانت حرارة الطفل مرتفعة، يرجى قياسها بدقة. إذا تخطت 38 درجة مئوية للرضع، يجب استشارة الطبيب فوراً. يمكنك استخدام كمادات فاترة كإجراء مؤقت لحين زيارة الطبيب.';
      } else if (message.contains('نوم')) {
        return 'يحتاج الرضع إلى 14-17 ساعة من النوم يومياً. تأكدي من تهيئة بيئة هادئة ومظلمة، وحاولي الحفاظ على روتين ثابت قبل النوم.';
      } else if (message.contains('رضاعة') || message.contains('حليب')) {
        return 'في الأشهر الأولى، يحتاج الطفل للرضاعة كل ساعتين إلى ثلاث ساعات. دعي طفلك يحدد متى يشبع ولاحظي علامات الجوع.';
      } else if (message.contains('سلام') || message.contains('اهلا')) {
        return 'أهلاً بكِ! أتمنى لكِ ولطفلك الصحة والعافية. كيف يمكنني المساعدة؟';
      } else {
        return 'أنا هنا لمساعدتك في كل ما يخص رعاية طفلك. للأسف لست متصلاً بخادم حقيقي الآن، ولكن عندما يقوم المطور بربط الـ API الخاص بي سأتمكن من الإجابة على أي سؤال! هل لديك سؤال عن الحرارة أو الرضاعة أو النوم؟';
      }
    } catch (e) {
      return 'عذراً، حدث خطأ في الاتصال. تأكد من الإنترنت وحاول مرة أخرى.';
    }
  }
}
