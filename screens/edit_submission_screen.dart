import 'package:flutter/material.dart';
import '../models/submission.dart';
import '../services/api_service.dart';

class EditSubmissionScreen extends StatefulWidget {
  final Submission submission;
  final VoidCallback onSubmissionUpdated; // Callback to refresh history

  const EditSubmissionScreen({
    super.key,
    required this.submission,
    required this.onSubmissionUpdated,
  });

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _submissionTextController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _submissionTextController = TextEditingController(text: widget.submission.submissionText);
  }

  @override
  void dispose() {
    _submissionTextController.dispose();
    super.dispose();
  }

  Future<void> _updateSubmission() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiService.editSubmission(
          widget.submission.submissionId,
          _submissionTextController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to update submission.')),
          );
          if (response['message'] != null && response['message'].contains('successfully')) {
            widget.onSubmissionUpdated(); // Notify parent to refresh history
            Navigator.pop(context); // Go back to submission history
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
        title: const Text('Edit Submission'),
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
                      'Task: ${widget.submission.taskTitle}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Original Submission Time: ${widget.submission.submittedAt.substring(0, 16)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Edit Your Report:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _submissionTextController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Edit your work completion report...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Submission text cannot be empty.';
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
                              onPressed: () {
                                // Show confirmation dialog before updating
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Update'),
                                      content: const Text('Are you sure you want to save these changes?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Update'),
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close dialog
                                            _updateSubmission(); // Proceed with update
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'SAVE CHANGES',
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