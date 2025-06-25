/// Utility helper functions.
///
/// parseFlexibleDouble converts string representations of a number
/// that may omit the leading zero before a decimal (e.g. `.5`) into
/// a double value.
///
/// If the string is null or cannot be parsed, null is returned.

double? parseFlexibleDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.startsWith('.')
      ? '0$value'
      : value.startsWith('-.')
          ? value.replaceFirst('-.', '-0.')
          : value;
  return double.tryParse(normalized);
}
