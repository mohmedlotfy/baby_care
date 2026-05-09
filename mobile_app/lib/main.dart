import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'controllers/auth_controller.dart';
import 'controllers/infant_profile_controller.dart';
import 'controllers/routine_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/growth_controller.dart';
import 'services/notification_service.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/profile/infant_profile_screen.dart';
import 'ui/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notification Service
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Register global GetX controllers
  Get.put(AuthController());
  Get.put(InfantProfileController());
  Get.put(RoutineController());
  Get.put(NavigationController());
  Get.put(GrowthController());

  // Determine initial route based on auth state and profile existence
  final currentUser = FirebaseAuth.instance.currentUser;
  String initialRoute = '/login';
  
  if (currentUser != null) {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('infants')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        initialRoute = '/home';
      } else {
        initialRoute = '/infant-profile';
      }
    } catch (e) {
      initialRoute = '/home'; // fallback
    }
  }

  runApp(BabyCareApp(initialRoute: initialRoute));
}

class BabyCareApp extends StatelessWidget {
  final String initialRoute;
  const BabyCareApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'رعاية الطفل',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5DB075)),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      locale: const Locale('ar', 'AE'),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/infant-profile', page: () => const InfantProfileScreen()),
        GetPage(name: '/home', page: () => const MainNavigationScreen()),
      ],
    );
  }
}
