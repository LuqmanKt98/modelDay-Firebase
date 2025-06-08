import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/casting.dart';
import '../models/test.dart';
import '../services/jobs_service.dart';
import '../widgets/app_layout.dart';

import '../widgets/ui/badge.dart' as ui;
import '../widgets/ui/card.dart' as ui;
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _activities = [];
  String _searchTerm = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _sortBy = 'date';
  final bool _ascending = false;

  final List<String> _types = [
    'all',
    'option',
    'job',
    'direct-option',
    'direct-booking',
    'casting',
    'on-stay',
    'test',
    'polaroids',
    'meeting',
    'ai-jobs',
    'other'
  ];
  final List<String> _statuses = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];
  final List<String> _sortOptions = ['date', 'type', 'status'];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final jobs = await JobsService.list();
      final castings = await Casting.list();
      final tests = await Test.list();

      final activities = <dynamic>[...jobs, ...castings, ...tests];
      activities.sort((a, b) {
        try {
          final aDateStr = a is Job
              ? a.date
              : a is Casting
                  ? a.date.toString()
                  : (a as Test).date.toString();
          final bDateStr = b is Job
              ? b.date
              : b is Casting
                  ? b.date.toString()
                  : (b as Test).date.toString();

          final aDate = DateTime.parse(aDateStr);
          final bDate = DateTime.parse(bDateStr);
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0; // If parsing fails, consider them equal
        }
      });

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load activities: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredActivities {
    return _activities.where((activity) {
      // Type filter
      if (_typeFilter != 'all') {
        if (_typeFilter == 'job' && activity is! Job) return false;
        if (_typeFilter == 'casting' && activity is! Casting) return false;
        if (_typeFilter == 'test' && activity is! Test) return false;
      }

      // Status filter
      if (_statusFilter != 'all') {
        final activityStatus = activity is Job ? 'pending' : activity.status;
        if (activityStatus != _statusFilter) {
          return false;
        }
      }

      // Search
      final searchLower = _searchTerm.toLowerCase();
      if (searchLower.isNotEmpty) {
        final title = activity is Job
            ? activity.clientName.toLowerCase()
            : (activity.title?.toLowerCase() ?? '');
        final description = activity is Job
            ? (activity.notes?.toLowerCase() ?? '')
            : (activity.description?.toLowerCase() ?? '');
        final location = activity.location?.toLowerCase() ?? '';
        return title.contains(searchLower) ||
            description.contains(searchLower) ||
            location.contains(searchLower);
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'date') {
          try {
            final aDateStr = a is Job ? a.date : a.date.toString();
            final bDateStr = b is Job ? b.date : b.date.toString();
            final aDate = DateTime.parse(aDateStr);
            final bDate = DateTime.parse(bDateStr);
            return _ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          } catch (e) {
            return 0;
          }
        } else if (_sortBy == 'type') {
          final aType = a is Job
              ? 'job'
              : a is Casting
                  ? 'casting'
                  : 'test';
          final bType = b is Job
              ? 'job'
              : b is Casting
                  ? 'casting'
                  : 'test';
          return _ascending ? aType.compareTo(bType) : bType.compareTo(aType);
        } else if (_sortBy == 'status') {
          final aStatus = a is Job ? 'pending' : a.status;
          final bStatus = b is Job ? 'pending' : b.status;
          return _ascending
              ? aStatus.compareTo(bStatus)
              : bStatus.compareTo(aStatus);
        }
        return 0;
      });
  }

  Color _getTypeColor(dynamic activity) {
    if (activity is Job) return Colors.blue;
    if (activity is Casting) return Colors.purple;
    if (activity is Test) return Colors.orange;
    return Colors.grey;
  }

  String _getTypeName(dynamic activity) {
    if (activity is Job) return 'Job';
    if (activity is Casting) return 'Casting';
    if (activity is Test) return 'Test';
    return 'Activity';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF9C3); // yellow-100
      case 'confirmed':
        return const Color(0xFFDBEAFE); // blue-100
      case 'completed':
        return const Color(0xFFDCFCE7); // green-100
      case 'cancelled':
        return const Color(0xFFF3F4F6); // gray-100
      default:
        return const Color(0xFFF3F4F6); // gray-100
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF854D0E); // yellow-800
      case 'confirmed':
        return const Color(0xFF1E40AF); // blue-800
      case 'completed':
        return const Color(0xFF166534); // green-800
      case 'cancelled':
        return const Color(0xFF1F2937); // gray-800
      default:
        return const Color(0xFF1F2937); // gray-800
    }
  }

  void _showActivityDetails(BuildContext context, dynamic activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          activity is Job
              ? activity.clientName
              : (activity.title ?? 'Activity Details'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((activity is Job && activity.notes != null) ||
                (activity is! Job && activity.description != null)) ...[
              const Text(
                'Description:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                activity is Job ? activity.notes! : activity.description!,
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
              activity.location ?? 'No location specified',
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
              () {
                try {
                  final dateStr = activity is Job
                      ? activity.date
                      : activity.date.toString();
                  final date = DateTime.parse(dateStr);
                  return DateFormat('EEEE, MMMM d, y').format(date);
                } catch (e) {
                  return activity is Job
                      ? activity.date
                      : activity.date.toString();
                }
              }(),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              (activity is Job ? 'PENDING' : activity.status.toUpperCase()),
              style: const TextStyle(color: Colors.white),
            ),
            if (activity.rate != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Rate:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}',
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
              // Navigate to edit page based on activity type
              if (activity is Job) {
                Navigator.pushNamed(context, '/new-job', arguments: activity);
              } else if (activity is Casting) {
                Navigator.pushNamed(context, '/new-casting',
                    arguments: activity);
              } else if (activity is Test) {
                Navigator.pushNamed(context, '/new-test', arguments: activity);
              }
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    final typeColor = _getTypeColor(activity);
    final typeName = _getTypeName(activity);
    final activityStatus = activity is Job ? 'pending' : activity.status;
    final statusColor = _getStatusColor(activityStatus);
    final statusTextColor = _getStatusTextColor(activityStatus);

    return ui.Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showActivityDetails(context, activity);
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
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      typeName,
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ui.Badge(
                    label: activityStatus,
                    backgroundColor: statusColor,
                    textColor: statusTextColor,
                  ),
                  const Spacer(),
                  Text(
                    () {
                      try {
                        final dateStr = activity is Job
                            ? activity.date
                            : activity.date.toString();
                        final date = DateTime.parse(dateStr);
                        return DateFormat('MMM d, y').format(date);
                      } catch (e) {
                        return activity is Job
                            ? activity.date
                            : activity.date.toString();
                      }
                    }(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activity is Job
                    ? activity.clientName
                    : (activity.title ?? 'Untitled'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activity.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
              if ((activity is Job && activity.notes != null) ||
                  (activity is! Job && activity.description != null)) ...[
                const SizedBox(height: 8),
                Text(
                  activity is Job ? activity.notes! : activity.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (activity.rate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.currency ?? 'USD'} ${activity.rate!.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _filteredActivities;

    return AppLayout(
      currentPage: '/activities',
      title: 'All Activities',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;
          final isMediumScreen = constraints.maxWidth < 1200;

          return Column(
            children: [
              // Header with title and add button
              _buildHeader(isSmallScreen),
              const SizedBox(height: 24),

              // Filters section
              _buildFilters(isSmallScreen, isMediumScreen),
              const SizedBox(height: 16),

              // Results count and clear filters
              _buildResultsHeader(filteredActivities.length, isSmallScreen),
              const SizedBox(height: 16),

              // Activities List or Table
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : filteredActivities.isEmpty
                            ? _buildEmptyState()
                            : isSmallScreen
                                ? _buildMobileList(filteredActivities)
                                : _buildDesktopTable(filteredActivities),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Activities',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage all your modeling activities in one place',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/add-event');
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(isSmallScreen ? 'Add' : 'Add Activity'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldColor,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool isSmallScreen, bool isMediumScreen) {
    return ui.Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: [
            // Search
            TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.goldColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.goldColor),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Filter Row - Responsive layout
            if (isSmallScreen)
              Column(
                children: [
                  _buildFilterDropdown('Activity Type', _typeFilter, _types,
                      (value) => setState(() => _typeFilter = value!)),
                  const SizedBox(height: 12),
                  _buildFilterDropdown('Status', _statusFilter, _statuses,
                      (value) => setState(() => _statusFilter = value!)),
                  const SizedBox(height: 12),
                  _buildFilterDropdown('Sort By', _sortBy, _sortOptions,
                      (value) => setState(() => _sortBy = value!)),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                      child: _buildFilterDropdown(
                          'Activity Type',
                          _typeFilter,
                          _types,
                          (value) => setState(() => _typeFilter = value!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildFilterDropdown(
                          'Status',
                          _statusFilter,
                          _statuses,
                          (value) => setState(() => _statusFilter = value!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildFilterDropdown(
                          'Sort By',
                          _sortBy,
                          _sortOptions,
                          (value) => setState(() => _sortBy = value!))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.goldColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.goldColor),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      dropdownColor: const Color(0xFF2A2A2A),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item == 'all' ? 'All ${label}s' : item.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultsHeader(int count, bool isSmallScreen) {
    return Row(
      children: [
        Text(
          '$count activities found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _searchTerm = '';
              _typeFilter = 'all';
              _statusFilter = 'all';
              _sortBy = 'date';
            });
          },
          icon: const Icon(Icons.clear, color: AppTheme.goldColor, size: 16),
          label: const Text(
            'Clear Filters',
            style: TextStyle(color: AppTheme.goldColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found matching your filters',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria or add a new activity',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<dynamic> activities) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildActivityCard(activities[index]),
    );
  }

  Widget _buildDesktopTable(List<dynamic> activities) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Client',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
                SizedBox(
                    width: 100,
                    child: Text('Actions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor))),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Color(0xFF2E2E2E), height: 1),
              itemBuilder: (context, index) =>
                  _buildTableRow(activities[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic activity) {
    final typeColor = _getTypeColor(activity);
    final typeName = _getTypeName(activity);
    final activityStatus = activity is Job ? 'pending' : activity.status;
    final statusColor = _getStatusColor(activityStatus);

    return InkWell(
      onTap: () => _showActivityDetails(context, activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity is Job
                        ? activity.clientName
                        : activity.clientName ?? 'Unknown Client',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.notes != null && activity.notes!.isNotEmpty)
                    Text(
                      activity.notes!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  typeName,
                  style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(activity is Job
                        ? activity.date
                        : activity.date.toString()),
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (activity.time != null)
                    Text(
                      activity.time!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                activity.location ?? 'TBD',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activityStatus.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: AppTheme.goldColor, size: 18),
                    onPressed: () {
                      // Navigate to edit page based on activity type
                      if (activity is Job) {
                        Navigator.pushNamed(context, '/new-job',
                            arguments: activity);
                      } else if (activity is Casting) {
                        Navigator.pushNamed(context, '/new-casting',
                            arguments: activity);
                      } else if (activity is Test) {
                        Navigator.pushNamed(context, '/new-test',
                            arguments: activity);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
