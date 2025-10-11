import 'package:flutter/material.dart';
import '../api_calls/auth_apis.dart';
import '../models/auth/auth_response.dart';
import '../utils/shared_preferences.dart';
import '../constants/strings.dart';
import 'add_users_to_inventory_page.dart';

class InventoryUsersPage extends StatefulWidget {
  const InventoryUsersPage({super.key});

  @override
  State<InventoryUsersPage> createState() => _InventoryUsersPageState();
}

class _InventoryUsersPageState extends State<InventoryUsersPage> {
  List<UserWithRole> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInventoryUsers();
  }

  Future<void> _loadInventoryUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        Navigator.of(context).pop();
        return;
      }

      final inventoryUsers = await AuthAPI.getInventoryUsers(token: token);
      setState(() {
        users = inventoryUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _removeUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove User'),
          content: Text('Are you sure you want to remove $userName from inventory?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final String? token = await StorageService.getString(AppStrings.authToken);
        if (token == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication token not found. Please login again.')),
          );
          Navigator.of(context).pop();
          return;
        }

        await AuthAPI.removeUserFromInventory(token: token, userId: userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User removed successfully')),
          );
          _loadInventoryUsers(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove user: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Users'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading users',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadInventoryUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                user.firstName?.isNotEmpty == true
                                    ? user.firstName![0].toUpperCase()
                                    : user.mobileNumber[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.firstName?.isNotEmpty == true
                                  ? '${user.firstName} ${user.lastName ?? ''}'
                                  : user.mobileNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobile: ${user.mobileNumber}'),
                                Text('Role: ${user.role}'),
                                if (user.email?.isNotEmpty == true)
                                  Text('Email: ${user.email}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeUser(
                                user.id,
                                user.firstName?.isNotEmpty == true
                                    ? '${user.firstName} ${user.lastName ?? ''}'
                                    : user.mobileNumber,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddUsersToInventoryPage(),
            ),
          );
          
          if (result == true) {
            _loadInventoryUsers(); // Refresh the list
          }
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
