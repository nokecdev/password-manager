import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwordmanager/Models/vault_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

final FlutterSecureStorage _storage = const FlutterSecureStorage();
final encoder = JsonEncoder();

String getStringFromBytes(ByteData data) {
  final buffer = data.buffer;
  var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return utf8.decode(list);
}

ByteData stringoTBytes(String data) {
  final password = utf8.encode(data).buffer.asByteData();
  return password;
}

Future<void> addNewPassword(
  String domain,
  String username,
  String password,
) async {
  var key = Uuid();

  var value = VaultEntry(
    id: key,
    title: domain,
    username: username,
    password: stringoTBytes(password),
    createdAt: DateTime.now(),
    updatedAt: null,
    device: null,
  );

  await _storage.write(key: key.toString(), value: encoder.convert(value));
}

Future<void> addEntry(VaultEntry entry) async {
  await _storage.write(
    key: entry.id.toString(),
    value: jsonEncode(entry.toJson()),
  );
}

Future<List<VaultEntry>> getAllEntry() async {
  final all = await _storage.readAll(); // Map<String, String>

  return all.values.map((value) {
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    return VaultEntry.fromJson(decoded);
  }).toList();
}

Future<String?> getPassword(String uuid) async {
  return await _storage.read(key: uuid);
}

Future<void> updatePassword(String username, String password) async {
  var value = await _storage.read(key: username);
  if (value == null) return;

  await _storage.write(key: username, value: password);
}

Future<void> deletePassword(String username) async {
  await _storage.delete(key: username);
}
