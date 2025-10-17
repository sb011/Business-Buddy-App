import 'package:flutter/material.dart';
import '../api_calls/auth_apis.dart';
import '../models/auth/auth_request.dart';
import '../utils/shared_preferences.dart';
import '../constants/strings.dart';
import '../constants/roles.dart';
import '../constants/permissions.dart';
import '../widgets/permission_wrapper.dart';

class AddUsersToInventoryPage extends StatefulWidget {
  const AddUsersToInventoryPage({super.key});

  @override
  State<AddUsersToInventoryPage> createState() =>
      _AddUsersToInventoryPageState();
}

class _AddUsersToInventoryPageState extends State<AddUsersToInventoryPage> {
  final List<Map<String, TextEditingController>> _userControllers = [];
  final List<String> _roles = AppRoles.allRoles;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addUserField();
  }

  void _addUserField() {
    setState(() {
      _userControllers.add({
        'mobileNumber': TextEditingController(),
        'role': TextEditingController(text: _roles[0]),
      });
    });
  }

  void _removeUserField(int index) {
    if (_userControllers.length > 1) {
      setState(() {
        _userControllers[index]['mobileNumber']?.dispose();
        _userControllers[index]['role']?.dispose();
        _userControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitUsers() async {
    // Validate all fields
    for (int i = 0; i < _userControllers.length; i++) {
      final mobileNumber = _userControllers[i]['mobileNumber']?.text.trim();
      final role = _userControllers[i]['role']?.text.trim();

      if (mobileNumber == null || mobileNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter mobile number for user ${i + 1}'),
          ),
        );
        return;
      }

      if (role == null || role.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select role for user ${i + 1}')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await StorageService.getString(
        AppStrings.authToken,
      );
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication token not found. Please login again.',
            ),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      final users = _userControllers.map((controller) {
        return UserToInventoryRequest(
          mobileNumber: controller['mobileNumber']!.text.trim(),
          role: controller['role']!.text.trim(),
        );
      }).toList();

      final request = AddUsersToInventoryRequest(users: users);

      await AuthAPI.addUsersToInventory(
        context: context,
        token: token,
        addUsersToInventoryRequest: request,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Users added successfully')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add users: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controllers in _userControllers) {
      controllers['mobileNumber']?.dispose();
      controllers['role']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.addUserToInventory,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Users to Inventory'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add multiple users to your inventory',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _userControllers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'User ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_userControllers.length > 1)
                                  IconButton(
                                    onPressed: () => _removeUserField(index),
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller:
                                  _userControllers[index]['mobileNumber'],
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number',
                                hintText: 'Enter mobile number',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _userControllers[index]['role']?.text,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _userControllers[index]['role']?.text = value;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _addUserField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another User'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Add Users'),
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
}
