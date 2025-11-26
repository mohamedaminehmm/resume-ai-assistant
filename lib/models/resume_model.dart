import 'package:hive/hive.dart';

part 'resume_model.g.dart';

@HiveType(typeId: 0)
class ResumeData extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String fullName;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String phone;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late String summary;

  @HiveField(6)
  late List<String> skills;

  @HiveField(7)
  late List<Experience> experiences;

  @HiveField(8)
  late List<Education> education;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  late DateTime updatedAt;

  ResumeData();

  ResumeData.create({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    required this.skills,
    required this.experiences,
    required this.education,
  }) {
    id = DateTime.now().millisecondsSinceEpoch.toString();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // Copy with method for updates
  ResumeData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? summary,
    List<String>? skills,
    List<Experience>? experiences,
    List<Education>? education,
  }) {
    return ResumeData.create(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'summary': summary,
      'skills': skills,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 1)
class Experience {
  @HiveField(0)
  final String company;

  @HiveField(1)
  final String position;

  @HiveField(2)
  final String duration;

  @HiveField(3)
  final String description;

  Experience({
    required this.company,
    required this.position,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'duration': duration,
      'description': description,
    };
  }

  Experience copyWith({
    String? company,
    String? position,
    String? duration,
    String? description,
  }) {
    return Experience(
      company: company ?? this.company,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      description: description ?? this.description,
    );
  }
}

@HiveType(typeId: 2)
class Education {
  @HiveField(0)
  final String institution;

  @HiveField(1)
  final String degree;

  @HiveField(2)
  final String year;

  Education({
    required this.institution,
    required this.degree,
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'year': year,
    };
  }

  Education copyWith({
    String? institution,
    String? degree,
    String? year,
  }) {
    return Education(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      year: year ?? this.year,
    );
  }
}
