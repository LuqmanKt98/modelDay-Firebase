import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();

  String _selectedEventType = '';
  String _selectedJobType = '';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isCustomType = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _eventTypes = [
    {
      'value': 'directbookings',
      'label': 'Direct Bookings',
      'color': Colors.teal
    },
    {'value': 'directoptions', 'label': 'Direct Options', 'color': Colors.cyan},
    {'value': 'jobs', 'label': 'Jobs', 'color': Colors.blue},
    {'value': 'castings', 'label': 'Castings', 'color': Colors.purple},
    {'value': 'test', 'label': 'Test', 'color': Colors.green},
    {'value': 'onstay', 'label': 'OnStay', 'color': Colors.orange},
    {'value': 'polaroids', 'label': 'Polaroids', 'color': Colors.pink},
    {'value': 'meetings', 'label': 'Meetings', 'color': Colors.indigo},
    {'value': 'aijobs', 'label': 'AI Jobs', 'color': Colors.white},
  ];

  final List<String> _jobTypes = [
    'Add manually',
    'Campaign',
    'E-commerce',
    'Editorial',
    'Fittings',
    'Lookbook',
    'Looks',
    'Show',
    'Showroom',
    'TVC',
    'Web / Social Media Shooting',
  ];

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
  void dispose() {
    _clientNameController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    _customTypeController.dispose();
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
      // Navigate to the appropriate page based on event type
      String routeName = '/calendar';
      switch (_selectedEventType) {
        case 'directbookings':
          routeName = '/new-direct-booking';
          break;
        case 'directoptions':
          routeName = '/new-direct-option';
          break;
        case 'jobs':
          routeName = '/new-job';
          break;
        case 'castings':
          routeName = '/new-casting';
          break;
        case 'test':
          routeName = '/new-test';
          break;
        case 'onstay':
          routeName = '/new-on-stay';
          break;
        case 'polaroids':
          routeName = '/new-polaroid';
          break;
        case 'meetings':
          routeName = '/new-meeting';
          break;
        case 'aijobs':
          routeName = '/new-ai-job';
          break;
        default:
          routeName = '/calendar';
      }

      // Pass the form data to the specific creation page
      Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: {
          'clientName': _clientNameController.text,
          'jobType':
              _isCustomType ? _customTypeController.text : _selectedJobType,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'startTime': _formatTime(_startTime),
          'endTime': _formatTime(_endTime),
          'location': _locationController.text,
          'rate': _rateController.text,
          'currency': _selectedCurrency,
          'notes': _notesController.text,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/add-event',
      title: 'Add New Event',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Name
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

              // Event Type Selection
              const Text(
                'Event Type',
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
                  value: _selectedEventType.isEmpty || !_eventTypes.any((type) => type['value'] == _selectedEventType) ? null : _selectedEventType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select event type',
                    style: TextStyle(color: Colors.white70),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an event type';
                    }
                    return null;
                  },
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: type['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type['label'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Job Type Selection
              if (_selectedEventType.isNotEmpty) ...[
                const Text(
                  'Job Type',
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
                          label: 'Custom Job Type',
                          controller: _customTypeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter job type';
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
                      value: _selectedJobType.isEmpty || !_jobTypes.contains(_selectedJobType) ? null : _selectedJobType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.white),
                      hint: const Text(
                        'Select job type',
                        style: TextStyle(color: Colors.white70),
                      ),
                      items: _jobTypes.map((type) {
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
                            _selectedJobType = '';
                          });
                        } else {
                          setState(() {
                            _selectedJobType = value ?? '';
                          });
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Date Selection
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const SizedBox(height: 16),

              // Time Selection
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
                              border:
                                  Border.all(color: const Color(0xFF2E2E2E)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white70),
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
                              border:
                                  Border.all(color: const Color(0xFF2E2E2E)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white70),
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
              const SizedBox(height: 16),

              // Duration Display
              if (_startTime != null && _endTime != null) ...[
                const Text(
                  'Duration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2E2E2E)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        _calculateDuration(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Location
              ui.Input(
                label: 'Location',
                controller: _locationController,
              ),
              const SizedBox(height: 16),

              // Rate and Currency
              Row(
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
                            value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : _currencies.first,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
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
              ),
              const SizedBox(height: 16),

              // Notes
              ui.Input(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

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
                      text: _isLoading ? 'Creating...' : 'Create Event',
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
}
