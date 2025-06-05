import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/test.dart';
import '../widgets/app_layout.dart';
import '../widgets/ui/badge.dart' as ui;
import '../widgets/ui/input.dart' as ui;
import '../widgets/ui/button.dart';
import '../widgets/ui/table.dart' as ui;

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  List<Test> tests = [];
  bool isLoading = true;
  String? error;
  String _searchTerm = '';
  String _viewMode = 'grid';
  String _selectedStatus = 'all';
  final Map<String, bool> _columnVisibility = {
    'date': true,
    'title': true,
    'description': true,
    'location': true,
    'status': true,
    'rate': true,
    'actions': true,
  };

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedTests = await Test.list();
      setState(() {
        tests = loadedTests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load tests: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF9C3); // yellow-100
      case 'confirmed':
        return const Color(0xFFDBEAFE); // blue-100
      case 'completed':
        return const Color(0xFFDCFCE7); // green-100
      case 'rejected':
        return const Color(0xFFFEE2E2); // red-100
      case 'canceled':
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
      case 'rejected':
        return const Color(0xFF991B1B); // red-800
      case 'canceled':
        return const Color(0xFF1F2937); // gray-800
      default:
        return const Color(0xFF1F2937); // gray-800
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Test test) async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Test',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${test.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      try {
        final success = await Test.delete(test.id);
        if (success) {
          await _loadTests();
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Test deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to delete test');
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting test: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Filter Tests',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Status:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                'all',
                'pending',
                'confirmed',
                'completed',
                'rejected',
                'canceled'
              ]
                  .map((status) => FilterChip(
                        label: Text(status.toUpperCase()),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : 'all';
                          });
                          Navigator.pop(context);
                          _loadTests();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(Test test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        test.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(test.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    test.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusTextColor(test.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(test.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (test.rate != null) ...[
                  const SizedBox(width: 24),
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${test.currency ?? 'USD'} ${test.rate!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    test.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Requirements', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              test.requirements,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (test.images != null && test.images!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Images', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: test.images!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        test.images![index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    Navigator.pushNamed(context, '/new-test');
                  },
                  text: 'Edit',
                ),
                const SizedBox(width: 8),
                Button(
                  variant: ButtonVariant.destructive,
                  onPressed: () => _showDeleteConfirmation(context, test),
                  text: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsTable() {
    return ui.Table(
      children: [
        ui.TableHead(
          children: [
            if (_columnVisibility['date']!)
              const ui.TableHeader(child: Text('Date')),
            if (_columnVisibility['title']!)
              const ui.TableHeader(child: Text('Title')),
            if (_columnVisibility['description']!)
              const ui.TableHeader(child: Text('Description')),
            if (_columnVisibility['location']!)
              const ui.TableHeader(child: Text('Location')),
            if (_columnVisibility['status']!)
              const ui.TableHeader(child: Text('Status')),
            if (_columnVisibility['rate']!)
              const ui.TableHeader(child: Text('Rate')),
            if (_columnVisibility['actions']!)
              const ui.TableHeader(child: Text('Actions')),
          ],
        ),
        ui.TableBody(
          children: tests.map((test) {
            return ui.TableRow(
              children: [
                if (_columnVisibility['date']!)
                  ui.TableCell(
                    child: Text(
                      DateFormat('MMM d, yyyy').format(test.date),
                    ),
                  ),
                if (_columnVisibility['title']!)
                  ui.TableCell(child: Text(test.title)),
                if (_columnVisibility['description']!)
                  ui.TableCell(
                    child: Text(
                      test.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_columnVisibility['location']!)
                  ui.TableCell(child: Text(test.location)),
                if (_columnVisibility['status']!)
                  ui.TableCell(
                    child: ui.Badge(
                      label: test.status,
                      backgroundColor: _getStatusColor(test.status),
                      textColor: _getStatusTextColor(test.status),
                      variant: ui.BadgeVariant.outline,
                    ),
                  ),
                if (_columnVisibility['rate']!)
                  ui.TableCell(
                    child: test.rate != null
                        ? Text(
                            '${test.currency ?? 'USD'} ${test.rate!.toStringAsFixed(2)}',
                          )
                        : const Text('-'),
                  ),
                if (_columnVisibility['actions']!)
                  ui.TableCell(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(context, '/new-test');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmation(context, test),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/tests',
      title: 'Tests',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-test'),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ui.Input(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search tests...',
                    value: _searchTerm,
                    onChanged: (value) => setState(() => _searchTerm = value),
                  ),
                ),
                const SizedBox(width: 16),
                Button(
                  text: 'Filter',
                  variant: ButtonVariant.outline,
                  prefix: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _viewMode == 'grid' ? Icons.view_list : Icons.grid_view,
                  ),
                  onPressed: () {
                    setState(() {
                      _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
                    });
                  },
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(child: Text(error!))
          else if (tests.isEmpty)
            const Center(child: Text('No tests found'))
          else if (_viewMode == 'grid')
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 900) crossAxisCount = 2;
                  if (constraints.maxWidth < 600) crossAxisCount = 1;

                  return GridView.builder(
                    padding: const EdgeInsets.all(0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2, // Adjusted for better content fit
                    ),
                    itemCount: tests.length,
                    itemBuilder: (context, index) =>
                        _buildTestCard(tests[index]),
                  );
                },
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTestsTable(),
              ),
            ),
        ],
      ),
    );
  }
}
