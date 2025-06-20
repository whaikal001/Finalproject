import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Worker worker;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.worker, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current worker data, ensuring non-null strings
    _fullNameController = TextEditingController(text: widget.worker.fullName ?? '');
    _emailController = TextEditingController(text: widget.worker.email ?? '');
    _phoneController = TextEditingController(text: widget.worker.phone ?? '');
    _addressController = TextEditingController(text: widget.worker.address ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      // If exiting edit mode without saving, you might want to revert changes
      // For now, we'll assume changes are applied or user backs out.
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create an updated Worker object from controller texts
        Worker updatedWorker = Worker(
          id: widget.worker.id,
          fullName: _fullNameController.text,
          email: _emailController.text, // Email typically not editable
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null, // Store null if empty
          address: _addressController.text.isNotEmpty ? _addressController.text : null, // Store null if empty
        );

        final response = await ApiService.updateProfile(updatedWorker);

        if (mounted) { // Check if the widget is still in the tree before calling setState
          setState(() {
            _isLoading = false;
            _isEditing = false; // Exit edit mode on successful update
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Profile updated successfully!')),
          );
          // If you need to update the parent's worker object, use a callback:
          // widget.onProfileUpdated(updatedWorker); // Assuming onProfileUpdated callback exists
        }
      } catch (e) {
        if (mounted) { // Check if the widget is still in the tree before calling setState
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _toggleEditMode,
            )
          else
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () {
                // Revert changes if editing is cancelled without saving
                _fullNameController.text = widget.worker.fullName ?? '';
                _emailController.text = widget.worker.email ?? '';
                _phoneController.text = widget.worker.phone ?? '';
                _addressController.text = widget.worker.address ?? '';
                _toggleEditMode();
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _isLoading ? null : _updateProfile, // Disable save button while loading
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _fullNameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                    filled: _isEditing,
                  ),
                  validator: (value) {
                    if (_isEditing && (value == null || value.isEmpty)) {
                      return 'Full Name cannot be empty.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  enabled: false, // Email is typically not editable for security
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: InputBorder.none, // Non-editable field often looks better without a border
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone (Optional)',
                    prefixIcon: const Icon(Icons.phone),
                    border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                    filled: _isEditing,
                  ),
                  // No specific validator for optional phone, but can add one for format if needed
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  enabled: _isEditing,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: const Icon(Icons.location_on),
                    border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                    filled: _isEditing,
                  ),
                  // No specific validator for optional address
                ),
                const SizedBox(height: 40),
                if (!_isEditing) // Only show logout button when not in editing mode
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Logout'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onLogout();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'LOGOUT',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}