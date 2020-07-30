import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'taggerUrl': Platform.environment['TAGGER_BASE_URL']
  };

  const filename = 'lib/env.dart';
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