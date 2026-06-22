import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/cat.dart';
import '../../../shared/providers/cat_provider.dart';

class CatFormScreen extends ConsumerStatefulWidget {
  final Cat? catToEdit;

  const CatFormScreen({super.key, this.catToEdit});

  @override
  ConsumerState<CatFormScreen> createState() => _CatFormScreenState();
}

class _CatFormScreenState extends ConsumerState<CatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  DateTime? _selectedDate;
  String _gender = 'Female';
  bool _isNeutered = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.catToEdit?.name ?? '');
    _breedController = TextEditingController(text: widget.catToEdit?.breed ?? '');
    _weightController = TextEditingController(text: widget.catToEdit?.weight?.toString() ?? '');
    _selectedDate = widget.catToEdit?.birthDate;
    if (widget.catToEdit != null) {
      _gender = widget.catToEdit!.gender;
      _isNeutered = widget.catToEdit!.isNeutered;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveCat() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a birth date')),
        );
        return;
      }

      final weight = double.tryParse(_weightController.text);

      if (widget.catToEdit == null) {
        // Add new
        ref.read(catListProvider.notifier).addCat(
          name: _nameController.text,
          breed: _breedController.text,
          birthDate: _selectedDate!,
          gender: _gender,
          isNeutered: _isNeutered,
          weight: weight,
        );
      } else {
        // Update existing
        final cat = widget.catToEdit!
          ..name = _nameController.text
          ..breed = _breedController.text
          ..birthDate = _selectedDate!
          ..gender = _gender
          ..isNeutered = _isNeutered
          ..weight = weight;
        ref.read(catListProvider.notifier).updateCat(cat);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.catToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Cat' : 'Add New Cat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo placeholder
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
                validator: (value) => value!.isEmpty ? 'Please enter a breed' : null,
              ),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Birth Date'),
                subtitle: Text(_selectedDate == null 
                  ? 'Select Date' 
                  : DateFormat.yMMMd().format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Female', 'Male'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Neutered/Spayed'),
                value: _isNeutered,
                onChanged: (val) {
                  setState(() {
                    _isNeutered = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)', suffixText: 'kg'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveCat,
                child: Text(isEditing ? 'Save Changes' : 'Add Cat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
