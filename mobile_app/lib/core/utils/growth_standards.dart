class GrowthStandards {
  // المبني على بيانات منظمة الصحة العالمية (WHO) للأطفال من 0 إلى 24 شهراً
  
  // بيانات الذكور
  static final Map<int, Map<String, double>> boysWeight = {
    0: {'min': 2.5, 'avg': 3.3, 'max': 4.4},
    1: {'min': 3.4, 'avg': 4.5, 'max': 5.8},
    2: {'min': 4.3, 'avg': 5.6, 'max': 7.1},
    3: {'min': 5.0, 'avg': 6.4, 'max': 8.0},
    4: {'min': 5.6, 'avg': 7.0, 'max': 8.7},
    5: {'min': 6.0, 'avg': 7.5, 'max': 9.3},
    6: {'min': 6.4, 'avg': 7.9, 'max': 9.8},
    7: {'min': 6.7, 'avg': 8.3, 'max': 10.3},
    8: {'min': 6.9, 'avg': 8.6, 'max': 10.7},
    9: {'min': 7.1, 'avg': 8.9, 'max': 11.0},
    10: {'min': 7.4, 'avg': 9.2, 'max': 11.4},
    11: {'min': 7.6, 'avg': 9.4, 'max': 11.7},
    12: {'min': 7.7, 'avg': 9.6, 'max': 12.0},
    18: {'min': 8.8, 'avg': 10.9, 'max': 13.7},
    24: {'min': 9.7, 'avg': 12.2, 'max': 15.3},
  };

  static final Map<int, Map<String, double>> boysHeight = {
    0: {'min': 46.1, 'avg': 49.9, 'max': 53.7},
    1: {'min': 50.8, 'avg': 54.7, 'max': 58.6},
    2: {'min': 54.4, 'avg': 58.4, 'max': 62.4},
    3: {'min': 57.3, 'avg': 61.4, 'max': 65.5},
    4: {'min': 59.7, 'avg': 63.9, 'max': 68.0},
    5: {'min': 61.7, 'avg': 65.9, 'max': 70.1},
    6: {'min': 63.3, 'avg': 67.6, 'max': 71.9},
    12: {'min': 71.0, 'avg': 75.7, 'max': 80.5},
    18: {'min': 76.9, 'avg': 82.3, 'max': 87.7},
    24: {'min': 81.7, 'avg': 87.8, 'max': 93.9},
  };

  // بيانات الإناث
  static final Map<int, Map<String, double>> girlsWeight = {
    0: {'min': 2.4, 'avg': 3.2, 'max': 4.2},
    1: {'min': 3.2, 'avg': 4.2, 'max': 5.5},
    2: {'min': 3.9, 'avg': 5.1, 'max': 6.6},
    3: {'min': 4.5, 'avg': 5.8, 'max': 7.5},
    4: {'min': 5.0, 'avg': 6.4, 'max': 8.2},
    5: {'min': 5.4, 'avg': 6.9, 'max': 8.8},
    6: {'min': 5.7, 'avg': 7.3, 'max': 9.3},
    7: {'min': 6.0, 'avg': 7.6, 'max': 9.8},
    8: {'min': 6.3, 'avg': 7.9, 'max': 10.2},
    9: {'min': 6.5, 'avg': 8.2, 'max': 10.5},
    10: {'min': 6.7, 'avg': 8.5, 'max': 10.9},
    11: {'min': 6.9, 'avg': 8.7, 'max': 11.2},
    12: {'min': 7.0, 'avg': 8.9, 'max': 11.5},
    18: {'min': 8.1, 'avg': 10.2, 'max': 13.2},
    24: {'min': 9.0, 'avg': 11.5, 'max': 14.8},
  };

  static final Map<int, Map<String, double>> girlsHeight = {
    0: {'min': 45.4, 'avg': 49.1, 'max': 52.9},
    1: {'min': 49.8, 'avg': 53.7, 'max': 57.6},
    2: {'min': 53.0, 'avg': 57.1, 'max': 61.1},
    3: {'min': 55.6, 'avg': 59.8, 'max': 64.0},
    4: {'min': 57.8, 'avg': 62.1, 'max': 66.4},
    5: {'min': 59.6, 'avg': 64.0, 'max': 68.5},
    6: {'min': 61.2, 'avg': 65.7, 'max': 70.3},
    12: {'min': 68.9, 'avg': 74.0, 'max': 79.2},
    18: {'min': 74.9, 'avg': 80.7, 'max': 86.5},
    24: {'min': 80.0, 'avg': 86.4, 'max': 92.9},
  };

  // دالة لجلب البيانات بناءً على الشهر والجنس
  static Map<String, double> getWeightStandard(int month, String gender) {
    int key = _findClosestMonth(month, gender == 'ذكر' ? boysWeight : girlsWeight);
    return gender == 'ذكر' ? boysWeight[key]! : girlsWeight[key]!;
  }

  static Map<String, double> getHeightStandard(int month, String gender) {
    int key = _findClosestMonth(month, gender == 'ذكر' ? boysHeight : girlsHeight);
    return gender == 'ذكر' ? boysHeight[key]! : girlsHeight[key]!;
  }

  static int _findClosestMonth(int month, Map<int, dynamic> standards) {
    if (standards.containsKey(month)) return month;
    List<int> keys = standards.keys.toList()..sort();
    int closest = keys.first;
    for (int key in keys) {
      if (key <= month) closest = key;
    }
    return closest;
  }
}
