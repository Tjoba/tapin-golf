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
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      appBar: AppBar(
        title: const Text('Play'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Play Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Book Screen
class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB2EFEEEE),
      appBar: AppBar(
        title: const Text('Book'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Book Screen',
          style: TextStyle(fontSize: 24),
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
