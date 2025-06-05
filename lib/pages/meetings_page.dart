import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/meeting.dart';
import 'package:new_flutter/services/meetings_service.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  List<Meeting> _meetings = [];
  List<Meeting> _filteredMeetings = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeetings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final meetings = await MeetingsService.list();
      if (!mounted) return;
      setState(() {
        _meetings = meetings;
        _filteredMeetings = meetings;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meetings: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredMeetings = _meetings.where((meeting) {
        final searchLower = _searchQuery.toLowerCase();
        return meeting.clientName.toLowerCase().contains(searchLower) ||
            (meeting.type?.toLowerCase().contains(searchLower) ?? false) ||
            (meeting.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      _filteredMeetings.sort((a, b) {
        try {
          final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
          final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search meetings...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _filteredMeetings.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No meetings found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-meeting'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Meeting'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) crossAxisCount = 2;
        if (constraints.maxWidth > 900) crossAxisCount = 3;
        if (constraints.maxWidth > 1200) crossAxisCount = 4;

        return GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredMeetings.length,
          itemBuilder: (context, index) =>
              _buildMeetingCard(_filteredMeetings[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredMeetings.length,
      itemBuilder: (context, index) =>
          _buildMeetingListItem(_filteredMeetings[index]),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meeting.clientName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(meeting.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(meeting.type ?? 'No Type',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_formatDate(meeting.date),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            if (meeting.rate != null && meeting.rate!.isNotEmpty)
              Text('\$${meeting.rate}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingListItem(Meeting meeting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(meeting.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meeting.type ?? 'No Type'),
            Text(_formatDate(meeting.date)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (meeting.rate != null && meeting.rate!.isNotEmpty)
              Text('\$${meeting.rate}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(meeting.status),
          ],
        ),
        onTap: () =>
            Navigator.pushNamed(context, '/new-meeting', arguments: meeting.id),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      case 'rescheduled':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status?.toUpperCase() ?? 'UNKNOWN',
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/meetings',
      title: 'Meetings',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-meeting'),
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
