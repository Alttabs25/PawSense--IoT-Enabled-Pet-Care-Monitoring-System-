import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/meet_your_pup_screen.dart';
import 'widgets/app_drawer.dart';
import 'services/pet_log_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PawSenseApp());
}

class PawSenseApp extends StatelessWidget {
  const PawSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const figmaOlive = Color(0xFFA4B189);
    const figmaBeige = Color(0xFFE8E5C6);
    const figmaCard = Color(0xFFD3D3D3);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: figmaOlive,
      primary: figmaOlive,
      secondary: figmaOlive,
      surface: figmaCard,
      brightness: Brightness.light,
    );

    final manropeTextTheme = GoogleFonts.manropeTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      title: 'PawSense',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: manropeTextTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        primaryTextTheme: manropeTextTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: figmaBeige,
        appBarTheme: const AppBarTheme(
          backgroundColor: figmaOlive,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          toolbarHeight: 74,
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: figmaCard,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 1,
          shadowColor: Colors.black12,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: figmaOlive, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: figmaOlive,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: figmaOlive,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: figmaOlive,
            side: const BorderSide(color: figmaOlive),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: figmaBeige,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: figmaOlive,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.white.withValues(alpha: 0.22),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: Colors.white,
              size: isSelected ? 26 : 24,
            );
          }),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isOnLoginPage = true;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthStateChange);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChange);
    _authService.dispose();
    super.dispose();
  }

  void _onAuthStateChange() {
    setState(() {});
  }

  void _switchToSignUp() {
    setState(() {
      _isOnLoginPage = false;
    });
  }

  void _switchToLogin() {
    setState(() {
      _isOnLoginPage = true;
    });
  }

  void _logout() {
    _authService.logout();
    setState(() {
      _isOnLoginPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isAuthenticated) {
      return _isOnLoginPage
          ? LoginScreen(
              authService: _authService,
              onSignUpTap: _switchToSignUp,
            )
          : SignUpScreen(
              authService: _authService,
              onLoginTap: _switchToLogin,
            );
    }

    // Check if user has completed pet profile
    if (_authService.currentUser != null &&
        !_authService.currentUser!.petProfileComplete) {
      return MeetYourPupScreen(
        authService: _authService,
        onComplete: () {
          setState(() {});
        },
      );
    }

    return MainNavigation(authService: _authService, onLogout: _logout);
  }
}

class MainNavigation extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.authService,
    required this.onLogout,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const Color _figmaOlive = Color(0xFFA4B189);
  static const Color _figmaBackground = Color(0xFFE8E5C6);

  int _selectedIndex = 0;
  late PetLogService _petLogService;

  @override
  void initState() {
    super.initState();
    _petLogService = PetLogService(userId: widget.authService.currentUser!.id);
    _petLogService.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    _petLogService.removeListener(_onServiceChange);
    _petLogService.dispose();
    super.dispose();
  }

  void _onServiceChange() {
    setState(() {});
  }

  List<Widget> get _pages => [
        HomeScreen(
          petLogService: _petLogService,
          petName: widget.authService.currentUser?.petName ?? 'Your pet',
        ),
        DashboardScreen(petLogService: _petLogService),
        ProfileScreen(authService: widget.authService),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    if (!mounted) {
      return;
    }
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _figmaBackground,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: _figmaOlive,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        title: const Text(
          "PawSense",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<void>(
            iconColor: Colors.white,
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  _handleLogout();
                },
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        userName: widget.authService.currentUser?.name ?? 'PawSense User',
        userEmail: widget.authService.currentUser?.email ?? '-',
        petName: widget.authService.currentUser?.petName ?? 'Your Pet',
        onSelectPage: _onItemTapped,
        onLogout: _handleLogout,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Activity'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
