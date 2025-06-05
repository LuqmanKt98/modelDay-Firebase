class IndustryContact {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String name;
  final String? jobTitle;
  final String? company;
  final String? instagram;
  final String? mobile;
  final String? email;
  final String? city;
  final String? country;
  final String? notes;

  IndustryContact({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.name,
    this.jobTitle,
    this.company,
    this.instagram,
    this.mobile,
    this.email,
    this.city,
    this.country,
    this.notes,
  });

  factory IndustryContact.fromJson(Map<String, dynamic> json) {
    return IndustryContact(
      id: json['id'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      createdBy: json['created_by'],
      isSample: json['is_sample'] ?? false,
      name: json['name'] ?? '',
      jobTitle: json['job_title'],
      company: json['company'],
      instagram: json['instagram'],
      mobile: json['mobile'],
      email: json['email'],
      city: json['city'],
      country: json['country'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'name': name,
      'job_title': jobTitle,
      'company': company,
      'instagram': instagram,
      'mobile': mobile,
      'email': email,
      'city': city,
      'country': country,
      'notes': notes,
    };
  }

  IndustryContact copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? name,
    String? jobTitle,
    String? company,
    String? instagram,
    String? mobile,
    String? email,
    String? city,
    String? country,
    String? notes,
  }) {
    return IndustryContact(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      instagram: instagram ?? this.instagram,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
    );
  }
}
