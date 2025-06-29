double? parseFlexibleDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.startsWith('.')
      ? '0$value'
      : value.startsWith('-.')
          ? value.replaceFirst('-.', '-0.')
          : value;
  return double.tryParse(normalized);
}
