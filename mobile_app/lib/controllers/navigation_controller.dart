import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final List<int> _history = [];

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    
    // Push current index to history if it's different
    _history.add(currentIndex.value);
    // Keep history reasonably small
    if (_history.length > 10) _history.removeAt(0);
    
    currentIndex.value = index;
  }

  bool goBack() {
    if (_history.isNotEmpty) {
      currentIndex.value = _history.removeLast();
      return true;
    }
    return false;
  }
}
