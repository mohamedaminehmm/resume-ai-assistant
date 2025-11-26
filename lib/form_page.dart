import 'package:flutter/material.dart';
import 'models/resume_model.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'resume_preview_page.dart';

class FormPage extends StatefulWidget {
  final ResumeData? existingResume;

  const FormPage({super.key, this.existingResume});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  List<String> skills = [];
  List<Experience> experiences = [];
  List<Education> education = [];

  bool _isGenerating = false;
  String _aiStatus = '';

  // Experience form controllers
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _expDescriptionController =
      TextEditingController();

  // Education form controllers
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingResume();
  }

  void _loadExistingResume() {
    if (widget.existingResume != null) {
      final resume = widget.existingResume!;
      _fullNameController.text = resume.fullName;
      _emailController.text = resume.email;
      _phoneController.text = resume.phone;
      _addressController.text = resume.address;
      skills = List.from(resume.skills);
      experiences = resume.experiences
          .map((e) => Experience(
                company: e.company,
                position: e.position,
                duration: e.duration,
                description: e.description,
              ))
          .toList();
      education = resume.education
          .map((e) => Education(
                institution: e.institution,
                degree: e.degree,
                year: e.year,
              ))
          .toList();
    }
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
  }

  void _addExperience() {
    if (_companyController.text.isNotEmpty &&
        _positionController.text.isNotEmpty) {
      setState(() {
        experiences.add(Experience(
          company: _companyController.text.trim(),
          position: _positionController.text.trim(),
          duration: _durationController.text.trim(),
          description: _expDescriptionController.text.trim(),
        ));
        _clearExperienceFields();
      });
    }
  }

  void _clearExperienceFields() {
    _companyController.clear();
    _positionController.clear();
    _durationController.clear();
    _expDescriptionController.clear();
  }

  void _addEducation() {
    if (_institutionController.text.isNotEmpty &&
        _degreeController.text.isNotEmpty) {
      setState(() {
        education.add(Education(
          institution: _institutionController.text.trim(),
          degree: _degreeController.text.trim(),
          year: _yearController.text.trim(),
        ));
        _clearEducationFields();
      });
    }
  }

  void _clearEducationFields() {
    _institutionController.clear();
    _degreeController.clear();
    _yearController.clear();
  }

  Future<void> _saveResumeToDatabase(String summary) async {
    final resumeData = ResumeData.create(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      summary: summary,
      skills: skills,
      experiences: experiences,
      education: education,
    );

    await DatabaseService().saveResume(resumeData);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume saved successfully!')),
    );
  }

  Future<void> _updateResumeInDatabase(String summary) async {
    if (widget.existingResume != null) {
      final updatedResume = widget.existingResume!.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        summary: summary,
        skills: skills,
        experiences: experiences,
        education: education,
      );

      await DatabaseService().saveResume(updatedResume);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume updated successfully!')),
      );
    }
  }

  Future<void> _generateResume() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _aiStatus = 'Connecting to AI service...';
    });

    try {
      setState(() {
        _aiStatus = 'Generating professional summary...';
      });

      final summary = await AIService.generateResumeSummary(
        fullName: _fullNameController.text,
        skills: skills,
        experiences: experiences,
        education: education,
      );

      // Save or update resume in database
      if (widget.existingResume != null) {
        await _updateResumeInDatabase(summary);
      } else {
        await _saveResumeToDatabase(summary);
      }

      final resumeData = ResumeData.create(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        summary: summary,
        skills: skills,
        experiences: experiences,
        education: education,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumePreviewPage(resumeData: resumeData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'AI Service Temporarily Unavailable. Using template summary.'),
          backgroundColor: Colors.orange,
        ),
      );

      // Continue with local fallback
      final localSummary = AIService.generateLocalSummary(
        fullName: _fullNameController.text,
        skills: skills,
        experiences: experiences,
        education: education,
      );

      // Save or update resume in database
      if (widget.existingResume != null) {
        await _updateResumeInDatabase(localSummary);
      } else {
        await _saveResumeToDatabase(localSummary);
      }

      final resumeData = ResumeData.create(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        summary: localSummary,
        skills: skills,
        experiences: experiences,
        education: education,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumePreviewPage(resumeData: resumeData),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
        _aiStatus = '';
      });
    }
  }

  void _clearAll() {
    setState(() {
      _fullNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _skillController.clear();
      skills.clear();
      experiences.clear();
      education.clear();
      _clearExperienceFields();
      _clearEducationFields();
    });
  }

  void _saveWithoutAI() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill')),
      );
      return;
    }

    final localSummary = AIService.generateLocalSummary(
      fullName: _fullNameController.text,
      skills: skills,
      experiences: experiences,
      education: education,
    );

    final resumeData = ResumeData.create(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      summary: localSummary,
      skills: skills,
      experiences: experiences,
      education: education,
    );

    // Save or update resume in database
    if (widget.existingResume != null) {
      _updateResumeInDatabase(localSummary);
    } else {
      _saveResumeToDatabase(localSummary);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumePreviewPage(resumeData: resumeData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingResume != null
            ? 'Edit Resume'
            : 'Create New Resume'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
          if (widget.existingResume == null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveWithoutAI,
              tooltip: 'Save Without AI',
            ),
        ],
      ),
      body: _isGenerating ? _buildLoadingScreen() : _buildForm(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            _aiStatus,
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          const Text(
            'This may take a few seconds...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 20),
            _buildSkillsSection(),
            const SizedBox(height: 20),
            _buildExperienceSection(),
            const SizedBox(height: 20),
            _buildEducationSection(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills *',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Add Skill',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Flutter, JavaScript, Project Management',
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add_circle),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    iconSize: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (skills.isNotEmpty) ...[
              const Text(
                'Your Skills:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  return Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSkill(index),
                    backgroundColor: Colors.blue[50],
                  );
                }).toList(),
              ),
            ] else ...[
              const Text(
                'No skills added yet',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Work Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 2020-2023)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expDescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add),
                label: const Text('Add Experience'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (experiences.isNotEmpty) ...[
              const Text(
                'Added Experiences:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...experiences.asMap().entries.map((entry) {
                final index = entry.key;
                final exp = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.grey[50],
                  child: ListTile(
                    title: Text(
                      exp.position,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp.company),
                        Text(exp.duration,
                            style: const TextStyle(fontSize: 12)),
                        if (exp.description.isNotEmpty)
                          Text(
                            exp.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          experiences.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Education',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _degreeController,
              decoration: const InputDecoration(
                labelText: 'Degree',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emoji_events),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addEducation,
                icon: const Icon(Icons.add),
                label: const Text('Add Education'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (education.isNotEmpty) ...[
              const Text(
                'Added Education:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...education.asMap().entries.map((entry) {
                final index = entry.key;
                final edu = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.grey[50],
                  child: ListTile(
                    title: Text(
                      edu.degree,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu.institution),
                        Text(edu.year, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          education.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateResume,
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              widget.existingResume != null
                  ? 'Update with AI'
                  : 'Generate AI Resume',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.existingResume == null)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _saveWithoutAI,
              icon: const Icon(Icons.save),
              label: const Text(
                'Save Without AI',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          widget.existingResume != null
              ? 'AI will update your professional summary'
              : 'AI will generate a professional summary based on your information',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _skillController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _durationController.dispose();
    _expDescriptionController.dispose();
    _institutionController.dispose();
    _degreeController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
