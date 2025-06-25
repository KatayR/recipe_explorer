import '../constants/app_constants.dart';

/// Validation result container
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const ValidationResult({required this.isValid, this.errorMessage});
  
  factory ValidationResult.valid() => const ValidationResult(isValid: true);
  factory ValidationResult.invalid(String message) => ValidationResult(isValid: false, errorMessage: message);
}

/// Utility class for input validation
class InputValidator {
  
  /// Validates search query input
  static ValidationResult validateSearchQuery(String query) {
    final trimmedQuery = query.trim();
    
    // Check if empty
    if (trimmedQuery.isEmpty) {
      return ValidationResult.invalid('Search query cannot be empty');
    }
    
    // Check minimum length
    if (trimmedQuery.length < AppConstants.minSearchQueryLength) {
      return ValidationResult.invalid('Search query must be at least ${AppConstants.minSearchQueryLength} characters long');
    }
    
    // Check maximum length
    if (trimmedQuery.length > AppConstants.maxSearchQueryLength) {
      return ValidationResult.invalid('Search query must be less than ${AppConstants.maxSearchQueryLength} characters');
    }
    
    // Check for valid characters using regex
    final RegExp pattern = RegExp(AppConstants.searchQueryPattern);
    if (!pattern.hasMatch(trimmedQuery)) {
      return ValidationResult.invalid('Search query contains invalid characters. Only letters, numbers, spaces, and basic punctuation are allowed');
    }
    
    // Check for blocked terms (case insensitive)
    final lowerQuery = trimmedQuery.toLowerCase();
    for (final blockedTerm in AppConstants.blockedSearchTerms) {
      if (lowerQuery.contains(blockedTerm.toLowerCase())) {
        return ValidationResult.invalid('Search query contains inappropriate content');
      }
    }
    
    // Check if query is not just whitespace or special characters
    if (RegExp(r'^[\s\-\.,&]+$').hasMatch(trimmedQuery)) {
      return ValidationResult.invalid('Search query must contain at least one letter or number');
    }
    
    return ValidationResult.valid();
  }
  
  /// Sanitizes search query by removing potentially harmful content
  static String sanitizeSearchQuery(String query) {
    return query
        .trim()
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('\\', '')
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }
  
  /// Validates that at least one search filter is selected
  static ValidationResult validateSearchFilters(bool byName, bool byIngredient) {
    if (!byName && !byIngredient) {
      return ValidationResult.invalid('Please select at least one search filter (by name or by ingredient)');
    }
    return ValidationResult.valid();
  }
}