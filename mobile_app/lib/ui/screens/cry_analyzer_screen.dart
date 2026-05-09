import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CryAnalyzerScreen extends StatefulWidget {
  const CryAnalyzerScreen({super.key});

  @override
  State<CryAnalyzerScreen> createState() => _CryAnalyzerScreenState();
}

class _CryAnalyzerScreenState extends State<CryAnalyzerScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _resultTitle;
  String? _resultAdvice;
  String? _resultEmoji;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // AI ANALYSIS DATA
  // ═══════════════════════════════════════════════════════════════════
  final List<Map<String, String>> _analysisResults = [
    {
      'title': 'الطفل جائع',
      'emoji': '🍼',
      'advice':
          'حاولي إرضاع الطفل الآن. إذا كان يرضع صناعياً، حضري ١٢٠ مل من الحليب بدرجة حرارة ٣٧°. تأكدي من وضعية الرضاعة الصحيحة لتجنب المغص.',
    },
    {
      'title': 'الطفل يشعر بالألم',
      'emoji': '😢',
      'advice':
          'تحققي من درجة حرارة الطفل. جربي تدليك بطنه بحركات دائرية لطيفة. إذا استمر البكاء أكثر من ٣٠ دقيقة، استشيري الطبيب فوراً.',
    },
    {
      'title': 'يحتاج تغيير الحفاضة',
      'emoji': '🧷',
      'advice':
          'افحصي الحفاضة وغيريها. استخدمي كريم حماية لمنع الالتهابات. اتركي الجلد يجف قليلاً قبل وضع حفاضة جديدة.',
    },
    {
      'title': 'الطفل يريد النوم',
      'emoji': '😴',
      'advice':
          'هيئي بيئة هادئة ومظلمة. خفضي الأضواء والأصوات. جربي هز الطفل بلطف أو غني له. درجة حرارة الغرفة المثالية ٢٠-٢٢ درجة.',
    },
    {
      'title': 'مغص وغازات',
      'emoji': '💨',
      'advice':
          'ضعي الطفل على بطنه لبضع دقائق. دلكي بطنه بحركات دائرية مع عقارب الساعة. تأكدي من تجشئته بعد كل رضعة. إذا تكرر المغص، استشيري الطبيب.',
    },
  ];

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _resultTitle = null;
      _resultAdvice = null;
      _resultEmoji = null;
    });

    // Simulate recording (5 seconds)
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    // Simulate AI processing (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    final result = _analysisResults[Random().nextInt(_analysisResults.length)];

    setState(() {
      _isAnalyzing = false;
      _resultTitle = result['title'];
      _resultAdvice = result['advice'];
      _resultEmoji = result['emoji'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ─────────────────────────────────────
            _buildTopBar(),
            // ─── Content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeaderInfo(),
                    const SizedBox(height: 32),
                    _buildMicButton(),
                    const SizedBox(height: 24),
                    _buildStatusText(),
                    const SizedBox(height: 24),
                    if (_isAnalyzing) _buildAnalyzingIndicator(),
                    if (_resultTitle != null) _buildResultCard(),
                    const SizedBox(height: 20),
                    if (_resultTitle == null && !_isRecording && !_isAnalyzing)
                      _buildInstructions(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text(
          'رعاية الطفل - محلل الصراخ',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _buildHeaderInfo() => Column(
    children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF5DB075).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.graphic_eq_rounded, color: Color(0xFF5DB075), size: 32)),
      ),
      const SizedBox(height: 14),
      Text(
        'فهم احتياجات طفلك بالذكاء الاصطناعي',
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF636E72),
          height: 1.6,
        ),
      ),
    ],
  );

  Widget _buildMicButton() => GestureDetector(
    onTap: _isRecording || _isAnalyzing ? null : _startRecording,
    child: AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isRecording
                    ? [const Color(0xFFE8847C), const Color(0xFFD32F2F)]
                    : [const Color(0xFF8DC5A2), const Color(0xFF5DB075)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? const Color(0xFFE8847C) : const Color(0xFF5DB075)).withOpacity(0.35),
                  blurRadius: _isRecording ? 30 : 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildStatusText() {
    String text;
    Color color;
    if (_isRecording) {
      text = '🔴 جاري الاستماع لصوت الطفل...';
      color = const Color(0xFFE8847C);
    } else if (_isAnalyzing) {
      text = '🧠 الذكاء الاصطناعي يحلل الصوت...';
      color = const Color(0xFF42A5F5);
    } else if (_resultTitle != null) {
      text = 'تم التحليل بنجاح ✅';
      color = const Color(0xFF5DB075);
    } else {
      text = 'اضغط على الزر لبدء التسجيل';
      color = const Color(0xFF636E72);
    }
    return Text(
      text,
      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildAnalyzingIndicator() => Column(
    children: [
      const SizedBox(
        width: 40, height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(Color(0xFF5DB075)),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'يتم فحص جودة الصوت وتحليله...',
        style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF636E72)),
      ),
    ],
  );

  Widget _buildResultCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
      ],
    ),
    child: Column(
      children: [
        // Emoji & Title
        Text(_resultEmoji ?? '', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          _resultTitle ?? '',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60, height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF5DB075),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        // Medical Advice
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'نصيحة طبية',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5DB075),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.medical_information_rounded, color: Color(0xFF5DB075), size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _resultAdvice ?? '',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF2D3436),
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Try Again button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text('تحليل مرة أخرى', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5DB075),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildInstructions() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF5DB075), Color(0xFF4A9A63)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'كيف يعمل؟',
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.lightbulb_outline_rounded, color: Colors.white70, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        _buildStep('١', 'اضغط على زر الميكروفون لبدء التسجيل'),
        const SizedBox(height: 6),
        _buildStep('٢', 'قرّب الهاتف من الطفل لتسجيل صوت واضح'),
        const SizedBox(height: 6),
        _buildStep('٣', 'الذكاء الاصطناعي يحلل ويعطيك النتيجة فوراً'),
      ],
    ),
  );

  Widget _buildStep(String num, String text) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.9)),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(num, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ],
  );
}
