import 'dart:io';

Future<List<int>?> readBytesFromPath(String path) async {
  final file = File(path);
  if (await file.exists()) return await file.readAsBytes();
  return null;
}
