import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/ai_job.dart';
import 'package:new_flutter/services/ai_jobs_service.dart';

class AiJobsPage extends StatefulWidget {
  const AiJobsPage({super.key});

  @override
  State<AiJobsPage> createState() => _AiJobsPageState();
}

class _AiJobsPageState extends State<AiJobsPage> {
  List<AiJob> _aiJobs = [];
  List<AiJob> _filteredAIJobs = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAIJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAIJobs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final aiJobs = await AiJobsService.list();
      if (!mounted) return;
      setState(() {
        _aiJobs = aiJobs;
        _filteredAIJobs = aiJobs;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading AI jobs: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredAIJobs = _aiJobs.where((aiJob) {
        final searchLower = _searchQuery.toLowerCase();
        return aiJob.clientName.toLowerCase().contains(searchLower) ||
            (aiJob.type?.toLowerCase().contains(searchLower) ?? false) ||
            (aiJob.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      _filteredAIJobs.sort((a, b) {
        final dateA = a.date ?? DateTime(1900);
        final dateB = b.date ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
    });
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No Date';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search AI jobs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _filteredAIJobs.isEmpty
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
          const Icon(Icons.smart_toy, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No AI jobs found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-ai-job'),
            icon: const Icon(Icons.add),
            label: const Text('Add New AI Job'),
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
          itemCount: _filteredAIJobs.length,
          itemBuilder: (context, index) => _buildAIJobCard(_filteredAIJobs[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAIJobs.length,
      itemBuilder: (context, index) =>
          _buildAIJobListItem(_filteredAIJobs[index]),
    );
  }

  Widget _buildAIJobCard(AiJob aiJob) {
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
                    aiJob.clientName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(aiJob.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(aiJob.type ?? 'No Type',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_formatDate(aiJob.date),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            if (aiJob.rate != null)
              Text('\$${aiJob.rate!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIJobListItem(AiJob aiJob) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(aiJob.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aiJob.type ?? 'No Type'),
            Text(_formatDate(aiJob.date)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (aiJob.rate != null)
              Text('\$${aiJob.rate!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(aiJob.status),
          ],
        ),
        onTap: () =>
            Navigator.pushNamed(context, '/new-ai-job', arguments: aiJob.id),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
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
      currentPage: '/ai-jobs',
      title: 'AI Jobs',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-ai-job'),
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
