/// Base exception for all data layer errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => '[$runtimeType] $message${code != null ? ' (Code: $code)' : ''}';
}

// ==================== NETWORK EXCEPTIONS ====================

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
  }) : super(code: 'NETWORK_ERROR');
}

class TimeoutException extends AppException {
  final Duration? timeout;

  const TimeoutException({
    this.timeout,
    super.message = 'Request timed out',
  }) : super(code: 'TIMEOUT');
}

class ConnectionRefusedException extends AppException {
  const ConnectionRefusedException({
    super.message = 'Connection refused by server',
  }) : super(code: 'CONNECTION_REFUSED');
}

class HostUnreachableException extends AppException {
  const HostUnreachableException({
    super.message = 'Server is unreachable',
  }) : super(code: 'HOST_UNREACHABLE');
}

// ==================== SERVER EXCEPTIONS ====================

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    String? code,
  }) : super(code: code ?? 'SERVER_ERROR');
}

class BadRequestException extends ServerException {
  final Map<String, dynamic>? errors;

  const BadRequestException({
    super.message = 'Invalid request',
    this.errors,
  }) : super(statusCode: 400, code: 'BAD_REQUEST');
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    super.message = 'Authentication required',
  }) : super(statusCode: 401, code: 'UNAUTHORIZED');
}

class ForbiddenException extends ServerException {
  const ForbiddenException({
    super.message = 'Access denied',
  }) : super(statusCode: 403, code: 'FORBIDDEN');
}

class NotFoundException extends ServerException {
  final String? resource;

  const NotFoundException({
    this.resource,
    super.message = 'Resource not found',
  }) : super(statusCode: 404, code: 'NOT_FOUND');
}

class ConflictException extends ServerException {
  const ConflictException({
    super.message = 'Resource conflict',
  }) : super(statusCode: 409, code: 'CONFLICT');
}

class UnprocessableEntityException extends ServerException {
  final Map<String, dynamic>? validationErrors;

  const UnprocessableEntityException({
    super.message = 'Validation failed',
    this.validationErrors,
  }) : super(statusCode: 422, code: 'VALIDATION_ERROR');
}

class TooManyRequestsException extends ServerException {
  final DateTime? retryAfter;

  const TooManyRequestsException({
    super.message = 'Rate limit exceeded',
    this.retryAfter,
  }) : super(statusCode: 429, code: 'RATE_LIMITED');
}

class ServerInternalException extends ServerException {
  const ServerInternalException({
    super.message = 'Internal server error',
  }) : super(statusCode: 500, code: 'INTERNAL_ERROR');
}

class ServiceUnavailableException extends ServerException {
  const ServiceUnavailableException({
    super.message = 'Service temporarily unavailable',
  }) : super(statusCode: 503, code: 'SERVICE_UNAVAILABLE');
}

class GatewayTimeoutException extends ServerException {
  const GatewayTimeoutException({
    super.message = 'Gateway timeout',
  }) : super(statusCode: 504, code: 'GATEWAY_TIMEOUT');
}

// ==================== CACHE/LOCAL STORAGE EXCEPTIONS ====================

class CacheException extends AppException {
  const CacheException({
    required super.message,
  }) : super(code: 'CACHE_ERROR');
}

class CacheMissException extends CacheException {
  final String? key;

  const CacheMissException({
    this.key,
    super.message = 'Cache miss',
  }) : super();
}

class CacheWriteException extends CacheException {
  const CacheWriteException({
    super.message = 'Failed to write to cache',
  }) : super();
}

class CacheExpiredException extends CacheException {
  final DateTime? expiredAt;

  const CacheExpiredException({
    this.expiredAt,
    super.message = 'Cache data expired',
  }) : super();
}

class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
  }) : super(code: 'DATABASE_ERROR');
}

class DatabaseConnectionException extends DatabaseException {
  const DatabaseConnectionException({
    super.message = 'Database connection failed',
  }) : super();
}

class UniqueConstraintException extends DatabaseException {
  final String? field;

