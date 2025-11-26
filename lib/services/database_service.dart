import 'package:hive/hive.dart';
import '../models/resume_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Box<ResumeData> get resumesBox => Hive.box<ResumeData>('resumes');

  // Get all resumes sorted by updated date
  List<ResumeData> getAllResumes() {
    final resumes = resumesBox.values.toList();
    resumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return resumes;
  }

  // Get resume by ID
  ResumeData? getResume(String id) {
    return resumesBox.get(id);
  }

  // Save or update resume
  Future<void> saveResume(ResumeData resume) async {
    await resumesBox.put(resume.id, resume);
  }

  // Delete resume
  Future<void> deleteResume(String id) async {
    await resumesBox.delete(id);
  }

  // Check if resume exists
  bool resumeExists(String id) {
    return resumesBox.containsKey(id);
  }

  // Get resumes count
  int getResumesCount() {
    return resumesBox.length;
  }

  // Search resumes by name or skills
  List<ResumeData> searchResumes(String query) {
    final allResumes = getAllResumes();
    if (query.isEmpty) return allResumes;

    final lowercaseQuery = query.toLowerCase();
    return allResumes.where((resume) {
      return resume.fullName.toLowerCase().contains(lowercaseQuery) ||
          resume.skills
              .any((skill) => skill.toLowerCase().contains(lowercaseQuery)) ||
          resume.summary.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
