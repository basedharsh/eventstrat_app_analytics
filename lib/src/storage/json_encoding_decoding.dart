import 'dart:convert';
import 'dart:io';

String encodeAndCompress(List<Map<String, dynamic>> data) {
  final jsonString = jsonEncode(data);
  final compressed = gzip.encode(utf8.encode(jsonString));
  final base64String = base64Encode(compressed);
  return base64String;
}

List<Map<String, dynamic>> decodeAndDecompress(String base64String) {
  final decodedJson = jsonDecode(
    utf8.decode(gzip.decode(base64Decode(base64String))),
  );
  return (decodedJson as List).map((e) => e as Map<String, dynamic>).toList();
}