  const UniqueConstraintException({
    this.field,
    super.message = 'Duplicate entry',
  });
}

// ==================== DATA/PARSING EXCEPTIONS ====================

class ParsingException extends AppException {
  final dynamic rawData;
  final Type? expectedType;

  const ParsingException({
    required super.message,
    this.rawData,
    this.expectedType,
  }) : super(code: 'PARSING_ERROR');
}

class JsonParsingException extends ParsingException {
  const JsonParsingException({
    super.message = 'Failed to parse JSON',
    super.rawData,
  });
}

class SerializationException extends AppException {
  const SerializationException({
    required super.message,
  }) : super(code: 'SERIALIZATION_ERROR');
}

class InvalidDataException extends AppException {
  final String? field;
  final dynamic value;

  const InvalidDataException({
    required super.message,
    this.field,
    this.value,
  }) : super(code: 'INVALID_DATA');
}

class UnexpectedResponseException extends AppException {
  final dynamic response;

  const UnexpectedResponseException({
    required super.message,
    required this.response,
  }) : super(code: 'UNEXPECTED_RESPONSE');
}

// ==================== PLATFORM/DEVICE EXCEPTIONS ====================

class PlatformException extends AppException {
  const PlatformException({
    required super.message,
  }) : super(code: 'PLATFORM_ERROR');
}

class PermissionDeniedException extends PlatformException {
  const PermissionDeniedException({
    super.message = 'Permission denied',
  }) : super();
}

class CameraException extends PlatformException {
  const CameraException({
    required super.message,
  });
}

class StorageException extends PlatformException {
  const StorageException({
    required super.message,
  });
}

class BiometricAuthException extends PlatformException {
  const BiometricAuthException({
    required super.message,
  });
}

// ==================== EXTERNAL SERVICE EXCEPTIONS ====================

class ExternalServiceException extends AppException {
  final String? serviceName;

  const ExternalServiceException({
    required super.message,
    this.serviceName,
  }) : super(code: 'EXTERNAL_SERVICE_ERROR');
}

class PaymentException extends ExternalServiceException {
  const PaymentException({
    required super.message,
  }) : super(serviceName: 'Payment Gateway');
}

class FirebaseException extends ExternalServiceException {
  const FirebaseException({
    required super.message,
  }) : super(serviceName: 'Firebase');
}

class PushNotificationException extends ExternalServiceException {
  const PushNotificationException({
    required super.message,
  }) : super(serviceName: 'Push Notification Service');
}

// ==================== CANCELLATION/USER ACTION ====================

class RequestCancelledException extends AppException {
  const RequestCancelledException({
    super.message = 'Request was cancelled',
  }) : super(code: 'CANCELLED');
}

class UserAbortException extends AppException {
  const UserAbortException({
    super.message = 'User aborted operation',
  }) : super(code: 'USER_ABORT');
}

// ==================== BUSINESS LOGIC EXCEPTIONS ====================

class BusinessRuleException extends AppException {
  final String? ruleId;

  const BusinessRuleException({
    required super.message,
    this.ruleId,
  }) : super(code: 'BUSINESS_RULE_VIOLATION');
}

class InsufficientFundsException extends BusinessRuleException {
  const InsufficientFundsException({
    super.message = 'Insufficient funds',
  }) : super(ruleId: 'INSUFFICIENT_FUNDS');
}

class AccountSuspendedException extends BusinessRuleException {
  const AccountSuspendedException({
    super.message = 'Account is suspended',
  }) : super(ruleId: 'ACCOUNT_SUSPENDED');
}

class DuplicateEntryException extends BusinessRuleException {
  final String? field;

  const DuplicateEntryException({
    this.field,
    super.message = 'Duplicate entry found',
  }) : super(ruleId: 'DUPLICATE_ENTRY');
}

class StateTransitionException extends BusinessRuleException {
  final String? fromState;
  final String? toState;

  const StateTransitionException({
    required super.message,
    this.fromState,
    this.toState,
  }) : super(ruleId: 'INVALID_STATE_TRANSITION');
}
