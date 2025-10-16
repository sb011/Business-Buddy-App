import 'package:flutter/material.dart';
import '../utils/shared_preferences.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../screens/unauthorized_page.dart';

class PermissionWrapper extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionWrapper({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService.getString(AppStrings.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final role = snapshot.data;
        if (role == null) {
          // No role found, redirect to unauthorized page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
            );
          });
          return const SizedBox.shrink();
        }
        
        final hasPermission = AppPermissions.hasPermission(role, permission);
        
        if (hasPermission) {
          return child;
        } else {
          // No permission, redirect to unauthorized page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
            );
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class RoleWrapper extends StatelessWidget {
  final String requiredRole;
  final Widget child;
  final Widget? fallback;

  const RoleWrapper({
    super.key,
    required this.requiredRole,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService.getString(AppStrings.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final role = snapshot.data;
        if (role == null || role != requiredRole) {
          // Wrong role or no role, redirect to unauthorized page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
            );
          });
          return const SizedBox.shrink();
        }
        
        return child;
      },
    );
  }
}

class OwnerOnlyWrapper extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const OwnerOnlyWrapper({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService.getString(AppStrings.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final role = snapshot.data;
        if (role != 'Owner') {
          // Not owner, redirect to unauthorized page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
            );
          });
          return const SizedBox.shrink();
        }
        
        return child;
      },
    );
  }
}
