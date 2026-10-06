import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // true = Login, false = Sign Up
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchMode(bool loginMode) {
    if (_isLoginMode == loginMode) return;
    setState(() {
      _isLoginMode = loginMode;
      _errorMessage = null;
      _nameController.clear();
    });
    if (!loginMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // LOGIN: Check if phone is registered, then log in
        final registered = await _authService.isUserRegistered(phone);
        if (registered) {
          await _authService.login(phone);
          setState(() { _isLoading = false; });
          _navigateToHome();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'This phone number is not registered. Please sign up first.';
          });
        }
      } else {
        // SIGN UP: Validate name, check if already registered, then register
        final name = _nameController.text.trim();
        if (name.isEmpty || name.length < 2) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Please enter your full name (at least 2 characters).';
          });
          return;
        }

        final alreadyRegistered = await _authService.isUserRegistered(phone);
        if (alreadyRegistered) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'This phone number is already registered. Please log in instead.';
          });
          return;
        }

        await _authService.register(name, phone);
        setState(() { _isLoading = false; });
        _navigateToHome();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e.toString().contains('UNIQUE constraint failed') || e.toString().contains('constraint failed')) {
          _errorMessage = 'This phone number is already registered. Please log in instead.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F1E),
                  Color(0xFF1B1B2F),
                  Color(0xFF110D2C),
                ],
              ),
            ),
          ),

          // Floating background glow elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA8E6CF).withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.12),
                    blurRadius: 90,
                    spreadRadius: 45,
                  ),
                ],
              ),
            ),
          ),

          // Main form content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand / Logo
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 72,
                      color: Color(0xFFA8E6CF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DinePoint',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find your perfect dining spot',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Glassmorphic Card Container
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Login / Sign Up Toggle Tabs
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchMode(true),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _isLoginMode
                                            ? const Color(0xFFA8E6CF)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Log In',
                                          style: TextStyle(
                                            color: _isLoginMode ? Colors.black : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchMode(false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !_isLoginMode
                                            ? const Color(0xFFA8E6CF)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: !_isLoginMode ? Colors.black : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Subtitle
                          Text(
                            _isLoginMode
                                ? 'Welcome back! Enter your phone number to log in.'
                                : 'New here? Create an account to get started.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Error message display
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Name input field (Sign Up only)
                          SizeTransition(
                            sizeFactor: _fadeAnimation,
                            axisAlignment: -1.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                enabled: !_isLoading,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(color: Colors.grey.shade400),
                                  prefixIcon: Icon(
                                    Icons.person_rounded,
                                    color: Colors.grey.shade400,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFA8E6CF),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Phone input field (always visible)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !_isLoading,
                            inputFormatters: [
                              IndianPhoneInputFormatter(),
                            ],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(
                                Icons.phone_iphone_rounded,
                                color: Colors.grey.shade400,
                              ),
                              prefixText: '+91 ',
                              prefixStyle: const TextStyle(color: Colors.white70),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFA8E6CF),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA8E6CF),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: const Color(0xFFA8E6CF).withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFFA8E6CF).withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    _isLoginMode ? 'Log In' : 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IndianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // If it starts with 91 and has more than 10 digits, strip the 91 prefix
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length > 10) {
      // Strip leading zero if it's there
      digits = digits.substring(1);
    }
    
    // Limit to 10 digits max
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
