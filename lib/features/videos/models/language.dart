import 'package:freezed_annotation/freezed_annotation.dart';

part 'language.freezed.dart';
part 'language.g.dart';

/// Represents a supported language for translation
@freezed
class Language with _$Language {
  const factory Language({
    /// The language code (e.g., 'es', 'pt')
    required String code,

    /// The display name of the language (e.g., 'Spanish', 'Portuguese')
    required String name,

    /// Optional emoji flag for the language
    String? flag,
  }) = _Language;

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}

/// Enum representing all supported language codes
enum LanguageCode {
  @JsonValue('es')
  spanish('es'),

  @JsonValue('pt')
  portuguese('pt'),

  @JsonValue('zh')
  chinese('zh'),

  @JsonValue('de')
  german('de'),

  @JsonValue('ja')
  japanese('ja');

  final String code;
  const LanguageCode(this.code);
}

/// List of all supported languages with their metadata
final List<Language> supportedLanguages = [
  const Language(
    code: 'es',
    name: 'Spanish',
    flag: '🇪🇸',
  ),
  const Language(
    code: 'pt',
    name: 'Portuguese',
    flag: '🇵🇹',
  ),
  const Language(
    code: 'zh',
    name: 'Chinese',
    flag: '🇨🇳',
  ),
  const Language(
    code: 'de',
    name: 'German',
    flag: '🇩🇪',
  ),
  const Language(
    code: 'ja',
    name: 'Japanese',
    flag: '🇯🇵',
  ),
];

/// Extension methods for LanguageCode
extension LanguageCodeX on LanguageCode {
  /// Get the Language object for this language code
  Language get language => supportedLanguages.firstWhere(
        (l) => l.code == code,
        orElse: () => throw Exception('Invalid language code: $code'),
      );
}

/// Extension methods for String
extension LanguageCodeStringX on String {
  /// Convert a string to a LanguageCode if valid
  LanguageCode? toLanguageCode() {
    return LanguageCode.values.cast<LanguageCode?>().firstWhere(
          (l) => l?.code == this,
          orElse: () => null,
        );
  }
}
