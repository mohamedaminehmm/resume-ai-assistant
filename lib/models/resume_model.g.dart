// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeDataAdapter extends TypeAdapter<ResumeData> {
  @override
  final int typeId = 0;

  @override
  ResumeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeData()
      ..id = fields[0] as String
      ..fullName = fields[1] as String
      ..email = fields[2] as String
      ..phone = fields[3] as String
      ..address = fields[4] as String
      ..summary = fields[5] as String
      ..skills = (fields[6] as List).cast<String>()
      ..experiences = (fields[7] as List).cast<Experience>()
      ..education = (fields[8] as List).cast<Education>()
      ..createdAt = fields[9] as DateTime
      ..updatedAt = fields[10] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ResumeData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.skills)
      ..writeByte(7)
      ..write(obj.experiences)
      ..writeByte(8)
      ..write(obj.education)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperienceAdapter extends TypeAdapter<Experience> {
  @override
  final int typeId = 1;

  @override
  Experience read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Experience(
      company: fields[0] as String,
      position: fields[1] as String,
      duration: fields[2] as String,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Experience obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.company)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EducationAdapter extends TypeAdapter<Education> {
  @override
  final int typeId = 2;

  @override
  Education read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Education(
      institution: fields[0] as String,
      degree: fields[1] as String,
      year: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Education obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.institution)
      ..writeByte(1)
      ..write(obj.degree)
      ..writeByte(2)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EducationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
