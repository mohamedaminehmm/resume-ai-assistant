import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'form_page.dart';
import 'resume_preview_page.dart';
import 'models/resume_model.dart';
import 'services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormPage()),
              );
            },
            tooltip: 'Create New Resume',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search resumes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          // Resumes List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<ResumeData>('resumes').listenable(),
              builder: (context, Box<ResumeData> box, widget) {
                final resumes =
                    _databaseService.searchResumes(_searchController.text);

                if (resumes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No resumes yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first resume!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: resumes.length,
                  itemBuilder: (context, index) {
                    final resume = resumes[index];
                    return _buildResumeCard(resume);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPage()),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResumeCard(ResumeData resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description,
            color: Colors.blue.shade800,
            size: 30,
          ),
        ),
        title: Text(
          resume.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (resume.skills.isNotEmpty)
              Text(
                resume.skills.take(3).join(' • '),
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              'Updated: ${_formatDate(resume.updatedAt)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, resume),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResumePreviewPage(resumeData: resume),
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(String action, ResumeData resume) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResumePreviewPage(resumeData: resume),
          ),
        );
        break;
      case 'edit':
        _navigateToEdit(resume);
        break;
      case 'duplicate':
        _duplicateResume(resume);
        break;
      case 'delete':
        _deleteResume(resume);
        break;
    }
  }

  void _navigateToEdit(ResumeData resume) {
    // For editing, we'll navigate to form page with existing data
    // You might want to create an EditFormPage for better editing experience
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumePreviewPage(resumeData: resume),
      ),
    );
  }

  void _duplicateResume(ResumeData resume) {
    final duplicatedResume = ResumeData.create(
      fullName: '${resume.fullName} (Copy)',
      email: resume.email,
      phone: resume.phone,
      address: resume.address,
      summary: resume.summary,
      skills: List.from(resume.skills),
      experiences: resume.experiences.map((e) => e.copyWith()).toList(),
      education: resume.education.map((e) => e.copyWith()).toList(),
    );

    _databaseService.saveResume(duplicatedResume);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume duplicated successfully!')),
    );
  }

  void _deleteResume(ResumeData resume) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text(
            'Are you sure you want to delete ${resume.fullName}\'s resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _databaseService.deleteResume(resume.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resume deleted successfully!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
