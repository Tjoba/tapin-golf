import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Disabled temporarily
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/golf_courses_screen.dart';
import 'services/location_service.dart';
import 'services/golf_course_service.dart';
import 'models/golf_course.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TapinGolfApp());
}

class TapinGolfApp extends StatelessWidget {
  const TapinGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapin Golf',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

// Authentication Wrapper - decides whether to show login or main app
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

// Full-screen Login Page with Blue Clouded Gradient
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthentication() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final result = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (result == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } else {
        if (_firstNameController.text.trim().isEmpty || 
            _lastNameController.text.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter both first and last name')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final result = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );
        if (result == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create account. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              Color(0xFFCCE8F0), // Light blue-teal
              Color(0xFF66C9DD), // Medium blue-teal
              Color(0xFF33AEC6), // Medium-dark blue-teal
              Color(0xFF0093AF), // Blue-teal #0093AF
            ],
            stops: [0.0, 0.2, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.top - 
                     MediaQuery.of(context).padding.bottom,
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Welcome Text
                  Text(
                    _isLogin ? 'Tap in Golf' : 'Join Tapin Golf',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to continue' : 'Create your account',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  Column(
                    children: [
                      if (!_isLogin) ...[
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      
                      // Sign In/Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuthentication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1ca9c9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF1ca9c9))
                              : Text(
                                  _isLogin ? 'Sign In' : 'Create Account',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Toggle between login and register
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin 
                              ? 'Don\'t have an account? Create one'
                              : 'Already have an account? Sign in',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40), // Bottom spacing
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    PlayScreen(),
    BookScreen(),
    YouScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_golf),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0093AF),
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      try {
        _userProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to get the appropriate profile image for Home screen
  ImageProvider? _getHomeProfileImageProvider() {
    // For Tobias Hanner, use the temporary asset image
    if (_userProfile?.firstName == 'Tobias' && _userProfile?.lastName == 'Hanner') {
      return const AssetImage('assets/profile/temp-tobias.jpeg');
    }
    
    // If there's a photo URL from Firebase Storage, use it
    if (_userProfile?.photoUrl != null && _userProfile!.photoUrl!.isNotEmpty) {
      return NetworkImage(_userProfile!.photoUrl!);
    }
    
    // No image available
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      body: Stack(
        children: [
          Column(
            children: [
              // Course image taking up 60% of screen height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                child: Image.asset(
                  'assets/courses/random/golf_course_hero.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              // Remaining content area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(
                    child: Text(
                      'Home Screen',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Profile picture overlay with handicap in top left
          if (!_isLoading && _userProfile != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16, // Account for status bar
              left: 16,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      key: ValueKey(_userProfile!.photoUrl ?? 'tobias-home'),
                      radius: 13.5, // 27px diameter
                      backgroundColor: Colors.white,
                      backgroundImage: _getHomeProfileImageProvider(),
                      child: _getHomeProfileImageProvider() == null
                          ? Text(
                              _userProfile!.firstName.isNotEmpty && _userProfile!.lastName.isNotEmpty
                                  ? '${_userProfile!.firstName[0].toUpperCase()}${_userProfile!.lastName[0].toUpperCase()}'
                                  : _userProfile!.firstName.isNotEmpty
                                      ? _userProfile!.firstName[0].toUpperCase()
                                      : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 31, // Match profile image height with border
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    alignment: Alignment.center, // Center the text vertically
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6), // 60% transparency
                      borderRadius: BorderRadius.circular(20), // More rounded corners
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_userProfile!.handicap.toStringAsFixed(1)} HCP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Play Screen
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final LocationService _locationService = LocationService.instance;
  final GolfCourseService _courseService = GolfCourseService.instance;
  
  List<GolfCourse> _nearbyCourses = [];
  bool _isLoadingCourses = true;
  bool _locationError = false;
  Position? _userLocation;
  GolfCourse? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _loadNearbyCourses();
  }

  Future<void> _loadNearbyCourses() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingCourses = true;
      _locationError = false;
    });

    try {
      // Try to get user's location first
      Position? location = await _locationService.getCurrentLocation();
      
      // If location is not available or we're in a simulator, use Stockholm mock location
      if (location == null || 
          (location.latitude.toStringAsFixed(4) == '37.7858' && location.longitude.toStringAsFixed(4) == '-122.4064')) {
        location = _locationService.getMockLocation();
        setState(() {
          _locationError = true; // Show that we're using mock location
        });
      } else {
        setState(() {
          _locationError = false;
        });
      }
      
      if (mounted) {
        setState(() {
          _userLocation = location;
        });

        // Get nearby courses within 6km
        final courses = await _courseService.getCoursesNearby(
          location.latitude, 
          location.longitude, 
          6.0, // 6km radius
        );

        // Sort courses by distance (closest first)
        courses.sort((a, b) {
          final distanceA = _locationService.calculateDistance(
            location!.latitude,
            location.longitude,
            a.lat,
            a.lon,
          );
          final distanceB = _locationService.calculateDistance(
            location.latitude,
            location.longitude,
            b.lat,
            b.lon,
          );
          return distanceA.compareTo(distanceB);
        });

        if (mounted) {
          setState(() {
            _nearbyCourses = courses.take(10).toList(); // Limit to 10 closest courses
            _isLoadingCourses = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
          _locationError = true;
        });
      }
    }
  }

  void _showCourseSelectionModal(GolfCourse course) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                course.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (course.city != null)
                Text(
                  course.city!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Holes section
              const Text(
                'Available holes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Display holes or fallback message
              if (course.holes != null && course.holes!.isNotEmpty)
                ...course.holes!.map((hole) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.golf_course,
                        size: 16,
                        color: Color(0xFF1ca9c9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hole,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ))
              else
                Text(
                  'Course information available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCourse = course;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ca9c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Select Course',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      appBar: AppBar(
        title: const Text('Play'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF1ca9c9),
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GolfCoursesScreen(),
                ),
              );
            },
            tooltip: 'Search Golf Courses',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Course Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select course',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_locationError)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Demo Location',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Filter chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1ca9c9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Horizontal Course List
            SizedBox(
              height: 120,
              child: _isLoadingCourses
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1ca9c9),
                      ),
                    )
                  : _nearbyCourses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No courses found nearby',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _nearbyCourses.length,
                          itemBuilder: (context, index) {
                            final course = _nearbyCourses[index];
                            final distance = _userLocation != null
                                ? _locationService.calculateDistance(
                                    _userLocation!.latitude,
                                    _userLocation!.longitude,
                                    course.lat,
                                    course.lon,
                                  )
                                : 0.0;
                            
                            return _NearbyGolfCourseCard(
                              course: course,
                              distance: distance,
                              isSelected: _selectedCourse?.id == course.id,
                              onTap: () {
                                _showCourseSelectionModal(course);
                              },
                            );
                          },
                        ),
            ),
            
            const SizedBox(height: 24),
            
            // Add Player Section
            const Text(
              'Add Player',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Invite friends to join your round',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // Add Player Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Implement add player functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add player feature coming soon!')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1ca9c9).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Color(0xFF1ca9c9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Invite Players',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add friends to play together and track scores',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyGolfCourseCard extends StatelessWidget {
  final GolfCourse course;
  final double distance;
  final VoidCallback onTap;
  final bool isSelected;

  const _NearbyGolfCourseCard({
    required this.course,
    required this.distance,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth * 0.8, // 80% of screen width
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0, // Remove shadow
        color: Colors.white, // White background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Course Logo (if available)
                if (course.logo != null)
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        course.logo!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to default icon if logo fails to load
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.golf_course,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                
                // Left side - Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Course Name
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // City and Distance in same row
                      Row(
                        children: [
                          // Distance
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (course.city != null) ...[
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                course.city!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Hole information
                      if (course.holeInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Selected course: ${course.holeInfo!}',
                          style: const TextStyle(
                            color: Color(0xFF1ca9c9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Right side - Checkmark icon when selected
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.check_circle,
                      color: const Color(0xFF1ca9c9),
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Book Screen
class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final GolfCourseService _golfCourseService = GolfCourseService.instance;
  
  DateTime selectedDate = DateTime.now();
  late ScrollController _scrollController;
  int daysToShow = 60; // Start with 2 months
  List<String> players = []; // List to store player names
  
  // Favorites filter state
  UserProfile? _userProfile;
  List<GolfCourse> _favoriteCourses = [];
  bool _showFavoritesOnly = true; // Default to showing favorites
  List<GolfCourse> _recentSearches = []; // Add recent searches list
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Add scroll listener to load more dates when near the end
    _scrollController.addListener(_onScroll);
    
    // Load user profile and favorites
    _loadUserAndFavorites();
    
    // Load recent searches (for demo - you can replace with actual search history)
    _loadRecentSearches();
    
    // No auto-scroll - start at the beginning showing today's date
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Check if user is near the end of the list
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.8; // Load more when 80% scrolled
      
      if (currentScroll >= threshold) {
        // Load next month (approximately 30 more days)
        setState(() {
          daysToShow += 30;
        });
      }
    }
  }
  
  Future<void> _loadUserAndFavorites() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    try {
      setState(() {
        // _isLoadingFavorites = true; // Removed loading state
      });
      
      // Load user profile
      _userProfile = await _firestoreService.getUserProfile(user.uid);
      
      if (_userProfile != null && _userProfile!.favoriteCourses.isNotEmpty) {
        // Load all courses
        final allCourses = await _golfCourseService.loadCourses();
        
        // Filter to get only favorite courses
        _favoriteCourses = allCourses
            .where((course) => _userProfile!.favoriteCourses.contains(course.id))
            .toList();
      }
      
      setState(() {
        // _isLoadingFavorites = false; // Removed loading state
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        // _isLoadingFavorites = false; // Removed loading state
      });
    }
  }
  
  Future<void> _loadRecentSearches() async {
    // For demo purposes, load a few sample courses as recent searches
    // In a real app, you would load this from shared preferences or a database
    try {
      final courses = await _golfCourseService.getAllCourses();
      
      // Sample recent searches - you can replace this with actual search history logic
      final sampleRecentSearches = courses.where((course) => 
        course.name.contains('Bro') || 
        course.name.contains('Wermdo') || 
        course.name.contains('Halmstad')
      ).take(3).toList();
      
      setState(() {
        _recentSearches = sampleRecentSearches;
      });
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }
  
  void _showPlayerSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Players',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${players.length}/4',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search players...',
                            prefixIcon: Icon(Icons.search, color: Color(0xFF1ca9c9)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Current players section
                      if (players.isNotEmpty) ...[
                        Text(
                          'Selected Players',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Selected players list
                        ...players.asMap().entries.map((entry) {
                          final index = entry.key;
                          final player = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ca9c9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF1ca9c9).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF1ca9c9),
                                  radius: 16,
                                  child: Text(
                                    player[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    player,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      players.removeAt(index);
                                    });
                                    setModalState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Add new player button
                      if (players.length < 4) ...[
                        Text(
                          'Add New Player',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close modal first
                            _showAddPlayerDialog();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1ca9c9),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF1ca9c9).withOpacity(0.05),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: Color(0xFF1ca9c9),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Add Player Manually',
                                  style: TextStyle(
                                    color: Color(0xFF1ca9c9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Done button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ca9c9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            players.isEmpty 
                                ? 'Close' 
                                : 'Done (${players.length} player${players.length == 1 ? '' : 's'})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  void _showAddPlayerDialog() {
    final TextEditingController playerController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Player'),
          content: TextField(
            controller: playerController,
            decoration: const InputDecoration(
              hintText: 'Enter player name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final playerName = playerController.text.trim();
                if (playerName.isNotEmpty && players.length < 4) {
                  setState(() {
                    players.add(playerName);
                  });
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ca9c9),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130), // Increased height to prevent overflow
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            padding: const EdgeInsets.only(top: kToolbarHeight + 4), // Added extra padding
            child: Column(
              children: [
                // Title and Add Players row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Book Tee Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      // Add Players button
                      InkWell(
                        onTap: _showPlayerSelectionModal,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                players.isEmpty ? Icons.person_add : Icons.group,
                                color: const Color(0xFF1ca9c9),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                players.isEmpty 
                                    ? 'Add players'
                                    : 'Players: ${players.length}',
                                style: const TextStyle(
                                  color: Color(0xFF1ca9c9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Separator line
                Container(
                  height: 1,
                  color: const Color(0xB2EFEEEE), // Same as background color
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                
                // Horizontal Date Picker
                Expanded( // Use Expanded to prevent overflow
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added vertical padding
                    itemCount: daysToShow, // Dynamic number of days
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month &&
                          date.year == selectedDate.year;
                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;
                      
                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF1ca9c9)
                                  : isToday 
                                      ? const Color(0xFF1ca9c9).withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isToday && !isSelected
                                  ? Border.all(color: const Color(0xFF1ca9c9), width: 1)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Day name
                                Text(
                                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected 
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                
                                // Day number
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? Colors.white
                                        : isToday 
                                            ? const Color(0xFF1ca9c9)
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                
                                // Month
                                Text(
                                  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Course filter section
            if (_userProfile != null && (_favoriteCourses.isNotEmpty || _recentSearches.isNotEmpty)) ...[
              // Filter chips outside the card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Favorites filter chip
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showFavoritesOnly = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showFavoritesOnly
                              ? const Color(0xFF1ca9c9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: _showFavoritesOnly
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Favorites',
                              style: TextStyle(
                                color: _showFavoritesOnly
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Recent searches filter chip
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showFavoritesOnly = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_showFavoritesOnly
                              ? const Color(0xFF1ca9c9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              color: !_showFavoritesOnly
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recent Searches',
                              style: TextStyle(
                                color: !_showFavoritesOnly
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Search icon
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GolfCoursesScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF1ca9c9),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            )], // Close Padding widget properly
            
            const SizedBox(height: 16),
            
            // Show favorite courses or recent searches as separate cards
            ...(_showFavoritesOnly 
                ? (_favoriteCourses.isNotEmpty ? _favoriteCourses : <GolfCourse>[])
                : (_recentSearches.isNotEmpty ? _recentSearches : <GolfCourse>[])
            ).map((course) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            // Course logo
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1ca9c9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: course.logo != null && course.logo!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: course.logo!.startsWith('http')
                                          ? Image.network(
                                              course.logo!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.golf_course,
                                                  color: Color(0xFF1ca9c9),
                                                  size: 24,
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xFF1ca9c9),
                                                    strokeWidth: 2,
                                                  ),
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              course.logo!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.golf_course,
                                                  color: Color(0xFF1ca9c9),
                                                  size: 24,
                                                );
                                              },
                                            ),
                                    )
                                  : const Icon(
                                      Icons.golf_course,
                                      color: Color(0xFF1ca9c9),
                                      size: 24,
                                    ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Course info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (course.city != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      course.city!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Favorite indicator
                            const Icon(
                              Icons.favorite,
                              color: Color(0xFF1ca9c9),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// You Screen
class YouScreen extends StatefulWidget {
  const YouScreen({super.key});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      try {
        _userProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      appBar: AppBar(
        title: const Text('You'),
        backgroundColor: Colors.white,
        actions: [
          if (_currentUser != null) ...[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      userProfile: _userProfile,
                      onProfileUpdated: _loadUserData,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Please sign in to view your profile',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : _userProfile == null
                  ? const Center(child: Text('Error loading profile'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Additional profile actions can be added here in the future
                        ],
                      ),
                    ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback onProfileUpdated;

  const SettingsScreen({
    super.key,
    this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _handicapController;
  late TextEditingController _homeClubController;
  
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile?.photoUrl != widget.userProfile?.photoUrl) {
      _currentPhotoUrl = widget.userProfile?.photoUrl;
    }
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(
      text: widget.userProfile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userProfile?.lastName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userProfile?.email ?? '',
    );
    _handicapController = TextEditingController(
      text: widget.userProfile?.handicap.toStringAsFixed(1) ?? '0.0',
    );
    _homeClubController = TextEditingController(
      text: widget.userProfile?.homeClub ?? '',
    );
    _currentPhotoUrl = widget.userProfile?.photoUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _handicapController.dispose();
    _homeClubController.dispose();
    super.dispose();
  }

  // Helper method to get the appropriate profile image for Settings screen
  ImageProvider? _getSettingsProfileImageProvider() {
    // If there's a selected image, use it
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    
    // For Tobias Hanner, use the temporary asset image
    if (widget.userProfile?.firstName == 'Tobias' && widget.userProfile?.lastName == 'Hanner') {
      return const AssetImage('assets/profile/temp-tobias.jpeg');
    }
    
    // If there's a photo URL from Firebase Storage, use it
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return NetworkImage(_currentPhotoUrl!);
    }
    
    // No image available
    return null;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              if (_currentPhotoUrl != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _currentPhotoUrl = null;
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    // Temporary: Firebase Storage not configured
    print('Firebase Storage not configured - skipping upload');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile pictures will be available soon! Image selected but not uploaded.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // Return null to indicate no upload occurred
    return null;
    
    // Original upload code (disabled for now):
    /*
    try {
      final user = _authService.currentUser;
      if (user == null) {
        print('No authenticated user found');
        throw Exception('User not authenticated');
      }

      print('Starting image upload for user: ${user.uid}');
      
      // Test Firebase Storage connection first
      try {
        print('Testing Firebase Storage connection...');
        final testRef = FirebaseStorage.instance.ref();
        print('Storage reference created successfully: ${testRef.bucket}');
        
        // Try to get storage bucket info
        final bucket = FirebaseStorage.instance.bucket;
        print('Storage bucket: $bucket');
        
      } catch (storageTestError) {
        print('Firebase Storage connection test failed: $storageTestError');
        throw Exception('Firebase Storage not properly configured: $storageTestError');
      }
      
      // Create a unique filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.uid}_$timestamp.jpg';
      
      // Create the storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      print('Upload path: profile_images/$fileName');
      print('Full reference path: ${storageRef.fullPath}');
      
      // Set metadata for the file
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadedAt': timestamp.toString(),
        },
      );

      print('Starting file upload...');
      final uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;
      print('Upload task completed, getting download URL...');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Upload successful! Download URL: $downloadUrl');
      return downloadUrl;
      
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      print('Error details: ${e.toString()}');
      
      String userFriendlyMessage;
      switch (e.code) {
        case 'object-not-found':
          userFriendlyMessage = 'Storage bucket not found. Please check Firebase Storage configuration.';
          break;
        case 'bucket-not-found':
          userFriendlyMessage = 'Storage bucket does not exist. Please configure Firebase Storage.';
          break;
        case 'project-not-found':
          userFriendlyMessage = 'Firebase project not found. Please check project configuration.';
          break;
        case 'quota-exceeded':
          userFriendlyMessage = 'Storage quota exceeded. Please try again later.';
          break;
        case 'unauthenticated':
          userFriendlyMessage = 'Authentication required. Please log in again.';
          break;
        case 'unauthorized':
          userFriendlyMessage = 'Permission denied. Please check Storage security rules.';
          break;
        case 'retry-limit-exceeded':
          userFriendlyMessage = 'Upload failed after multiple attempts. Please try again.';
          break;
        case 'invalid-checksum':
          userFriendlyMessage = 'File validation failed. Please try again.';
          break;
        case 'canceled':
          userFriendlyMessage = 'Upload was canceled.';
          break;
        default:
          userFriendlyMessage = 'Upload failed: ${e.message ?? 'Unknown error'}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: Text('Error Code: ${e.code}\nMessage: ${e.message}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
      
      throw Exception('Firebase Storage Error: ${e.code} - ${e.message}');
      
    } catch (e) {
      print('General upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      throw e;
    }
    */
  }

  Future<void> _saveChanges() async {
    if (widget.userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoUrl = _currentPhotoUrl;
      bool imageUploadFailed = false;
      
      // Upload new image if selected
      if (_selectedImage != null) {
        try {
          print('Attempting to upload image...');
          photoUrl = await _uploadImage(_selectedImage!);
          print('Image uploaded successfully: $photoUrl');
        } catch (imageError) {
          print('Image upload failed: $imageError');
          imageUploadFailed = true;
          
          // Show specific image upload error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${imageError.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          
          // Ask user if they want to continue without image
          if (mounted) {
            final shouldContinue = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Image Upload Failed'),
                content: const Text('Would you like to save your profile changes without updating the photo?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
            
            if (shouldContinue != true) {
              return; // User cancelled
            }
          }
          
          // Continue with existing photo URL
          photoUrl = _currentPhotoUrl;
        }
      }
      
      final updatedProfile = widget.userProfile!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        handicap: double.tryParse(_handicapController.text.trim()) ?? 0.0,
        homeClub: _homeClubController.text.trim(),
        photoUrl: photoUrl,
      );

      print('Updating profile in Firestore...');
      await _firestoreService.updateUserProfile(updatedProfile);
      print('Profile updated successfully in Firestore');
      
      // Update local state with new photo URL and clear selected image
      setState(() {
        _currentPhotoUrl = photoUrl;
        _selectedImage = null;
      });
      
      // Show success message
      if (mounted) {
        final message = imageUploadFailed 
            ? 'Profile updated! (Photo uploads temporarily disabled)'
            : 'Profile updated successfully!';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: imageUploadFailed ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Callback to refresh parent screen
        widget.onProfileUpdated();
        
        // Go back to You screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      if (mounted) {
        // Go back to main screen and trigger refresh
        Navigator.of(context).pop();
        widget.onProfileUpdated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEEE), // Changed to fully opaque
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside of text fields
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        key: ValueKey(_currentPhotoUrl ?? 'tobias-temp'),
                                        radius: 60,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: _getSettingsProfileImageProvider(),
                                        child: _getSettingsProfileImageProvider() == null
                                            ? Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey.shade400,
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0093AF),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to change photo',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              enabled: false, // Email cannot be changed
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Golf Information Section
                  Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Golf Information',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF919194),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _handicapController,
                              decoration: const InputDecoration(
                                labelText: 'Handicap',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _homeClubController,
                              decoration: const InputDecoration(
                                labelText: 'Home Club',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Column(
                    children: [
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ca9c9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _confirmLogout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1ca9c9),
                            side: const BorderSide(color: Color(0xFF1ca9c9)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
            ),
    );
  }
}
