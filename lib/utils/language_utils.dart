const Map<String, String> _languageNames = {
  'english': 'English',
  'spanish': 'Spanish',
  'french': 'French',
  'german': 'German',
  'italian': 'Italian',
  'portuguese': 'Portuguese',
  'russian': 'Russian',
  'japanese': 'Japanese',
  'korean': 'Korean',
  'chinese': 'Chinese',
  'hindi': 'Hindi',
  'arabic': 'Arabic',
};

String getLanguageDisplayName(String languageCode) {
  return _languageNames[languageCode.toLowerCase()] ??
      languageCode.substring(0, 1).toUpperCase() +
          languageCode.substring(1).toLowerCase();
}
