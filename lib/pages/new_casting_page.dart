import 'package:flutter/material.dart';
import 'package:new_flutter/models/casting.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:intl/intl.dart';

class NewCastingPage extends StatefulWidget {
  final Casting? casting;

  const NewCastingPage({super.key, this.casting});

  @override
  State<NewCastingPage> createState() => _NewCastingPageState();
}

class _NewCastingPageState extends State<NewCastingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _rateController = TextEditingController();
  String _currency = 'USD';
  String _status = 'pending';
  DateTime _date = DateTime.now();
  final List<String> _images = [];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY'];
  final List<String> _statuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // Handle both widget.casting and route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Casting) {
        _populateForm(args);
      } else if (widget.casting != null) {
        _populateForm(widget.casting!);
      }
    });
  }

  void _populateForm(Casting casting) {
    _titleController.text = casting.title;
    _descriptionController.text = casting.description;
    _locationController.text = casting.location;
    _requirementsController.text = casting.requirements;
    _rateController.text = casting.rate?.toString() ?? '';
    setState(() {
      _currency = casting.currency ?? 'USD';
      _status = casting.status;
      _date = casting.date;
      _images.clear();
      if (casting.images != null) {
        _images.addAll(casting.images!);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveCasting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      final editingCasting = args is Casting ? args : widget.casting;

      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _date.toIso8601String(),
        'location': _locationController.text,
        'requirements': _requirementsController.text,
        'status': _status,
        'rate': double.tryParse(_rateController.text),
        'currency': _currency,
        'images': _images,
      };

      if (editingCasting != null) {
        // Update existing casting
        await Casting.update(editingCasting.id, data);
      } else {
        // Create new casting
        await Casting.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingCasting != null
                ? 'Casting updated successfully'
                : 'Casting created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save casting: $e';
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
    final args = ModalRoute.of(context)?.settings.arguments;
    final isEditing = args is Casting || widget.casting != null;

    return AppLayout(
      currentPage: '/new-casting',
      title: isEditing ? 'Edit Casting' : 'New Casting',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ui.Input(
                label: 'Title',
                value: _titleController.text,
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ui.Input(
                label: 'Description',
                value: _descriptionController.text,
                controller: _descriptionController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
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
                label: 'Requirements',
                value: _requirementsController.text,
                controller: _requirementsController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter requirements';
                  }
                  return null;
                },
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
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
                  text: isEditing ? 'Update Casting' : 'Create Casting',
                  variant: ButtonVariant.primary,
                  onPressed: _isLoading ? null : _saveCasting,
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
