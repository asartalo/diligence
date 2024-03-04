part of 'diligence_theme.dart';

class DiligenceTextTheme {
  final TextTheme textTheme;

  DiligenceTextTheme({required this.textTheme});

  TextStyle get dataTitle {
    return textTheme.bodyLarge!.copyWith(
      color: colors.grayText,
      letterSpacing: 1,
    );
  }
}
