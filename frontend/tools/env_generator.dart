import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'taggerUrl':
        Platform.environment['TAGGER_BASE_URL'] ?? 'http://0.0.0.0:8080/api'
  };

  const filename = 'lib/generated_env.dart';
  final contents = config.entries.fold(<String>[
    '// ignore_for_file: public_member_api_docs, prefer_single_quotes\n'
  ], (previousValue, element) {
    return [
      ...previousValue,
      'const ${element.key} = ${json.encode(element.value)};'
    ];
  });

  File(filename).writeAsString(contents.join('\n'));
}
