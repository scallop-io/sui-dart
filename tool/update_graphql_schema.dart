import 'dart:io';

const _schemaUrl =
    'https://raw.githubusercontent.com/MystenLabs/sui/main/'
    'crates/sui-indexer-alt-graphql/schema.graphql';
const _outputPath = 'lib/graphql/schema.graphql';
const _sourceHeader =
    '# Source: MystenLabs/sui '
    'crates/sui-indexer-alt-graphql/schema.graphql\n';

Future<void> main() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(_schemaUrl));
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Schema download failed with HTTP ${response.statusCode}',
        uri: Uri.parse(_schemaUrl),
      );
    }
    final contents = await response.transform(SystemEncoding().decoder).join();
    final normalized = contents.replaceAll(
      RegExp(r'[ \t]+$', multiLine: true),
      '',
    );
    await File(_outputPath).writeAsString('$_sourceHeader$normalized');
    stdout.writeln('Updated $_outputPath');
  } finally {
    client.close();
  }
}
