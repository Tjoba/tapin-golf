import 'package:flutter/material.dart';
import '../models/golf_course.dart';
import '../services/golf_course_service.dart';

class GolfCoursesScreen extends StatefulWidget {
  const GolfCoursesScreen({super.key});

  @override
  State<GolfCoursesScreen> createState() => _GolfCoursesScreenState();
}

class _GolfCoursesScreenState extends State<GolfCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GolfCourseService _courseService = GolfCourseService.instance;
  
  List<GolfCourse> _courses = [];
  List<GolfCourse> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _courseService.getAllCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _filteredCourses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCourses = _courses;
      } else {
        _filteredCourses = _courses.where((course) {
          final nameMatch = course.name.toLowerCase().contains(query.toLowerCase());
          final cityMatch = course.city?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return nameMatch || cityMatch;
        }).toList();
      }
    });
  }

  void _showCourseDetails(GolfCourse course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CourseDetailsSheet(course: course),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Golf Courses',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search courses or cities...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF1ca9c9)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Results Counter
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredCourses.length} courses found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1ca9c9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Course List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1ca9c9),
                    ),
                  )
                : _filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.golf_course,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No courses available'
                                  : 'No courses found for "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return _CourseCard(
                            course: course,
                            onTap: () => _showCourseDetails(course),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final GolfCourse course;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              if (course.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (course.hasContactInfo) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (course.phone != null) ...[
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (course.email != null) ...[
                      Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (course.primaryWebsite != null) ...[
                      Icon(
                        Icons.web,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      'Contact info available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseDetailsSheet extends StatelessWidget {
  final GolfCourse course;

  const _CourseDetailsSheet({required this.course});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address
                      if (course.address.isNotEmpty) ...[
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Address',
                          value: course.address,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Coordinates
                      _DetailRow(
                        icon: Icons.map,
                        label: 'Coordinates',
                        value: '${course.lat.toStringAsFixed(6)}, ${course.lon.toStringAsFixed(6)}',
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Contact Information
                      if (course.phone != null) ...[
                        _DetailRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: course.phone!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      if (course.email != null) ...[
                        _DetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: course.email!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      if (course.primaryWebsite != null) ...[
                        _DetailRow(
                          icon: Icons.web,
                          label: 'Website',
                          value: course.primaryWebsite!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Course ID
                      _DetailRow(
                        icon: Icons.tag,
                        label: 'Course ID',
                        value: course.id.toString(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement navigation to course
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Navigation feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Get Directions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1ca9c9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement add to favorites
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Favorites feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Add to Favorites'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1ca9c9),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: const BorderSide(color: Color(0xFF1ca9c9)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF1ca9c9),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}