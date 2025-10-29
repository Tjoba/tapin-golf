import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      home: const MainNavigationScreen(),
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
  final AuthService _authService = AuthService();
  bool _hasCheckedAuth = false;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    PlayScreen(),
    BookScreen(),
    YouScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthenticationState();
  }

  Future<void> _checkAuthenticationState() async {
    // Check if user is already signed in
    final currentUser = _authService.currentUser;
    
    if (currentUser == null && !_hasCheckedAuth) {
      // User is not signed in, show login dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginDialog();
      });
    }
    
    setState(() {
      _hasCheckedAuth = true;
    });
  }

  Future<void> _showLoginDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    bool isLogin = true;

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without signing in
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isLogin ? 'Welcome to Tapin Golf' : 'Create Account'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLogin) ...[
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin ? 'Create Account' : 'Sign In Instead'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isLogin) {
                      final result = await _authService.signInWithEmailAndPassword(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (result != null) {
                        Navigator.of(context).pop();
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid email or password')),
                        );
                      }
                    } else {
                      if (firstNameController.text.trim().isEmpty || 
                          lastNameController.text.trim().isEmpty) {
                        // Show error - names are required
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter both first and last name')),
                        );
                        return;
                      }
                      final result = await _authService.registerWithEmailAndPassword(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        firstNameController.text.trim(),
                        lastNameController.text.trim(),
                      );
                      if (result != null) {
                        Navigator.of(context).pop();
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to create account. Please try again.')),
                        );
                      }
                    }
                  },
                  child: Text(isLogin ? 'Sign In' : 'Create Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'Home Screen',
          style: TextStyle(fontSize: 24),
        ),
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
      appBar: AppBar(
        title: const Text('Play'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      appBar: AppBar(
        title: const Text('Book'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      appBar: AppBar(
        title: const Text('You'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            IconButton(
              onPressed: () async {
                await _authService.signOut();
                _loadUserData();
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
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
                          // Profile Picture
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green.shade100,
                            child: _userProfile!.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _userProfile!.photoUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    _userProfile!.firstName.isNotEmpty && _userProfile!.lastName.isNotEmpty
                                        ? '${_userProfile!.firstName[0].toUpperCase()}${_userProfile!.lastName[0].toUpperCase()}'
                                        : _userProfile!.firstName.isNotEmpty
                                            ? _userProfile!.firstName[0].toUpperCase()
                                            : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Profile Info Cards
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Name'),
                              subtitle: Text('${_userProfile!.firstName} ${_userProfile!.lastName}'),
                            ),
                          ),
                          
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(_userProfile!.email),
                            ),
                          ),
                          
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.sports_golf),
                              title: const Text('Handicap'),
                              subtitle: Text(_userProfile!.handicap.toString()),
                            ),
                          ),
                          
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.location_on),
                              title: const Text('Home Club'),
                              subtitle: Text(_userProfile!.homeClub.isEmpty 
                                  ? 'Not set' 
                                  : _userProfile!.homeClub),
                            ),
                          ),
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
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _handicapController;
  late TextEditingController _homeClubController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
      text: widget.userProfile?.handicap.toString() ?? '0',
    );
    _homeClubController = TextEditingController(
      text: widget.userProfile?.homeClub ?? '',
    );
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

  Future<void> _saveChanges() async {
    if (widget.userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = widget.userProfile!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        handicap: int.tryParse(_handicapController.text.trim()) ?? 0,
        homeClub: _homeClubController.text.trim(),
      );

      await _firestoreService.updateUserProfile(updatedProfile);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
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
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Profile Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            enabled: false, // Email cannot be changed
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Golf Information Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sports_golf,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Golf Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _handicapController,
                            decoration: const InputDecoration(
                              labelText: 'Handicap',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.sports_golf),
                              helperText: 'Enter your current golf handicap',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _homeClubController,
                            decoration: const InputDecoration(
                              labelText: 'Home Club',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on_outlined),
                              helperText: 'Your primary golf club or course',
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
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveChanges,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
