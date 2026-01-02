import 'package:flutter/material.dart';
import 'members.dart';

/// A simple, self-contained monthly calendar screen.
///
/// - Use `CalendarScreen.routeName` for navigation if you want to register it
///   in the app routes.
class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';

  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _today = DateTime.now();

  // Map a Y-M-D string to the selected member name for that date.
  final Map<String, String> _assignments = {};

  String _keyForDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<String> get _weekdayLabels =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _monthLabel {
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
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    final startOffset = firstOfMonth.weekday - 1; // Monday-start week
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // Build a list of 42 entries (6 weeks) to display the calendar grid
    final cells = List<Widget>.generate(42, (index) {
      final dayNumber = index - startOffset + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return Container();
      }

      final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
      final isToday = date.year == _today.year &&
          date.month == _today.month &&
          date.day == _today.day;

      return AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              // Open members list and await the selected member name.
              final selected = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const MembersScreen()),
              );

              if (selected != null && selected.isNotEmpty) {
                setState(() {
                  _assignments[_keyForDate(date)] = selected;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Assigned "${selected}" to ${date.toLocal().toIso8601String().split('T').first}')),
                );
              }
            },
            child: Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: isToday
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    if (_assignments[_keyForDate(date)] != null) ...[
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          _assignments[_keyForDate(date)]!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous month',
                ),
                Text(
                  _monthLabel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next month',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday labels
            Row(
              children: _weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            Expanded(
              child: GridView.count(
                // Allow scrolling when content overflows and ensure the last
                // row is visible above the bottom navigation bar.
                padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 12),
                crossAxisCount: 7,
                childAspectRatio: 1,
                children: cells,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a date to see a placeholder action',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.restorablePushNamed(context, MembersScreen.routeName);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
        ],
      ),
    );
  }
}
