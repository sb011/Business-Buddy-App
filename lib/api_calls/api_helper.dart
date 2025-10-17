import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screens/auth_page.dart';
import '../screens/unauthorized_page.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_snackbar.dart';

class ApiHelper {
  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  static Future<bool> validateResponse(http.Response response, String message, BuildContext context) async {
    if (isSuccess(response.statusCode)) {
      return true;
    } else if (response.statusCode == 401) {
      await StorageService.clearAll();
      if (context.mounted) {
        CustomSnackBar.showWarning(
          context,
          "Session expired. Please login again.",
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false,
            );
          }
        });
      }
      return false;
    } else if (response.statusCode == 403) {
      if (context.mounted) {
        CustomSnackBar.showWarning(
          context,
          "You are not authorized to perform this action.",
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
            );
          }
        });
      }
      return false;
    } else if (isClientError(response.statusCode)) {
      CustomSnackBar.showError(context, message);
      return false;
    } else if (isServerError(response.statusCode)) {
      CustomSnackBar.showError(context, message);
      return false;
    } else {
      CustomSnackBar.showError(context, "Unknown error occurred.");
      return false;
    }
  }
}