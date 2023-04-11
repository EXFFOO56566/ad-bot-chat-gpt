
class ImageModel {
  ImageModel({
    required this.created,
    required this.data,
  });

  int created;
  List<Datum> data;

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    created: json["created"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "created": created,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    required this.url,
  });

  dynamic url;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    url: json["url"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}