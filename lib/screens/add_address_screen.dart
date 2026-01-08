import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/models/address_model.dart';
import 'package:zionshopings/services/address_controller.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? addressToEdit;
  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _receiverNameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addressToEdit?.name ?? '');
    _receiverNameController = TextEditingController(text: widget.addressToEdit?.receiverName ?? '');
    _phoneController = TextEditingController(text: widget.addressToEdit?.phoneNumber ?? '');
    _streetController = TextEditingController(text: widget.addressToEdit?.street ?? '');
    _cityController = TextEditingController(text: widget.addressToEdit?.city ?? '');
    _stateController = TextEditingController(text: widget.addressToEdit?.state ?? '');
    _zipController = TextEditingController(text: widget.addressToEdit?.zipCode ?? '');
    _isDefault = widget.addressToEdit?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: widget.addressToEdit?.id ?? const Uuid().v4(),
        name: _nameController.text,
        receiverName: _receiverNameController.text,
        phoneNumber: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        isDefault: _isDefault,
      );

      if (widget.addressToEdit != null) {
        context.read<AddressController>().updateAddress(address);
      } else {
        context.read<AddressController>().addAddress(address);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.addressToEdit != null ? 'Edit Address' : 'Add New Address'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Address Name (e.g. Home, Office)', _nameController, isDark),
              const SizedBox(height: 20),
              _buildTextField('Receiver Name', _receiverNameController, isDark),
              const SizedBox(height: 20),
              _buildTextField('Phone Number', _phoneController, isDark, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField('Street / Building', _streetController, isDark),
              const SizedBox(height: 20),
              Row(
                children: [
                   Expanded(child: _buildTextField('City', _cityController, isDark)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildTextField('State', _stateController, isDark)),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField('ZIP Code', _zipController, isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              
              SwitchListTile(
                title: const Text('Set as default address', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isDefault,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Save Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
