import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/casting.dart';
import '../models/test.dart';
import '../services/jobs_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _viewMode = 'month';
  bool _isLoading = true;
  String? _error;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load jobs, castings, and tests
      final jobs = await JobsService.list();
      final castings = await Casting.list();
      final tests = await Test.list();

      final events = <DateTime, List<dynamic>>{};

      // Group events by date
      for (final job in jobs) {
        try {
          final date = DateTime.parse(job.date);
          final dateKey = DateTime(date.year, date.month, date.day);
          events[dateKey] = [...(events[dateKey] ?? []), job];
        } catch (e) {
          // Skip invalid dates
          continue;
        }
      }

      for (final casting in castings) {
        final date = DateTime(
          casting.date.year,
          casting.date.month,
          casting.date.day,
        );
        events[date] = [...(events[date] ?? []), casting];
      }

      for (final test in tests) {
        final date = DateTime(test.date.year, test.date.month, test.date.day);
        events[date] = [...(events[date] ?? []), test];
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getEventColor(dynamic event) {
    if (event is Job) return Colors.blue;
    if (event is Casting) return Colors.purple;
    if (event is Test) return Colors.orange;
    return Colors.grey;
  }

  String _getEventType(dynamic event) {
    if (event is Job) return 'Job';
    if (event is Casting) return 'Casting';
    if (event is Test) return 'Test';
    return 'Event';
  }

  void _showEventDetails(BuildContext context, dynamic event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          event.title ?? event.clientName ?? 'Event Details',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description != null) ...[
              const Text(
                'Description:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                event.description!,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Location:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              event.location ?? 'No location specified',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Date:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d, y').format(event.date),
              style: const TextStyle(color: Colors.white),
            ),
            if (event is Job && event.time != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Time:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                event.time!,
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (event.rate != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Rate:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.currency ?? 'USD'} ${event.rate!.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to edit page based on event type
              if (event is Job) {
                Navigator.pushNamed(context, '/new-job', arguments: event);
              } else if (event is Casting) {
                Navigator.pushNamed(context, '/new-casting', arguments: event);
              } else if (event is Test) {
                Navigator.pushNamed(context, '/new-test', arguments: event);
              }
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final color = _getEventColor(event);
    final type = _getEventType(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showEventDetails(context, event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    event is Job && event.time != null
                        ? event.time!
                        : 'All day',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title ?? event.clientName ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.location ?? 'No location',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(0),
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 3,
                    markerSize: 8,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              SizedBox(
                height:
                    constraints.maxHeight * 0.5, // Use half of available height
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    if (_selectedDay != null) ...[
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getEventsForDay(
                        _selectedDay!,
                      ).map((event) => _buildEventCard(event)).toList(),
                      if (_getEventsForDay(_selectedDay!).isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 32),
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No events for this day',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgendaView() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('This Week', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 7; i++) ...[
          _buildDayEvents(startOfWeek.add(Duration(days: i))),
          if (i < 6) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDayEvents(DateTime day) {
    final events = _getEventsForDay(day);
    final isToday = isSameDay(day, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                DateFormat('E, MMM d').format(day),
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (events.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...events.map((event) => _buildEventCard(event)),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No events',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/calendar',
      title: 'Calendar',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/add-event');
          },
          tooltip: 'Add Event',
        ),
        IconButton(
          icon: Icon(
            _viewMode == 'month' ? Icons.view_agenda : Icons.calendar_month,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _viewMode = _viewMode == 'month' ? 'agenda' : 'month';
            });
          },
          tooltip: 'Toggle View',
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : _viewMode == 'month'
                  ? _buildCalendarView()
                  : _buildAgendaView(),
    );
  }
}
