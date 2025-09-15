class CccdModel {
  final String id;
  final String urlFront;
  final String urlBackSide;

  CccdModel(this.id, this.urlFront, this.urlBackSide);

  // JSON → Object
  factory CccdModel.fromJson(Map<String, dynamic> json) {
    return CccdModel(
      json['id'] as String,
      json['urlFront'] as String,
      json['urlBackSide'] as String,
    );
  }

  // Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urlFront': urlFront,
      'urlBackSide': urlBackSide,
    };
  }
}
