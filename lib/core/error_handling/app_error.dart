enum AppErrorType {
  // Network errors
  networkTimeout,
  networkUnavailable,
  serverUnavailable,

  // API errors
  apiKeyInvalid,
  apiKeyMissing,
  apiRateLimitExceeded,
  apiQuotaExceeded,
  apiServiceUnavailable,

  // Validation errors
  invalidParameters,
  missingDescription,
  invalidGenre,
  descriptionTooShort,
  descriptionTooLong,

  // Generation errors
  generationFailed,
  generationTimeout,
  generationCancelled,
  generationQueueFull,

  // Storage errors
  storageFull,
  storagePermissionDenied,
  storageUnavailable,

  // Authentication errors
  authenticationFailed,
  authenticationExpired,
  authenticationMissing,

  // Unknown errors
  unknown,
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? details;
  final String? technicalMessage;
  final int? statusCode;
  final bool isRetryable;
  final Map<String, dynamic>? metadata;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    this.technicalMessage,
    this.statusCode,
    this.isRetryable = false,
    this.metadata,
  });

  factory AppError.networkTimeout() => const AppError(
        type: AppErrorType.networkTimeout,
        message: 'Connection timeout',
        details:
            'The request took too long to complete. Please check your internet connection and try again.',
        isRetryable: true,
      );

  factory AppError.networkUnavailable() => const AppError(
        type: AppErrorType.networkUnavailable,
        message: 'No internet connection',
        details: 'Please check your internet connection and try again.',
        isRetryable: true,
      );

  factory AppError.serverUnavailable() => const AppError(
        type: AppErrorType.serverUnavailable,
        message: 'Service temporarily unavailable',
        details:
            'The music generation service is temporarily unavailable. Please try again in a few minutes.',
        isRetryable: true,
      );

  factory AppError.apiKeyInvalid() => const AppError(
        type: AppErrorType.apiKeyInvalid,
        message: 'Invalid API key',
        details:
            'The API key is invalid or has been revoked. Please contact support.',
        isRetryable: false,
      );

  factory AppError.apiKeyMissing() => const AppError(
        type: AppErrorType.apiKeyMissing,
        message: 'API key missing',
        details: 'No API key found. Please check your configuration.',
        isRetryable: false,
      );

  factory AppError.apiRateLimitExceeded() => const AppError(
        type: AppErrorType.apiRateLimitExceeded,
        message: 'Rate limit exceeded',
        details:
            'Too many requests. Please wait a few minutes before trying again.',
        isRetryable: true,
      );

  factory AppError.apiQuotaExceeded() => const AppError(
        type: AppErrorType.apiQuotaExceeded,
        message: 'Generation quota exceeded',
        details:
            'You have reached your monthly generation limit. Upgrade your plan to continue.',
        isRetryable: false,
      );

  factory AppError.apiServiceUnavailable() => const AppError(
        type: AppErrorType.apiServiceUnavailable,
        message: 'AI service unavailable',
        details:
            'The AI music generation service is currently unavailable. Please try again later.',
        isRetryable: true,
      );

  factory AppError.invalidParameters() => const AppError(
        type: AppErrorType.invalidParameters,
        message: 'Invalid parameters',
        details:
            'Some parameters are invalid. Please check your inputs and try again.',
        isRetryable: false,
      );

  factory AppError.missingDescription() => const AppError(
        type: AppErrorType.missingDescription,
        message: 'Description required',
        details: 'Please provide a description for your music to generate.',
        isRetryable: false,
      );

  factory AppError.invalidGenre() => const AppError(
        type: AppErrorType.invalidGenre,
        message: 'Genre selection required',
        details: 'Please select a genre for your music.',
        isRetryable: false,
      );

  factory AppError.descriptionTooShort() => const AppError(
        type: AppErrorType.descriptionTooShort,
        message: 'Description too short',
        details:
            'Please provide a more detailed description (at least 10 characters).',
        isRetryable: false,
      );

  factory AppError.descriptionTooLong() => const AppError(
        type: AppErrorType.descriptionTooLong,
        message: 'Description too long',
        details: 'Please shorten your description to 500 characters or less.',
        isRetryable: false,
      );

  factory AppError.generationFailed() => const AppError(
        type: AppErrorType.generationFailed,
        message: 'Generation failed',
        details:
            'The music generation process failed unexpectedly. Please try again with different parameters.',
        isRetryable: true,
      );

  factory AppError.generationTimeout() => const AppError(
        type: AppErrorType.generationTimeout,
        message: 'Generation timeout',
        details:
            'The generation process took too long to complete. Please try again.',
        isRetryable: true,
      );

  factory AppError.generationCancelled() => const AppError(
        type: AppErrorType.generationCancelled,
        message: 'Generation cancelled',
        details: 'The generation was cancelled by the user.',
        isRetryable: true,
      );

  factory AppError.generationQueueFull() => const AppError(
        type: AppErrorType.generationQueueFull,
        message: 'Queue is full',
        details:
            'The generation queue is currently full. Please try again in a few minutes.',
        isRetryable: true,
      );

  factory AppError.storageFull() => const AppError(
        type: AppErrorType.storageFull,
        message: 'Storage full',
        details:
            'Not enough storage space available. Please free up some space and try again.',
        isRetryable: false,
      );

  factory AppError.storagePermissionDenied() => const AppError(
        type: AppErrorType.storagePermissionDenied,
        message: 'Storage permission denied',
        details:
            'Permission to access storage was denied. Please enable storage permissions in your device settings.',
        isRetryable: false,
      );

  factory AppError.storageUnavailable() => const AppError(
        type: AppErrorType.storageUnavailable,
        message: 'Storage unavailable',
        details:
            'Device storage is temporarily unavailable. Please try again later.',
        isRetryable: true,
      );

  factory AppError.authenticationFailed() => const AppError(
        type: AppErrorType.authenticationFailed,
        message: 'Authentication failed',
        details: 'Unable to authenticate your request. Please log in again.',
        isRetryable: false,
      );

  factory AppError.authenticationExpired() => const AppError(
        type: AppErrorType.authenticationExpired,
        message: 'Session expired',
        details: 'Your session has expired. Please log in again to continue.',
        isRetryable: false,
      );

  factory AppError.authenticationMissing() => const AppError(
        type: AppErrorType.authenticationMissing,
        message: 'Authentication required',
        details: 'Please log in to use this feature.',
        isRetryable: false,
      );

  factory AppError.unknown({String? technicalMessage, int? statusCode}) =>
      AppError(
        type: AppErrorType.unknown,
        message: 'Unexpected error occurred',
        details:
            'An unexpected error occurred. Please try again or contact support if the problem persists.',
        technicalMessage: technicalMessage,
        statusCode: statusCode,
        isRetryable: true,
      );

  factory AppError.fromException(dynamic exception, {StackTrace? stackTrace}) {
    if (exception is AppError) {
      return exception;
    }

    // Handle specific exception types
    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('NetworkException')) {
      return AppError.networkUnavailable();
    }

    if (exception.toString().contains('TimeoutException')) {
      return AppError.networkTimeout();
    }

    if (exception.toString().contains('401')) {
      return AppError.authenticationFailed();
    }

    if (exception.toString().contains('403')) {
      return AppError.apiKeyInvalid();
    }

    if (exception.toString().contains('429')) {
      return AppError.apiRateLimitExceeded();
    }

    if (exception.toString().contains('500') ||
        exception.toString().contains('502') ||
        exception.toString().contains('503')) {
      return AppError.serverUnavailable();
    }

    return AppError.unknown(
      technicalMessage: exception.toString(),
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details)';
  }
}
