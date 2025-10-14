import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/screens/auth_page.dart';
import 'package:flutter/material.dart';

import '../api_calls/user_apis.dart';
import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import 'main_navigation.dart';

class UserUpdateDetailsPage extends StatefulWidget {
  final String id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicturePath;

  const UserUpdateDetailsPage({
    super.key,
    required this.id,
    required this.phoneNumber,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.profilePicturePath = '',
  });

  @override
  State<UserUpdateDetailsPage> createState() => _UserUpdateDetailsPageState();
}

class _UserUpdateDetailsPageState extends State<UserUpdateDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    if (widget.firstName.isNotEmpty) {
      _firstNameController.text = widget.firstName;
    }

    if (widget.lastName.isNotEmpty) {
      _lastNameController.text = widget.lastName;
    }

    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    }
  }

  Future<void> _updateUserDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final String? token = await StorageService.getString(AppStrings.authToken);

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token not found. Please login again.'),
        ),
      );

      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthPage()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();

    // TODO: add profile picture
    final updateUserRequest = UpdateUserRequest(
      id: widget.id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobileNumber: widget.phoneNumber,
      profilePicture: '',
    );

    try {
      await UserAPI.updateUserDetails(
        token: token,
        updateUserRequest: updateUserRequest,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Your Details'),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null; // Email is optional, so empty is okay
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _updateUserDetails,
                      child: const Text('Save Details'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
