import 'package:flutter/material.dart';

enum CalendarFormatType { day, week, month }

class CalendarFormatManager extends ChangeNotifier {
  CalendarFormatType _currentFormat = CalendarFormatType.month;

  CalendarFormatType get currentFormat => _currentFormat;

  void toggleFormat() {
    switch (_currentFormat) {
      case CalendarFormatType.day:
        _currentFormat = CalendarFormatType.week;
        break;
      case CalendarFormatType.week:
        _currentFormat = CalendarFormatType.month;
        break;
      case CalendarFormatType.month:
        _currentFormat = CalendarFormatType.day;
        break;
    }
    notifyListeners();
  }

  void setFormat(CalendarFormatType format) {
    _currentFormat = format;
    notifyListeners();
  }
}
