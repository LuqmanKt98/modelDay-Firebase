import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/theme/app_theme.dart';

import 'package:new_flutter/services/direct_options_service.dart';
import 'package:intl/intl.dart';

class NewDirectOptionPage extends StatefulWidget {
  const NewDirectOptionPage({super.key});

  @override
  State<NewDirectOptionPage> createState() => _NewDirectOptionPageState();
}

class _NewDirectOptionPageState extends State<NewDirectOptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _agencyFeeController = TextEditingController();
  final _taxController = TextEditingController();
  final _additionalFeesController = TextEditingController();
  final _extraHoursController = TextEditingController();

  String _selectedOptionType = '';
  String _selectedStatus = 'option';
  String _selectedPaymentStatus = 'unpaid';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isCustomType = false;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingId;

  final List<String> _optionTypes = [
    'Add manually',
    'Commercial',
    'Editorial',
    'Fashion Show',
    'Lookbook',
    'Print',
    'Runway',
    'Social Media',
    'Web Content',
    'Other'
  ];

  final List<String> _statusOptions = ['option', 'confirmed', 'canceled'];

  final List<String> _paymentStatusOptions = ['unpaid', 'partial', 'paid'];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'PLN',
    'ILS',
    'JPY',
    'KRW',
    'CNY',
    'AUD'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is Map<String, dynamic>) {
          _loadInitialData(args);
        } else if (args is String) {
          _loadDirectOption(args);
        }
      }
    });
  }

  void _loadInitialData(Map<String, dynamic> data) {
    setState(() {
      _clientNameController.text = data['clientName'] ?? '';
      _selectedDate = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
      if (data['startTime'] != null && data['startTime'].isNotEmpty) {
        final timeParts = data['startTime'].split(':');
        _startTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
      if (data['endTime'] != null && data['endTime'].isNotEmpty) {
        final timeParts = data['endTime'].split(':');
        _endTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
      _locationController.text = data['location'] ?? '';
      _rateController.text = data['rate'] ?? '';
      _selectedCurrency = data['currency'] ?? 'USD';
      _notesController.text = data['notes'] ?? '';
      if (data['jobType'] != null && data['jobType'].isNotEmpty) {
        if (_optionTypes.contains(data['jobType'])) {
          _selectedOptionType = data['jobType'];
        } else {
          _selectedOptionType = 'Add manually';
          _isCustomType = true;
          _customTypeController.text = data['jobType'];
        }
      }
    });
  }

  Future<void> _loadDirectOption(String id) async {
    setState(() {
      _isLoading = true;
      _isEditing = true;
      _editingId = id;
    });

    try {
      final option = await DirectOptionsService.getById(id);
      if (option != null) {
        setState(() {
          _clientNameController.text = option.clientName;
          _selectedOptionType = option.optionType ?? '';
          _locationController.text = option.location ?? '';
          _rateController.text = option.rate?.toString() ?? '';
          _selectedDate = option.date ?? DateTime.now();
          _phoneController.text = option.phone ?? '';
          _emailController.text = option.email ?? '';
          _notesController.text = option.notes ?? '';
          _selectedStatus = option.status ?? 'option';
          _selectedPaymentStatus = option.paymentStatus ?? 'unpaid';
          _selectedCurrency = option.currency ?? 'USD';
          _agencyFeeController.text = option.agencyFeePercentage ?? '';
          _taxController.text = option.taxPercentage ?? '';
          _additionalFeesController.text = option.additionalFees ?? '';
          _extraHoursController.text = option.extraHours ?? '';

          // Parse time strings
          if (option.time != null && option.time!.isNotEmpty) {
            final timeParts = option.time!.split(':');
            _startTime = TimeOfDay(
              hour: int.tryParse(timeParts[0]) ?? 0,
              minute: int.tryParse(timeParts[1]) ?? 0,
            );
          }
          if (option.endTime != null && option.endTime!.isNotEmpty) {
            final timeParts = option.endTime!.split(':');
            _endTime = TimeOfDay(
              hour: int.tryParse(timeParts[0]) ?? 0,
              minute: int.tryParse(timeParts[1]) ?? 0,
            );
          }

          // Handle custom type
          if (_selectedOptionType.isNotEmpty &&
              !_optionTypes.contains(_selectedOptionType)) {
            _customTypeController.text = _selectedOptionType;
            _selectedOptionType = 'Add manually';
            _isCustomType = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading direct option: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _customTypeController.dispose();
    _agencyFeeController.dispose();
    _taxController.dispose();
    _additionalFeesController.dispose();
    _extraHoursController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration() {
    if (_startTime == null || _endTime == null) return '00:00';

    int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    int endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours if end time is next day
    }

    int durationMinutes = endMinutes - startMinutes;
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldColor,
              surface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldColor,
              surface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final optionData = {
        'client_name': _clientNameController.text,
        'option_type':
            _isCustomType ? _customTypeController.text : _selectedOptionType,
        'rate': double.tryParse(_rateController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
        'location': _locationController.text,
        'status': _selectedStatus,
        'payment_status': _selectedPaymentStatus,
        'currency': _selectedCurrency,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'notes': _notesController.text,
        'agency_fee_percentage': _agencyFeeController.text,
        'tax_percentage': _taxController.text,
        'additional_fees': _additionalFeesController.text,
        'extra_hours': _extraHoursController.text,
      };

      if (_isEditing && _editingId != null) {
        await DirectOptionsService.update(_editingId!, optionData);
      } else {
        await DirectOptionsService.create(optionData);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving direct option: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditing) {
      return AppLayout(
        currentPage: '/new-direct-option',
        title: _isEditing ? 'Edit Direct Option' : 'New Direct Option',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppLayout(
      currentPage: '/new-direct-option',
      title: _isEditing ? 'Edit Direct Option' : 'New Direct Option',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionCard(
                'Basic Information',
                [
                  ui.Input(
                    label: 'Client Name',
                    controller: _clientNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter client name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTypeField(),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Location',
                    controller: _locationController,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scheduling Section
              _buildSectionCard(
                'Scheduling',
                [
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTimeFields(),
                  const SizedBox(height: 16),
                  _buildStatusField(),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Information Section
              _buildSectionCard(
                'Payment Information',
                [
                  _buildRateField(),
                  const SizedBox(height: 16),
                  _buildPaymentStatusField(),
                  const SizedBox(height: 16),
                  _buildFeeFields(),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionCard(
                'Contact Information',
                [
                  ui.Input(
                    label: 'Phone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes Section
              _buildSectionCard(
                'Notes',
                [
                  ui.Input(
                    label: 'Notes',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Buttons
              Row(
                children: [
                  Expanded(
                    child: Button(
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Button(
                      onPressed: _isLoading ? null : _handleSubmit,
                      text: _isLoading
                          ? 'Saving...'
                          : (_isEditing ? 'Update Option' : 'Create Option'),
                      variant: ButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOptionTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Option Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_isCustomType)
          Row(
            children: [
              Expanded(
                child: ui.Input(
                  label: 'Custom Option Type',
                  controller: _customTypeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter option type';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: () {
                  setState(() {
                    _isCustomType = false;
                    _customTypeController.clear();
                  });
                },
                text: 'Cancel',
                variant: ButtonVariant.outline,
              ),
            ],
          )
        else
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedOptionType.isEmpty ? null : _selectedOptionType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Select option type',
                style: TextStyle(color: Colors.white70),
              ),
              items: _optionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == 'Add manually') {
                  setState(() {
                    _isCustomType = true;
                    _selectedOptionType = '';
                  });
                } else {
                  setState(() {
                    _selectedOptionType = value ?? '';
                  });
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2E2E2E)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            _startTime != null
                                ? _formatTime(_startTime)
                                : 'Select time',
                            style: TextStyle(
                              color: _startTime != null
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2E2E2E)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            _endTime != null
                                ? _formatTime(_endTime)
                                : 'Select time',
                            style: TextStyle(
                              color: _endTime != null
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_startTime != null && _endTime != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${_calculateDuration()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _statusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? 'option';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRateField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ui.Input(
            label: 'Rate',
            controller: _rateController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Currency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value ?? 'USD';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPaymentStatus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: _paymentStatusOptions.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentStatus = value ?? 'unpaid';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeeFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ui.Input(
                label: 'Agency Fee (%)',
                controller: _agencyFeeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ui.Input(
                label: 'Tax (%)',
                controller: _taxController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ui.Input(
                label: 'Additional Fees',
                controller: _additionalFeesController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ui.Input(
                label: 'Extra Hours',
                controller: _extraHoursController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
