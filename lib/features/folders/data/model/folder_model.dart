import 'dart:convert';

import 'package:greate_note_app/features/folders/domain/entity/folder.dart';

class FolderModel extends Folder {
  FolderModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.color})
      : super();
// Converts a FolderModel into a Map for storing in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt':createdAt.toIso8601String(),
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
        id: map['id'],
        name: map['name'],
        createdAt:DateTime.parse(map['createdAt']),
        color: map['color']);
  }
}
