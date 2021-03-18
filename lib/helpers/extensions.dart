extension StringExtension on String {
  String capitalise() => '${this[0].toUpperCase()}${substring(1)}';
}
