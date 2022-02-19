// To parse this JSON data, do
//
//     final fileMetadata = fileMetadataFromMap(jsonString);

import 'dart:convert';

class FileMetadata {
  FileMetadata({
    this.name,
    this.type,
    this.size,
  });

  String? name;
  String? type;
  int? size;

  FileMetadata copyWith({
    String? name,
    String? type,
    int? size,
  }) =>
      FileMetadata(
        name: name,
        type: type,
        size: size,
      );

  factory FileMetadata.fromJson(String str) =>
      FileMetadata.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FileMetadata.fromMap(Map<String, dynamic> json) => FileMetadata(
        name: json["name"],
        type: json["type"],
        size: json["size"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "type": type,
        "size": size,
      };
}
