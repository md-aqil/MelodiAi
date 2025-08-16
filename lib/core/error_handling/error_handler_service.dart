import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../app_export.dart';
import './app_error.dart';

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  /// Handles and categorizes errors, returning appropriate AppError
  Future<AppError> handleError(dynamic error, {StackTrace? stackTrace}) async {
    // Log error for debugging
    if (kDebugMode) {
      print('ErrorHandlerService: Handling error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }

    // Check network connectivity first
    final connectivityResult = await _checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return AppError.networkUnavailable();
    }

    // Handle specific error types
    if (error is AppError) {
      return error;
    }

    // Handle network-related errors
    if (_isNetworkError(error)) {
      return _handleNetworkError(error);
    }

    // Handle API-related errors
    if (_isApiError(error)) {
      return _handleApiError(error);
    }

    // Handle validation errors
    if (_isValidationError(error)) {
      return _handleValidationError(error);
    }

    // Default to unknown error
    return AppError.fromException(error, stackTrace: stackTrace);
  }

  /// Validates music generation parameters and returns appropriate error if invalid
  AppError? validateMusicGenerationParams({
    required String description,
    required String genre,
    String? title,
    String? negativeTags,
    double? styleWeight,
    double? weirdness,
    double? audioWeight,
  }) {
    // Check description
    if (description.trim().isEmpty) {
      return AppError.missingDescription();
    }

    if (description.trim().length < 10) {
      return AppError.descriptionTooShort();
    }

    if (description.length > 500) {
      return AppError.descriptionTooLong();
    }

    // Check genre
    if (genre.trim().isEmpty) {
      return AppError.invalidGenre();
    }

    // Check title length if provided
    if (title != null && title.length > 100) {
      return AppError(
        type: AppErrorType.invalidParameters,
        message: 'Title too long',
        details: 'Please keep the title under 100 characters.',
      );
    }

    // Check negative tags length if provided
    if (negativeTags != null && negativeTags.length > 200) {
      return AppError(
        type: AppErrorType.invalidParameters,
        message: 'Negative tags too long',
        details: 'Please keep negative tags under 200 characters.',
      );
    }

    // Check parameter ranges
    if (styleWeight != null && (styleWeight < 0.0 || styleWeight > 1.0)) {
      return AppError(
        type: AppErrorType.invalidParameters,
        message: 'Invalid style weight',
        details: 'Style weight must be between 0 and 1.',
      );
    }

    if (weirdness != null && (weirdness < 0.0 || weirdness > 1.0)) {
      return AppError(
        type: AppErrorType.invalidParameters,
        message: 'Invalid weirdness value',
        details: 'Weirdness must be between 0 and 1.',
      );
    }

    if (audioWeight != null && (audioWeight < 0.0 || audioWeight > 1.0)) {
      return AppError(
        type: AppErrorType.invalidParameters,
        message: 'Invalid audio weight',
        details: 'Audio weight must be between 0 and 1.',
      );
    }

    return null; // No validation errors
  }

  /// Simulates API call and returns appropriate errors for demonstration
  Future<AppError?> simulateApiCall({
    String? taskId,
    bool forceFail = false,
  }) async {
    await Future.delayed(Duration(seconds: 2));

    if (forceFail) {
      return AppError.generationFailed();
    }

    // Simulate random errors for demonstration
    final random = DateTime.now().millisecond % 100;

    if (random < 5) {
      return AppError.networkTimeout();
    } else if (random < 8) {
      return AppError.apiRateLimitExceeded();
    } else if (random < 10) {
      return AppError.apiServiceUnavailable();
    } else if (random < 12) {
      return AppError.generationQueueFull();
    }

    return null; // Success
  }

  Future<ConnectivityResult> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('unreachable');
  }

  bool _isApiError(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('429') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('api');
  }

  bool _isValidationError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required') ||
        errorString.contains('missing');
  }

  AppError _handleNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return AppError.networkTimeout();
    }

    return AppError.networkUnavailable();
  }

  AppError _handleApiError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('401')) {
      return AppError.authenticationFailed();
    }

    if (errorString.contains('403')) {
      return AppError.apiKeyInvalid();
    }

    if (errorString.contains('429')) {
      return AppError.apiRateLimitExceeded();
    }

    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return AppError.serverUnavailable();
    }

    return AppError.apiServiceUnavailable();
  }

  AppError _handleValidationError(dynamic error) {
    return AppError.invalidParameters();
  }
}