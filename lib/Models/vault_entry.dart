import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class VaultEntry {
  final Uuid id;
  final String title;
  final String username;
  final ByteData password;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DeviceMeta? device;

  VaultEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    this.device,
  });

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      title: json['title'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      device: json['device'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'username': username,
    'password': password,
  };
}

class DeviceMeta {
  final Uuid deviceId;
  final String publicKey;
  final List pairedDevices;

  DeviceMeta(this.deviceId, this.publicKey, this.pairedDevices);
}
