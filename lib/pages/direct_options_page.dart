import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/direct_options.dart';
import 'package:new_flutter/services/direct_options_service.dart';

class DirectOptionsPage extends StatefulWidget {
  const DirectOptionsPage({super.key});

  @override
  State<DirectOptionsPage> createState() => _DirectOptionsPageState();
}

class _DirectOptionsPageState extends State<DirectOptionsPage> {
  List<DirectOptions> _options = [];
  List<DirectOptions> _filteredOptions = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortOrder = 'date-desc';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final options = await DirectOptionsService.list();
      if (!mounted) return;
      setState(() {
        _options = options;
        _filteredOptions = options;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading options: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredOptions = _options.where((option) {
        final searchLower = _searchQuery.toLowerCase();
        return option.clientName.toLowerCase().contains(searchLower) ||
            (option.optionType?.toLowerCase().contains(searchLower) ?? false) ||
            (option.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      // Apply sorting
      _filteredOptions.sort((a, b) {
        switch (_sortOrder) {
          case 'date-asc':
            return (a.date ?? DateTime(1900))
                .compareTo(b.date ?? DateTime(1900));
          case 'date-desc':
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
          case 'client-asc':
            return a.clientName.compareTo(b.clientName);
          case 'client-desc':
            return b.clientName.compareTo(a.clientName);
          default:
            return (b.date ?? DateTime(1900))
                .compareTo(a.date ?? DateTime(1900));
        }
      });
    });
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'EUR':
        return '€';
      case 'PLN':
        return 'zł';
      case 'ILS':
        return '₪';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'GBP':
        return '£';
      case 'USD':
      default:
        return '\$';
    }
  }

  double _calculateFinalAmount(DirectOptions option) {
    final baseAmount = option.rate ?? 0;
    final extraHours = double.tryParse(option.extraHours ?? '0') ?? 0;
    final additionalFees = double.tryParse(option.additionalFees ?? '0') ?? 0;
    final agencyFeePercentage =
        double.tryParse(option.agencyFeePercentage ?? '0') ?? 0;
    final taxPercentage = double.tryParse(option.taxPercentage ?? '0') ?? 0;

    final extraHoursAmount = extraHours * (baseAmount / 8);
    final totalBeforeDeductions =
        baseAmount + extraHoursAmount + additionalFees;
    final agencyFee = (totalBeforeDeductions * agencyFeePercentage) / 100;
    final taxAmount = (totalBeforeDeductions * taxPercentage) / 100;
    final finalAmount = totalBeforeDeductions - agencyFee - taxAmount;

    return finalAmount;
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredOptions.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search options...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (mounted) {
                setState(() => _sortOrder = value);
                _applyFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'date-desc', child: Text('Newest First')),
              const PopupMenuItem(
                  value: 'date-asc', child: Text('Oldest First')),
              const PopupMenuItem(
                  value: 'client-asc', child: Text('Client (A-Z)')),
              const PopupMenuItem(
                  value: 'client-desc', child: Text('Client (Z-A)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No direct options found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-direct-option'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Direct Option'),
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
          itemCount: _filteredOptions.length,
          itemBuilder: (context, index) =>
              _buildOptionCard(_filteredOptions[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) =>
          _buildOptionListItem(_filteredOptions[index]),
    );
  }

  Widget _buildOptionCard(DirectOptions option) {
    final finalAmount = _calculateFinalAmount(option);
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
                    option.clientName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(option.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              option.optionType ?? 'No Type',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (option.date != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(option.date!),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (option.location != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option.location!,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getCurrencySymbol(option.currency)}${finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                _buildPaymentStatusChip(option.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionListItem(DirectOptions option) {
    final finalAmount = _calculateFinalAmount(option);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(option.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.optionType ?? 'No Type'),
            if (option.date != null)
              Text(DateFormat('MMM d, yyyy').format(option.date!)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_getCurrencySymbol(option.currency)}${finalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildStatusChip(option.status),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          '/new-direct-option',
          arguments: option.id,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'option':
        color = Colors.blue;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaymentStatusChip(String? paymentStatus) {
    Color color;
    switch (paymentStatus) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        paymentStatus?.toUpperCase() ?? 'UNKNOWN',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/direct-options',
      title: 'Direct Options',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-direct-option'),
        ),
      ],
      child: _isLoading ? _buildLoadingWidget() : _buildContent(),
    );
  }
}
