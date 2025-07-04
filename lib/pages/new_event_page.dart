import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/services/events_service.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/safe_dropdown.dart';
import 'package:new_flutter/widgets/ui/agent_dropdown.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class NewEventPage extends StatefulWidget {
  final EventType eventType;
  
  const NewEventPage({
    super.key,
    required this.eventType,
  });

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _usageRateController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _photographerController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _agencyAddressController = TextEditingController();
  final _hotelAddressController = TextEditingController();
  final _flightCostController = TextEditingController();
  final _hotelCostController = TextEditingController();
  final _pocketMoneyController = TextEditingController();
  final _industryContactController = TextEditingController();

  // New missing field controllers
  final _agencyFeeController = TextEditingController();
  final _extraHoursController = TextEditingController();
  final _taxController = TextEditingController();
  final _callTimeController = TextEditingController();
  final _contractController = TextEditingController();
  
  // Form State
  DateTime _selectedDate = DateTime.now();
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCurrency = 'USD';
  EventStatus _selectedStatus = EventStatus.scheduled;
  PaymentStatus _selectedPaymentStatus = PaymentStatus.unpaid;
  final OptionStatus _selectedOptionStatus = OptionStatus.pending;
  String? _selectedAgentId;
  final List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  bool _isDateRange = false;
  bool _isPaid = false;
  bool _hasPocketMoney = false;
  TimeOfDay? _callTime;
  String? _error;

  // Job Types for casting/test
  String? _selectedJobType;
  String? _selectedOptionType;
  String _selectedTestType = 'Free';
  String _selectedPolaroidType = 'Free';
  bool _isCustomJobType = false;
  bool _isCustomOptionType = false;

  // Currencies
  final List<String> _currencies = [
    'USD', 'EUR', 'PLN', 'ILS', 'JPY', 'KRW', 'GBP', 'CNY', 'AUD'
  ];

  // Job Types
  final List<String> _jobTypes = [
    'Add manually',
    'Advertising',
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
    'TikTok',
    'AI',
    'Film'
  ];

  @override
  void initState() {
    super.initState();

    // Ensure initial values are valid
    if (!_currencies.contains(_selectedCurrency)) {
      _selectedCurrency = _currencies.first;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dayRateController.dispose();
    _usageRateController.dispose();
    _customTypeController.dispose();
    _subjectController.dispose();
    _eventNameController.dispose();
    _photographerController.dispose();
    _agencyNameController.dispose();
    _agencyAddressController.dispose();
    _hotelAddressController.dispose();
    _flightCostController.dispose();
    _hotelCostController.dispose();
    _pocketMoneyController.dispose();
    _industryContactController.dispose();
    _agencyFeeController.dispose();
    _extraHoursController.dispose();
    _taxController.dispose();
    _callTimeController.dispose();
    _contractController.dispose();
    super.dispose();
  }



  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String get _pageTitle {
    switch (widget.eventType) {
      case EventType.option:
        return 'New Option';
      case EventType.job:
        return 'New Job';
      case EventType.directOption:
        return 'New Direct Option';
      case EventType.directBooking:
        return 'New Direct Booking';
      case EventType.casting:
        return 'New Casting';
      case EventType.onStay:
        return 'New On Stay';
      case EventType.test:
        return 'New Test';
      case EventType.polaroids:
        return 'New Polaroids';
      case EventType.meeting:
        return 'New Meeting';
      case EventType.other:
        return 'New Event';
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventData = _buildEventData();
      final event = Event(
        type: widget.eventType,
        clientName: _clientNameController.text.isNotEmpty ? _clientNameController.text : null,
        date: _selectedDate,
        endDate: _endDate,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        agentId: _selectedAgentId,
        dayRate: double.tryParse(_dayRateController.text),
        usageRate: double.tryParse(_usageRateController.text),
        currency: _selectedCurrency,
        status: _selectedStatus,
        paymentStatus: _selectedPaymentStatus,
        optionStatus: _selectedOptionStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        additionalData: eventData,
      );

      final createdEvent = await EventsService().createEvent(event.toJson());

      if (createdEvent != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.eventType.displayName} created successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create ${widget.eventType.displayName.toLowerCase()}: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildEventData() {
    final data = <String, dynamic>{};
    
    switch (widget.eventType) {
      case EventType.option:
      case EventType.directOption:
        data['option_type'] = _isCustomOptionType ? _customTypeController.text : _selectedOptionType;
        data['option_status'] = _selectedOptionStatus.toString().split('.').last;
        data['agency_fee'] = double.tryParse(_agencyFeeController.text);
        data['call_time'] = _formatTimeOfDay(_callTime);
        break;

      case EventType.job:
      case EventType.directBooking:
        data['job_type'] = _isCustomJobType ? _customTypeController.text : _selectedJobType;
        data['agency_fee'] = double.tryParse(_agencyFeeController.text);
        data['extra_hours'] = double.tryParse(_extraHoursController.text);
        data['tax_percentage'] = double.tryParse(_taxController.text);
        data['call_time'] = _formatTimeOfDay(_callTime);
        break;

      case EventType.casting:
        data['job_type'] = _isCustomJobType ? _customTypeController.text : _selectedJobType;
        break;
        
      case EventType.test:
        data['photographer_name'] = _photographerController.text;
        data['test_type'] = _selectedTestType;
        data['is_paid'] = _isPaid;
        data['call_time'] = _formatTimeOfDay(_callTime);
        break;
        
      case EventType.polaroids:
        data['polaroid_type'] = _selectedPolaroidType;
        data['is_paid'] = _isPaid;
        data['call_time'] = _formatTimeOfDay(_callTime);
        break;
        
      case EventType.meeting:
        data['subject'] = _subjectController.text;
        data['industry_contact'] = _industryContactController.text;
        break;
        
      case EventType.onStay:
        data['agency_name'] = _agencyNameController.text;
        data['agency_address'] = _agencyAddressController.text;
        data['hotel_address'] = _hotelAddressController.text;
        data['flight_cost'] = double.tryParse(_flightCostController.text);
        data['hotel_cost'] = double.tryParse(_hotelCostController.text);
        data['has_pocket_money'] = _hasPocketMoney;
        data['pocket_money_cost'] = double.tryParse(_pocketMoneyController.text);
        data['contract'] = _contractController.text;
        break;
        
      case EventType.other:
        data['event_name'] = _eventNameController.text;
        break;
    }
    
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/new-event',
      title: _pageTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                _pageTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details for your ${widget.eventType.displayName.toLowerCase()}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Dynamic form fields based on event type
              ..._buildFormFields(),

              const SizedBox(height: 32),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: Button(
                  text: 'Create ${widget.eventType.displayName}',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _createEvent,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = <Widget>[];

    // Common fields for most event types
    if (_needsClientName()) {
      fields.addAll([
        ui.Input(
          controller: _clientNameController,
          placeholder: 'Client name *',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Client name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ]);
    }

    // Event-specific fields
    fields.addAll(_buildEventSpecificFields());

    // Date fields
    fields.addAll(_buildDateFields());

    // Time fields (for most events)
    if (_needsTimeFields()) {
      fields.addAll(_buildTimeFields());
    }

    // Location field
    if (_needsLocation()) {
      fields.addAll([
        const SizedBox(height: 16),
        ui.Input(
          controller: _locationController,
          placeholder: 'Location',
        ),
      ]);
    }

    // Agent field
    if (_needsAgent()) {
      fields.addAll(_buildAgentField());
    }

    // Rate fields
    if (_needsRateFields()) {
      fields.addAll(_buildRateFields());
    }

    // Status fields
    if (_needsStatusFields()) {
      fields.addAll(_buildStatusFields());
    }

    // Files
    fields.addAll(_buildFileUploadSection());

    // Notes
    fields.addAll([
      const SizedBox(height: 24),
      ui.Input(
        controller: _notesController,
        placeholder: 'Notes (optional)',
        maxLines: 3,
      ),
    ]);

    return fields;
  }

  bool _needsClientName() {
    return widget.eventType != EventType.meeting &&
           widget.eventType != EventType.other &&
           widget.eventType != EventType.test &&
           widget.eventType != EventType.polaroids;
  }

  bool _needsTimeFields() {
    return widget.eventType != EventType.onStay;
  }

  bool _needsLocation() {
    return true; // All events need location
  }

  bool _needsAgent() {
    return widget.eventType != EventType.meeting && widget.eventType != EventType.other;
  }

  bool _needsRateFields() {
    return widget.eventType == EventType.option ||
           widget.eventType == EventType.job ||
           widget.eventType == EventType.directOption ||
           widget.eventType == EventType.directBooking ||
           widget.eventType == EventType.test ||
           widget.eventType == EventType.polaroids;
  }

  bool _needsStatusFields() {
    return widget.eventType == EventType.job ||
           widget.eventType == EventType.directBooking;
  }

  List<Widget> _buildEventSpecificFields() {
    switch (widget.eventType) {
      case EventType.option:
      case EventType.directOption:
        return _buildOptionFields();
      case EventType.job:
      case EventType.directBooking:
        return _buildJobFields();
      case EventType.casting:
        return _buildCastingFields();
      case EventType.onStay:
        return _buildOnStayFields();
      case EventType.test:
        return _buildTestFields();
      case EventType.polaroids:
        return _buildPolaroidFields();
      case EventType.meeting:
        return _buildMeetingFields();
      case EventType.other:
        return _buildOtherFields();
    }
  }

  List<Widget> _buildOptionFields() {
    return [
      SafeDropdown(
        value: _selectedOptionType,
        items: _jobTypes,
        labelText: 'Option Type',
        hintText: 'Select option type',
        onChanged: (value) {
          if (value == 'Add manually') {
            setState(() {
              _isCustomOptionType = true;
              _selectedOptionType = null;
            });
          } else {
            setState(() {
              _isCustomOptionType = false;
              _selectedOptionType = value;
            });
          }
        },
        validator: (value) {
          if (!_isCustomOptionType && (value == null || value.isEmpty)) {
            return 'Option type is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      if (_isCustomOptionType) ...[
        ui.Input(
          controller: _customTypeController,
          placeholder: 'Enter custom option type',
          validator: (value) {
            if (_isCustomOptionType && (value == null || value.trim().isEmpty)) {
              return 'Option type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
      // Agency Fee field
      const SizedBox(height: 16),
      TextFormField(
        controller: _agencyFeeController,
        decoration: const InputDecoration(
          labelText: 'Agency Fee (%)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
      ),
      // Call Time field
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Call Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _callTime != null ? _formatTimeOfDay(_callTime) : '',
        ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _callTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _callTime = time;
            });
          }
        },
      ),
    ];
  }

  List<Widget> _buildJobFields() {
    return [
      SafeDropdown(
        value: _selectedJobType,
        items: _jobTypes,
        labelText: 'Job Type',
        hintText: 'Select job type',
        onChanged: (value) {
          if (value == 'Add manually') {
            setState(() {
              _isCustomJobType = true;
              _selectedJobType = null;
            });
          } else {
            setState(() {
              _isCustomJobType = false;
              _selectedJobType = value;
            });
          }
        },
        validator: (value) {
          if (!_isCustomJobType && (value == null || value.isEmpty)) {
            return 'Job type is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      if (_isCustomJobType) ...[
        ui.Input(
          controller: _customTypeController,
          placeholder: 'Enter custom job type',
          validator: (value) {
            if (_isCustomJobType && (value == null || value.trim().isEmpty)) {
              return 'Job type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
      // Financial fields in responsive row
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _agencyFeeController,
              decoration: const InputDecoration(
                labelText: 'Agency Fee (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _extraHoursController,
              decoration: const InputDecoration(
                labelText: 'Extra Hours',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _taxController,
              decoration: const InputDecoration(
                labelText: 'Tax (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Call Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _callTime != null ? _formatTimeOfDay(_callTime) : '',
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _callTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _callTime = time;
                  });
                }
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDateFields() {
    return [
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: DateFormat('MMM d, yyyy').format(_selectedDate),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              validator: (value) => value == null || value.isEmpty ? 'Date is required' : null,
            ),
          ),
          if (_isDateRange) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : '',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _selectedDate.add(const Duration(days: 1)),
                    firstDate: _selectedDate,
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
            ),
          ],
        ],
      ),
      if (widget.eventType == EventType.job || widget.eventType == EventType.directBooking || widget.eventType == EventType.onStay) ...[
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Date Range', style: TextStyle(color: Colors.white)),
          value: _isDateRange,
          onChanged: (value) {
            setState(() {
              _isDateRange = value ?? false;
              if (!_isDateRange) {
                _endDate = null;
              }
            });
          },
          activeColor: AppTheme.goldColor,
        ),
      ],
    ];
  }

  List<Widget> _buildTimeFields() {
    return [
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Start Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _startTime != null ? _formatTimeOfDay(_startTime) : '',
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _startTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _startTime = time;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'End Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _endTime != null ? _formatTimeOfDay(_endTime) : '',
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _endTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _endTime = time;
                  });
                }
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAgentField() {
    return [
      const SizedBox(height: 16),
      AgentDropdown(
        selectedAgentId: _selectedAgentId,
        labelText: 'Agent *',
        hintText: 'Select an agent',
        onChanged: (value) {
          setState(() {
            _selectedAgentId = value;
          });
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please select an agent';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildRateFields() {
    return [
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _dayRateController,
              decoration: const InputDecoration(
                labelText: 'Day Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SafeDropdown(
              value: _selectedCurrency,
              items: _currencies,
              labelText: 'Currency',
              hintText: 'Select currency',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _usageRateController,
        decoration: const InputDecoration(
          labelText: 'Usage Rate (optional)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
      ),
    ];
  }

  List<Widget> _buildStatusFields() {
    return [
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: SafeEnumDropdown<EventStatus>(
              value: _selectedStatus,
              items: EventStatus.values,
              labelText: 'Status',
              hintText: 'Select status',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SafeEnumDropdown<PaymentStatus>(
              value: _selectedPaymentStatus,
              items: PaymentStatus.values,
              labelText: 'Payment Status',
              hintText: 'Select payment status',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentStatus = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildFileUploadSection() {
    return [
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Files'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldColor,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(_selectedFiles.length, (index) {
                final file = _selectedFiles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(file.extension ?? ''),
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFile(index),
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'No files selected. You can upload contracts, invoices, schedules, and other documents.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildCastingFields() {
    return [
      SafeDropdown(
        value: _selectedJobType,
        items: _jobTypes,
        labelText: 'Job Type',
        hintText: 'Select job type',
        onChanged: (value) {
          if (value == 'Add manually') {
            setState(() {
              _isCustomJobType = true;
              _selectedJobType = null;
            });
          } else {
            setState(() {
              _isCustomJobType = false;
              _selectedJobType = value;
            });
          }
        },
        validator: (value) {
          if (!_isCustomJobType && (value == null || value.isEmpty)) {
            return 'Job type is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      if (_isCustomJobType) ...[
        ui.Input(
          controller: _customTypeController,
          placeholder: 'Enter custom job type',
          validator: (value) {
            if (_isCustomJobType && (value == null || value.trim().isEmpty)) {
              return 'Job type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    ];
  }

  List<Widget> _buildTestFields() {
    return [
      ui.Input(
        controller: _photographerController,
        placeholder: 'Photographer name *',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Photographer name is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: SafeDropdown(
              value: _selectedTestType,
              items: const ['Free', 'Paid'],
              labelText: 'Test Type',
              hintText: 'Select test type',
              onChanged: (value) {
                setState(() {
                  _selectedTestType = value ?? 'Free';
                  _isPaid = value == 'Paid';
                });
              },
            ),
          ),
          if (_isPaid) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _dayRateController,
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ),
          ],
        ],
      ),
      // Call Time field
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Call Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _callTime != null ? _formatTimeOfDay(_callTime) : '',
        ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _callTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _callTime = time;
            });
          }
        },
      ),
    ];
  }

  List<Widget> _buildPolaroidFields() {
    return [
      Row(
        children: [
          Expanded(
            child: SafeDropdown(
              value: _selectedPolaroidType,
              items: const ['Free', 'Paid'],
              labelText: 'Polaroid Type',
              hintText: 'Select polaroid type',
              onChanged: (value) {
                setState(() {
                  _selectedPolaroidType = value ?? 'Free';
                  _isPaid = value == 'Paid';
                });
              },
            ),
          ),
          if (_isPaid) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _dayRateController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ),
          ],
        ],
      ),
      // Call Time field
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Call Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _callTime != null ? _formatTimeOfDay(_callTime) : '',
        ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _callTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _callTime = time;
            });
          }
        },
      ),
    ];
  }

  List<Widget> _buildMeetingFields() {
    return [
      ui.Input(
        controller: _subjectController,
        placeholder: 'Subject *',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Subject is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      ui.Input(
        controller: _industryContactController,
        placeholder: 'Industry contact',
      ),
    ];
  }

  List<Widget> _buildOtherFields() {
    return [
      ui.Input(
        controller: _eventNameController,
        placeholder: 'Event name *',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Event name is required';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildOnStayFields() {
    return [
      ui.Input(
        controller: _agencyNameController,
        placeholder: 'Agency name *',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Agency name is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      ui.Input(
        controller: _agencyAddressController,
        placeholder: 'Agency address',
      ),
      const SizedBox(height: 16),
      ui.Input(
        controller: _hotelAddressController,
        placeholder: 'Hotel/Apartment address',
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _flightCostController,
              decoration: const InputDecoration(
                labelText: 'Flight cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _hotelCostController,
              decoration: const InputDecoration(
                labelText: 'Hotel cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ui.Input(
        controller: _contractController,
        placeholder: 'Contract details',
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        title: const Text('Pocket Money', style: TextStyle(color: Colors.white)),
        value: _hasPocketMoney,
        onChanged: (value) {
          setState(() {
            _hasPocketMoney = value ?? false;
          });
        },
        activeColor: AppTheme.goldColor,
      ),
      if (_hasPocketMoney) ...[
        const SizedBox(height: 16),
        TextFormField(
          controller: _pocketMoneyController,
          decoration: const InputDecoration(
            labelText: 'Pocket money cost',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
      ],
    ];
  }
}
