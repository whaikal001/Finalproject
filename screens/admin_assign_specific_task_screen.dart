import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Make sure to import ApiService

class AssignSpecificTaskScreen extends StatefulWidget {
  const AssignSpecificTaskScreen({super.key});

  @override
  State<AssignSpecificTaskScreen> createState() => _AssignSpecificTaskScreenState();
}

class _AssignSpecificTaskScreenState extends State<AssignSpecificTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workerIdController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _workerIdController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = picked.toIso8601String().substring(0, 10); // Format YYYY-MM-DD
      });
    }
  }

  Future<void> _assignSpecificTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final int? workerId = int.tryParse(_workerIdController.text);
        if (workerId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a valid Worker ID.')),
            );
          }
          return;
        }

        final response = await ApiService.assignSpecificTask(
          _titleController.text,
          _descriptionController.text,
          workerId,
          _dueDateController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to assign task.')),
          );
          if (response['message'] != null && response['message'].contains('successfully')) {
            // Clear fields on success
            _titleController.clear();
            _descriptionController.clear();
            _workerIdController.clear();
            _dueDateController.clear();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Specific Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for the task.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description for the task.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _workerIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Assign to Worker ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Worker ID.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number for Worker ID.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a due date.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _assignSpecificTask,
                      icon: const Icon(Icons.assignment_ind),
                      label: const Text('ASSIGN TASK'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}