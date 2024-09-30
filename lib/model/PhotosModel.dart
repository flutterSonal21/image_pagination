

class PhotosModel {
  String? id;
  String? createdAt;
  Map<String, dynamic>? urls;

  PhotosModel({this.id, this.createdAt, this.urls});

  PhotosModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    urls = json['urls'] != null ? Map<String, dynamic>.from(json['urls']) : null;
  }

  // Optionally, you can add a method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'urls': urls,
    };
  }
}
