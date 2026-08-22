class DimensionsModel {
  final double? weight;
  final double? height;
  final double? width;
  final double? depth;

  const DimensionsModel({
    this.weight,
    this.height,
    this.width,
    this.depth,
  });

  Map<String, dynamic> toJson() => {
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (width != null) 'width': width,
        if (depth != null) 'depth': depth,
      };

  factory DimensionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DimensionsModel();

    double? parseValue(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is Map<String, dynamic>) {
        final innerVal = val['value'];
        if (innerVal is num) return innerVal.toDouble();
        return double.tryParse(innerVal?.toString() ?? '');
      }
      return double.tryParse(val.toString());
    }

    return DimensionsModel(
      weight: parseValue(json['weight']),
      height: parseValue(json['height']),
      width: parseValue(json['width']),
      depth: parseValue(json['depth']),
    );
  }
}
