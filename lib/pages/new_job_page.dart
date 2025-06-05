import 'package:flutter/material.dart';
import 'package:new_flutter/services/jobs_service.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:intl/intl.dart';

class NewJobPage extends StatefulWidget {
  const NewJobPage({super.key});

  @override
  State<NewJobPage> createState() => _NewJobPageState();
}

class _NewJobPageState extends State<NewJobPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  final _clientNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _rateController = TextEditingController();
  String _currency = 'USD';
  String _selectedJobType = '';
  bool _isCustomType = false;
  DateTime _date = DateTime.now();
  final String _startTime = '';
  final String _endTime = '';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY'];

  @override
  void dispose() {
    _clientNameController.dispose();
    _typeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await JobsService.create({
        'client_name': _clientNameController.text,
        'type': _isCustomType ? _typeController.text : _selectedJobType,
        'date': _date.toIso8601String().split('T')[0],
        'time': _startTime.isNotEmpty ? _startTime : null,
        'end_time': _endTime.isNotEmpty ? _endTime : null,
        'location': _locationController.text,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'currency': _currency,
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create job: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/new-job',
      title: 'New Job',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ui.Input(
                label: 'Client Name',
                value: _clientNameController.text,
                controller: _clientNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Type Section
              const Text(
                'Job Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_isCustomType) ...[
                Row(
                  children: [
                    Expanded(
                      child: ui.Input(
                        value: _typeController.text,
                        controller: _typeController,
                        placeholder: 'Enter custom job type',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Job type is required';
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
                          _typeController.clear();
                        });
                      },
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                    ),
                  ],
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  value: _selectedJobType.isEmpty ? null : _selectedJobType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2E2E2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF444444)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF444444)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCDAA7D)),
                    ),
                  ),
                  dropdownColor: const Color(0xFF2E2E2E),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select job type',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: const [
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
                    'Web / Social Media Shooting'
                  ].map((type) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Job type is required';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMM d, yyyy').format(_date),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _date = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ui.Input(
                label: 'Location',
                value: _locationController.text,
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ui.Input(
                label: 'Notes',
                value: _notesController.text,
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ui.Input(
                      label: 'Rate',
                      value: _rateController.text,
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final rate = double.tryParse(value);
                          if (rate == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      value: _currency,
                      items: _currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _currency = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

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
                  text: 'Create Job',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _createJob,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
