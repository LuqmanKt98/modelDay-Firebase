import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/button.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  String _connectionStatus = 'Not tested';
  String _userStatus = 'Not checked';
  String _databaseStatus = 'Not tested';
  List<Map<String, dynamic>> _testData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Test connection
      setState(() {
        _connectionStatus = 'Connected to Supabase';
      });

      // Test user authentication
      final user = supabase.auth.currentUser;
      setState(() {
        _userStatus = user != null
            ? 'Authenticated as: ${user.email}'
            : 'Not authenticated';
      });

      // Test database access
      await _testDatabase();
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDatabase() async {
    try {
      final supabase = Supabase.instance.client;

      // Try to fetch some data from the Job table
      final response = await supabase
          .from('Job')
          .select('id, client_name, type, date')
          .limit(5);

      setState(() {
        _databaseStatus = 'Database access successful';
        _testData = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _databaseStatus = 'Database access failed: $e';
        _testData = [];
      });
    }
  }

  Future<void> _createTestJob() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final testJob = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'client_name': 'Test Client ${DateTime.now().millisecondsSinceEpoch}',
        'type': 'Test Job',
        'location': 'Test Location',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'time': '10:00',
        'rate': 1000.0,
        'currency': 'USD',
        'created_by': user.id,
        'created_date': DateTime.now().toIso8601String(),
      };

      await supabase.from('Job').insert(testJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test job created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh the test data
      await _testDatabase();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create test job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: 'SupabaseTest',
      title: 'Supabase Test',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase Connection Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Connection Status
            _buildStatusCard('Connection Status', _connectionStatus),
            const SizedBox(height: 16),

            // User Status
            _buildStatusCard('User Status', _userStatus),
            const SizedBox(height: 16),

            // Database Status
            _buildStatusCard('Database Status', _databaseStatus),
            const SizedBox(height: 24),

            // Test Actions
            Row(
              children: [
                Button(
                  onPressed: _isLoading ? null : _testConnection,
                  text: _isLoading ? 'Testing...' : 'Refresh Test',
                ),
                const SizedBox(width: 16),
                Button(
                  onPressed: _createTestJob,
                  text: 'Create Test Job',
                  variant: ButtonVariant.outline,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Test Data
            if (_testData.isNotEmpty) ...[
              const Text(
                'Sample Data from Job Table:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _testData.map((job) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${job['client_name']} - ${job['type']} (${job['date']})',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Environment Info
            const Text(
              'Environment Information:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supabase URL: Connected',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Auth Status: ${Supabase.instance.client.auth.currentUser != null ? "Authenticated" : "Not authenticated"}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    Color statusColor = Colors.grey;
    if (status.contains('successful') ||
        status.contains('Connected') ||
        status.contains('Authenticated')) {
      statusColor = Colors.green;
    } else if (status.contains('failed') || status.contains('error')) {
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
