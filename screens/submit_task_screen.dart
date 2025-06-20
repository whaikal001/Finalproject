import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class SubmitTaskScreen extends StatefulWidget {
  final Task task;
  final int workerId;
  final VoidCallback onSubmissionSuccess; // Callback to refresh task list

  const SubmitTaskScreen({
    super.key,
    required this.task,
    required this.workerId,
    required this.onSubmissionSuccess,
  });

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _submissionTextController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _submissionTextController.dispose();
    super.dispose();
  }

  Future<void> _submitWork() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiService.submitWork(
          widget.task.id,
          widget.workerId,
          _submissionTextController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Submission failed.')),
          );
          if (response['message'] != null && response['message'].contains('successfully')) {
            widget.onSubmissionSuccess(); // Notify parent to refresh tasks
            Navigator.pop(context); // Go back to the task list
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
        title: const Text('Submit Task Completion'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.task.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Due Date: ${widget.task.dueDate}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Completion Report:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _submissionTextController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Describe your work completion here...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a description of your completion.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitWork,
                              child: Text(
                                'SUBMIT COMPLETION',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}