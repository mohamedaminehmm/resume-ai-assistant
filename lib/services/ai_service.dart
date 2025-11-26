import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resume_model.dart';

class AIService {
  // Free AI API endpoints (no API key required for some)
  static const String huggingFaceUrl =
      'https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium';
  static const String deepAIUrl = 'https://api.deepai.org/api/text-generator';

  // Public method to generate local summary as fallback
  static String generateLocalSummary({
    required String fullName,
    required List<String> skills,
    required List<Experience> experiences,
    required List<Education> education,
  }) {
    final experienceText = experiences.isNotEmpty
        ? 'With ${experiences.length}+ years of experience as ${experiences.first.position}${experiences.length > 1 ? ' and other roles' : ''}, '
        : '';

    final educationText = education.isNotEmpty
        ? ' holding a ${education.first.degree}${education.length > 1 ? ' and other qualifications' : ''}.'
        : '.';

    final skillText = skills.isNotEmpty
        ? 'Proficient in ${skills.take(3).join(', ')}${skills.length > 3 ? ', and ${skills.length - 3} more skills' : ''}.'
        : '';

    return """
      $fullName is a dedicated professional $experienceText
      $skillText
      Demonstrated ability to deliver high-quality results and collaborate effectively in team environments$educationText
      Seeking to leverage expertise in a challenging new opportunity.
    """;
  }

  static Future<String> generateResumeSummary({
    required String fullName,
    required List<String> skills,
    required List<Experience> experiences,
    required List<Education> education,
  }) async {
    // Try multiple AI services with fallbacks
    try {
      // Try Hugging Face first
      final result =
          await _tryHuggingFace(fullName, skills, experiences, education);
      if (result.isNotEmpty) return result;
    } catch (e) {
      print('Hugging Face failed: $e');
    }

    try {
      // Try DeepAI as second option
      final result = await _tryDeepAI(fullName, skills, experiences, education);
      if (result.isNotEmpty) return result;
    } catch (e) {
      print('DeepAI failed: $e');
    }

    // Fallback to local generation
    return generateLocalSummary(
      fullName: fullName,
      skills: skills,
      experiences: experiences,
      education: education,
    );
  }

  static Future<String> _tryHuggingFace(
    String fullName,
    List<String> skills,
    List<Experience> experiences,
    List<Education> education,
  ) async {
    final prompt = """
      Create a professional resume summary for $fullName with these details:
      SKILLS: ${skills.join(', ')}
      EXPERIENCE: ${experiences.map((e) => '${e.position} at ${e.company} (${e.duration}) - ${e.description}').join(' | ')}
      EDUCATION: ${education.map((e) => '${e.degree} from ${e.institution} (${e.year})').join(' | ')}
      
      Generate a compelling 3-4 sentence professional summary highlighting key achievements and qualifications:
    """;

    try {
      final response = await http.post(
        Uri.parse(huggingFaceUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 250,
            'temperature': 0.8,
            'do_sample': true,
            'return_full_text': false,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          String generatedText = data[0]['generated_text'] ?? '';
          // Clean up the response
          generatedText = generatedText.replaceAll(prompt, '').trim();
          if (generatedText.isNotEmpty) return generatedText;
        } else if (data['generated_text'] != null) {
          return data['generated_text']
              .toString()
              .replaceAll(prompt, '')
              .trim();
        }
      } else if (response.statusCode == 503) {
        // Model is loading, wait and retry
        await Future.delayed(const Duration(seconds: 5));
        return _tryHuggingFace(fullName, skills, experiences, education);
      }
      throw Exception('Hugging Face API returned ${response.statusCode}');
    } catch (e) {
      throw Exception('Hugging Face error: $e');
    }
  }

  static Future<String> _tryDeepAI(
    String fullName,
    List<String> skills,
    List<Experience> experiences,
    List<Education> education,
  ) async {
    const apiKey =
        'quickstart-QUdJIGlzIGNvbWluZy4uLi4K'; // DeepAI quickstart key (free but limited)

    final prompt = """
      Write a professional resume summary for $fullName:
      Skills: ${skills.join(', ')}
      Experience: ${experiences.map((e) => '${e.position} at ${e.company}').join(', ')}
      Education: ${education.map((e) => '${e.degree} from ${e.institution}').join(', ')}
      
      Create a compelling 3-4 sentence professional summary:
    """;

    try {
      final response = await http.post(
        Uri.parse(deepAIUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Api-Key': apiKey,
        },
        body: 'text=$prompt',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['output'] ??
            generateLocalSummary(
              fullName: fullName,
              skills: skills,
              experiences: experiences,
              education: education,
            );
      } else {
        throw Exception('DeepAI API returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('DeepAI error: $e');
    }
  }
}
