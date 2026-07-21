import 'dart:typed_data';

Future<void> downloadPdfBytes(Uint8List bytes, String filename) async {
  // En no-web no debe llamarse (lo protegemos con kIsWeb).
  throw UnsupportedError('downloadPdfBytes solo está disponible en Web.');
}
