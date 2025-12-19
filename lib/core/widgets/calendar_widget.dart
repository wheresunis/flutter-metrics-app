import 'package:flutter/material.dart';
class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const CalendarWidget({super.key, this.onDateSelected});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getMonday(_selectedDate);
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    widget.onDateSelected?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> calendarDays = List.generate(7, (index) {
      DateTime day = _currentWeekStart.add(Duration(days: index));
      
      List<String> dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      
      return {
        'dateTime': day,
        'day': dayNames[index],
        'date': day.day,
        'isToday': _isSameDay(day, DateTime.now()),
        'isSelected': _isSameDay(day, _selectedDate),
        'isWeekend': index >= 4,
      };
    });

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: calendarDays.map((dayInfo) {
              return GestureDetector(
                onTap: () => _selectDate(dayInfo['dateTime']),
                child: _buildDaySquare(
                  day: dayInfo['day'],
                  date: dayInfo['date'].toString(),
                  isToday: dayInfo['isToday'],
                  isSelected: dayInfo['isSelected'],
                  isWeekend: dayInfo['isWeekend'],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySquare({
    required String day,
    required String date,
    bool isToday = false,
    bool isSelected = false,
    bool isWeekend = false,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isSelected) {
      // Вибраний день
      backgroundColor = const Color(0xFFDFFBA7);
      borderColor = const Color(0xFFDFFBA7);
      textColor = const Color.fromARGB(255, 0, 0, 0);
    } else if (isToday) {
      // Сьогоднішній день
      backgroundColor = const Color(0x60DFFBA7);
      borderColor = const Color(0xFFDFFBA7);
      textColor = Colors.white;
    } else if (isWeekend) {
      // Вихідні
      backgroundColor = Colors.transparent;
      borderColor = Colors.white;
      textColor = Colors.white;
    } else {
      // Будні
      backgroundColor = const Color(0x30797979);
      borderColor = const Color.fromARGB(0, 158, 158, 158);
      textColor = Colors.white;
    }

    return Container(
      width: 47,
      height: 62,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 2),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}