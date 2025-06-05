import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';

import 'package:new_flutter/services/agencies_service.dart';

class NewAgencyPage extends StatefulWidget {
  const NewAgencyPage({super.key});

  @override
  State<NewAgencyPage> createState() => _NewAgencyPageState();
}

class _NewAgencyPageState extends State<NewAgencyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _notesController = TextEditingController();

  // Main Booker
  final _mainBookerNameController = TextEditingController();
  final _mainBookerEmailController = TextEditingController();
  final _mainBookerPhoneController = TextEditingController();

  // Finance Contact
  final _financeNameController = TextEditingController();
  final _financeEmailController = TextEditingController();
  final _financePhoneController = TextEditingController();

  String _selectedStatus = 'active';
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingId;

  final List<String> _statusOptions = ['active', 'inactive', 'pending'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _loadAgency(args);
      }
    });
  }

  Future<void> _loadAgency(String id) async {
    setState(() {
      _isLoading = true;
      _isEditing = true;
      _editingId = id;
    });

    try {
      final agency = await AgenciesService.getById(id);
      if (agency != null) {
        setState(() {
          _nameController.text = agency.name;
          _websiteController.text = agency.website ?? '';
          _addressController.text = agency.address ?? '';
          _cityController.text = agency.city ?? '';
          _countryController.text = agency.country ?? '';
          _commissionRateController.text = agency.commissionRate.toString();
          _notesController.text = agency.notes ?? '';
          _selectedStatus = agency.status ?? 'active';

          // Main Booker
          if (agency.mainBooker != null) {
            _mainBookerNameController.text = agency.mainBooker!.name;
            _mainBookerEmailController.text = agency.mainBooker!.email;
            _mainBookerPhoneController.text = agency.mainBooker!.phone;
          }

          // Finance Contact
          if (agency.financeContact != null) {
            _financeNameController.text = agency.financeContact!.name;
            _financeEmailController.text = agency.financeContact!.email;
            _financePhoneController.text = agency.financeContact!.phone;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading agency: $e'),
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
    _nameController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _commissionRateController.dispose();
    _notesController.dispose();
    _mainBookerNameController.dispose();
    _mainBookerEmailController.dispose();
    _mainBookerPhoneController.dispose();
    _financeNameController.dispose();
    _financeEmailController.dispose();
    _financePhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final agencyData = {
        'name': _nameController.text,
        'website':
            _websiteController.text.isEmpty ? null : _websiteController.text,
        'address':
            _addressController.text.isEmpty ? null : _addressController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'country':
            _countryController.text.isEmpty ? null : _countryController.text,
        'commission_rate':
            double.tryParse(_commissionRateController.text) ?? 0.0,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'status': _selectedStatus,
        'main_booker': {
          'name': _mainBookerNameController.text,
          'email': _mainBookerEmailController.text,
          'phone': _mainBookerPhoneController.text,
        },
        'finance_contact': {
          'name': _financeNameController.text,
          'email': _financeEmailController.text,
          'phone': _financePhoneController.text,
        },
      };

      if (_isEditing && _editingId != null) {
        await AgenciesService.update(_editingId!, agencyData);
      } else {
        await AgenciesService.create(agencyData);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving agency: $e'),
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
        currentPage: '/new-agency',
        title: _isEditing ? 'Edit Agency' : 'New Agency',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AppLayout(
      currentPage: '/new-agency',
      title: _isEditing ? 'Edit Agency' : 'New Agency',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionCard(
                'Basic Information',
                [
                  ui.Input(
                    label: 'Agency Name',
                    value: _nameController.text,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter agency name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Website',
                    value: _websiteController.text,
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Address',
                    value: _addressController.text,
                    controller: _addressController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'City',
                          value: _cityController.text,
                          controller: _cityController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ui.Input(
                          label: 'Country',
                          value: _countryController.text,
                          controller: _countryController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ui.Input(
                          label: 'Commission Rate (%)',
                          value: _commissionRateController.text,
                          controller: _commissionRateController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusField(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Booker
              _buildSectionCard(
                'Main Booker',
                [
                  ui.Input(
                    label: 'Name',
                    value: _mainBookerNameController.text,
                    controller: _mainBookerNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter main booker name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    value: _mainBookerEmailController.text,
                    controller: _mainBookerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter main booker email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Phone',
                    value: _mainBookerPhoneController.text,
                    controller: _mainBookerPhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Finance Contact
              _buildSectionCard(
                'Finance Contact',
                [
                  ui.Input(
                    label: 'Name',
                    value: _financeNameController.text,
                    controller: _financeNameController,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Email',
                    value: _financeEmailController.text,
                    controller: _financeEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ui.Input(
                    label: 'Phone',
                    value: _financePhoneController.text,
                    controller: _financePhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              _buildSectionCard(
                'Notes',
                [
                  ui.Input(
                    label: 'Notes',
                    value: _notesController.text,
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
                          : (_isEditing ? 'Update Agency' : 'Create Agency'),
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
                _selectedStatus = value ?? 'active';
              });
            },
          ),
        ),
      ],
    );
  }
}
