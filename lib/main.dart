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

  Future<void> _showEditProfileDialog() async {
    if (_userProfile == null) return;

    final TextEditingController firstNameController = TextEditingController(text: _userProfile!.firstName);
    final TextEditingController lastNameController = TextEditingController(text: _userProfile!.lastName);
    final TextEditingController handicapController = TextEditingController(text: _userProfile!.handicap.toString());
    final TextEditingController homeClubController = TextEditingController(text: _userProfile!.homeClub);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                TextField(
                  controller: handicapController,
                  decoration: const InputDecoration(
                    labelText: 'Handicap',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: homeClubController,
                  decoration: const InputDecoration(
                    labelText: 'Home Club',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedProfile = _userProfile!.copyWith(
                  firstName: firstNameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  handicap: int.tryParse(handicapController.text.trim()) ?? 0,
                  homeClub: homeClubController.text.trim(),
                );
                
                try {
                  await _firestoreService.updateUserProfile(updatedProfile);
                  Navigator.of(context).pop();
                  _loadUserData();
                } catch (e) {
                  print('Error updating profile: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentUser != null)
            IconButton(
              onPressed: () async {
                await _authService.signOut();
                _loadUserData();
              },
              icon: const Icon(Icons.logout),
            ),
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
                              trailing: IconButton(
                                onPressed: _showEditProfileDialog,
                                icon: const Icon(Icons.edit),
                              ),
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
                              trailing: IconButton(
                                onPressed: _showEditProfileDialog,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                          
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.location_on),
                              title: const Text('Home Club'),
                              subtitle: Text(_userProfile!.homeClub.isEmpty 
                                  ? 'Not set' 
                                  : _userProfile!.homeClub),
                              trailing: IconButton(
                                onPressed: _showEditProfileDialog,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
