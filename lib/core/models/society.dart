class Society {
  final String id;
  final String name;
  final Map<String, dynamic>? config;

  Society({
    required this.id,
    required this.name,
    this.config,
  });

  factory Society.fromJson(Map<String, dynamic> json) {
    return Society(
      id: json['id'] as String,
      name: json['name'] as String,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'config': config,
    };
  }
}

class Unit {
  final String id;
  final String societyId;
  final String? block;
  final String flatNo;

  Unit({
    required this.id,
    required this.societyId,
    this.block,
    required this.flatNo,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      block: json['block'] as String?,
      flatNo: json['flat_no'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'society_id': societyId,
      'block': block,
      'flat_no': flatNo,
    };
  }

  @override
  String toString() => block != null ? '$block-$flatNo' : flatNo;
}
