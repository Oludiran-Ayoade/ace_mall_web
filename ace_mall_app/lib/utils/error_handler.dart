import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorHandler {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // Check if connected to mobile or wifi
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Verify actual internet access by attempting a lookup
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get user-friendly error message based on error type
  static Future<String> getErrorMessage(dynamic error) async {
    // Check internet connectivity first
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return "No internet connection. Please reconnect to continue.";
    }

    // Convert error to string for analysis
    final errorString = error.toString().toLowerCase();

    // Check for specific server errors
    if (errorString.contains('cloudinary')) {
      return "Image service error: ${_extractErrorMessage(error)}";
    }

    if (errorString.contains('render') || errorString.contains('onrender.com')) {
      return "Server error: ${_extractErrorMessage(error)}";
    }

    // Check for HTTP status code errors
    if (errorString.contains('404')) {
      return "Requested resource not found. Please try again.";
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return "Session expired. Please login again.";
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return "Access denied. You don't have permission for this action.";
    }

    if (errorString.contains('500') || errorString.contains('502') || 
        errorString.contains('503') || errorString.contains('504')) {
      return "Server is temporarily unavailable. Please try again later.";
    }

    if (errorString.contains('timeout')) {
      return "Connection timeout. Please check your connection and try again.";
    }

    if (errorString.contains('socket') || errorString.contains('connection refused')) {
      return "Cannot connect to server. Please try again.";
    }

    // Generic error message
    return "Something went wrong. Please try again.";
  }

  /// Extract meaningful error message from exception
  static String _extractErrorMessage(dynamic error) {
    if (error == null) return "Unknown error occurred";

    final errorString = error.toString();
    
    // Remove common exception prefixes
    String message = errorString
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '')
        .replaceAll('SocketException: ', '')
        .replaceAll('HttpException: ', '')
        .replaceAll('FormatException: ', '');

    // Capitalize first letter
    if (message.isNotEmpty) {
      message = message[0].toUpperCase() + message.substring(1);
    }

    return message;
  }

  /// Handle API response errors
  static String handleHttpError(int statusCode, String? responseBody) {
    switch (statusCode) {
      case 400:
        return _parseResponseError(responseBody) ?? "Invalid request. Please check your input.";
      case 401:
        final parsedError = _parseResponseError(responseBody);
        if (parsedError != null && parsedError.toLowerCase().contains('invalid')) {
          return parsedError;
        }
        return parsedError ?? "Session expired. Please login again.";
      case 403:
        return "Access denied. You don't have permission.";
      case 404:
        return "Requested resource not found.";
      case 422:
        return _parseResponseError(responseBody) ?? "Validation failed. Please check your input.";
      case 429:
        return "Too many requests. Please try again later.";
      case 500:
        return "Server error. Please try again later.";
      case 502:
        return "Server is temporarily unavailable. Please try again.";
      case 503:
        return "Service unavailable. Please try again later.";
      case 504:
        return "Connection timeout. Please try again.";
      default:
        if (statusCode >= 500) {
          return "Server error. Please try again later.";
        }
        return "Something went wrong. Please try again.";
    }
  }

  /// Parse error message from response body
  static String? _parseResponseError(String? responseBody) {
    if (responseBody == null || responseBody.isEmpty) return null;

    try {
      // Try to extract error message from common response formats
      if (responseBody.contains('"error"')) {
        final regex = RegExp(r'"error"\s*:\s*"([^"]+)"');
        final match = regex.firstMatch(responseBody);
        if (match != null && match.group(1) != null) {
          String error = match.group(1)!;
          
          // Handle backend validation errors
          if (error.contains("Field validation")) {
            if (error.contains("'Email'") && error.contains("'email'")) {
              return "Please enter a valid email address";
            } else if (error.contains("'Password'") && error.contains("'required'")) {
              return "Password is required";
            } else if (error.contains("'Email'") && error.contains("'required'")) {
              return "Email is required";
            } else if (error.toLowerCase().contains("validation")) {
              return "Please check your input and try again";
            }
          }
          
          return error;
        }
      }

      if (responseBody.contains('"message"')) {
        final regex = RegExp(r'"message"\s*:\s*"([^"]+)"');
        final match = regex.firstMatch(responseBody);
        if (match != null && match.group(1) != null) {
          String message = match.group(1)!;
          
          // Handle backend validation errors in message field
          if (message.contains("Field validation")) {
            if (message.contains("'Email'") && message.contains("'email'")) {
              return "Please enter a valid email address";
            } else if (message.contains("'Password'") && message.contains("'required'")) {
              return "Password is required";
            } else if (message.contains("'Email'") && message.contains("'required'")) {
              return "Email is required";
            }
          }
          
          return message;
        }
      }
    } catch (_) {
      // Ignore parsing errors
    }

    return null;
  }

  /// Show error in console for debugging (only in debug mode)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    assert(() {
      // ignore: avoid_print
      print('❌ Error in $context: $error');
      if (stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
      }
      return true;
    }());
  }
}
