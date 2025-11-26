import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'models/resume_model.dart';

class HiveConfig {
  static Future<void> init() async {
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ResumeDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExperienceAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(EducationAdapter());
    }

    // Open boxes
    await Hive.openBox<ResumeData>('resumes');

    // Add some sample resumes if empty
    await _addSampleResumes();
  }

  static Future<void> _addSampleResumes() async {
    final resumesBox = Hive.box<ResumeData>('resumes');

    if (resumesBox.isEmpty) {
      // Sample Resume 1: Software Developer
      final sampleResume1 = ResumeData.create(
        fullName: 'Sarah Johnson',
        email: 'sarah.johnson@email.com',
        phone: '+1 (555) 123-4567',
        address: 'San Francisco, CA',
        summary:
            'Experienced Software Developer with 5+ years in mobile and web development. Specialized in Flutter, React Native, and Node.js. Proven track record of delivering high-quality applications and leading development teams.',
        skills: [
          'Flutter',
          'Dart',
          'React Native',
          'JavaScript',
          'Node.js',
          'Firebase',
          'REST APIs'
        ],
        experiences: [
          Experience(
            company: 'Tech Innovations Inc.',
            position: 'Senior Mobile Developer',
            duration: '2020 - Present',
            description:
                'Led development of cross-platform mobile applications using Flutter. Improved app performance by 40% and reduced crash rates by 60%.',
          ),
          Experience(
            company: 'Digital Solutions LLC',
            position: 'Junior Developer',
            duration: '2018 - 2020',
            description:
                'Developed and maintained web applications using React and Node.js. Collaborated with design team to implement responsive UI components.',
          ),
        ],
        education: [
          Education(
            institution: 'Stanford University',
            degree: 'Bachelor of Science in Computer Science',
            year: '2018',
          ),
        ],
      );

      // Sample Resume 2: Marketing Manager
      final sampleResume2 = ResumeData.create(
        fullName: 'Michael Chen',
        email: 'michael.chen@email.com',
        phone: '+1 (555) 987-6543',
        address: 'New York, NY',
        summary:
            'Strategic Marketing Manager with 8+ years of experience in digital marketing and brand management. Expert in SEO, content strategy, and data-driven campaign optimization.',
        skills: [
          'Digital Marketing',
          'SEO/SEM',
          'Google Analytics',
          'Content Strategy',
          'Social Media',
          'Project Management'
        ],
        experiences: [
          Experience(
            company: 'Global Brands Corp',
            position: 'Marketing Manager',
            duration: '2019 - Present',
            description:
                'Managed digital marketing campaigns with \$2M annual budget. Increased organic traffic by 150% and improved conversion rates by 45%.',
          ),
          Experience(
            company: 'StartUp Ventures',
            position: 'Digital Marketing Specialist',
            duration: '2016 - 2019',
            description:
                'Developed and executed social media strategies. Grew social media following from 10K to 500K+ across platforms.',
          ),
        ],
        education: [
          Education(
            institution: 'New York University',
            degree: 'MBA in Marketing',
            year: '2016',
          ),
          Education(
            institution: 'University of California',
            degree: 'Bachelor of Arts in Communications',
            year: '2014',
          ),
        ],
      );

      // Sample Resume 3: UX Designer
      final sampleResume3 = ResumeData.create(
        fullName: 'Emily Rodriguez',
        email: 'emily.rodriguez@email.com',
        phone: '+1 (555) 456-7890',
        address: 'Austin, TX',
        summary:
            'Creative UX/UI Designer with 6+ years of experience creating intuitive user interfaces for web and mobile applications. Strong background in user research, prototyping, and design systems.',
        skills: [
          'Figma',
          'Sketch',
          'Adobe Creative Suite',
          'User Research',
          'Wireframing',
          'Prototyping',
          'Design Systems'
        ],
        experiences: [
          Experience(
            company: 'Creative Design Studio',
            position: 'Lead UX Designer',
            duration: '2020 - Present',
            description:
                'Led design team in creating user-centered interfaces for enterprise clients. Improved user satisfaction scores by 35% through iterative design process.',
          ),
          Experience(
            company: 'Web Solutions Inc.',
            position: 'UI/UX Designer',
            duration: '2017 - 2020',
            description:
                'Designed mobile and web interfaces for various clients. Conducted user testing and implemented feedback into design iterations.',
          ),
        ],
        education: [
          Education(
            institution: 'Rhode Island School of Design',
            degree: 'Bachelor of Fine Arts in Graphic Design',
            year: '2017',
          ),
        ],
      );

      await resumesBox.put(sampleResume1.id, sampleResume1);
      await resumesBox.put(sampleResume2.id, sampleResume2);
      await resumesBox.put(sampleResume3.id, sampleResume3);
    }
  }
}
