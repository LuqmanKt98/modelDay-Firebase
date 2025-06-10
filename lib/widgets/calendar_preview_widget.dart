import 'package:flutter/material.dart';
import 'package:new_flutter/theme/app_theme.dart';

class CalendarPreviewWidget extends StatelessWidget {
  const CalendarPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthName(currentMonth),
                style: const TextStyle(
                  fontSize: 18, // Increased font size
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                currentYear.toString(),
                style: TextStyle(
                  fontSize: 16, // Increased font size
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Increased spacing

          // Weekday headers
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallMobile = screenWidth < 360;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((day) => Flexible(
                          child: SizedBox(
                            width: isSmallMobile ? 16 : 20,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallMobile ? 9 : 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12), // Increased spacing

          // Calendar grid - scrollable for one month
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallMobile = screenWidth < 360;
              final calendarHeight = isSmallMobile ? 120.0 : 140.0;
              final dateWidth = isSmallMobile ? 50.0 : 60.0;
              final marginRight = isSmallMobile ? 6.0 : 8.0;

              return SizedBox(
                height: calendarHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      DateTime(currentYear, currentMonth + 1, 0)
                          .day, // Days in current month
                      (index) {
                        final dayNumber = index + 1;
                        final cellDate =
                            DateTime(currentYear, currentMonth, dayNumber);
                        final isToday = cellDate.day == now.day &&
                            cellDate.month == now.month &&
                            cellDate.year == now.year;
                        final isPast = cellDate
                            .isBefore(DateTime(now.year, now.month, now.day));

                        return Container(
                          width: dateWidth,
                          margin: EdgeInsets.only(right: marginRight),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.goldColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getWeekdayName(cellDate.weekday),
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 8 : 10,
                                  color: isToday
                                      ? Colors.black
                                      : Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              SizedBox(height: isSmallMobile ? 2 : 4),
                              Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 16 : 18,
                                  fontWeight: isToday
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isToday
                                      ? Colors.black
                                      : isPast
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : Colors.white,
                                ),
                              ),
                              SizedBox(height: isSmallMobile ? 2 : 4),
                              Text(
                                _getMonthAbbr(currentMonth),
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 8 : 10,
                                  color: isToday
                                      ? Colors.black
                                      : Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16), // Increased spacing

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppTheme.goldColor, 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
