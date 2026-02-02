import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/bouncing_dots_loader.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      
      final result = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );


      if (!mounted) return;

      if (result['success'] == true) {
        
        // Get user role from response
        final userData = result['data']['user'];
        final roleName = userData['role_name'] as String?;
        
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to appropriate dashboard based on role
        String dashboardRoute = '/general-staff-dashboard'; // Default for general staff
        
        if (roleName != null) {
          if (roleName.contains('CEO') || roleName.contains('Chief Executive')) {
            dashboardRoute = '/ceo-dashboard';
          } else if (roleName.contains('COO') || roleName.contains('Chief Operating')) {
            dashboardRoute = '/coo-dashboard'; // COO has dedicated dashboard
          } else if (roleName.contains('Chairman')) {
            dashboardRoute = '/ceo-dashboard'; // Chairman uses CEO dashboard
          } else if (roleName.contains('HR') || roleName.contains('Human Resource')) {
            dashboardRoute = '/hr-dashboard';
          } else if (roleName.contains('Auditor')) {
            dashboardRoute = '/auditor-dashboard'; // Auditors have dedicated dashboard
          } else if (roleName.contains('Group Head')) {
            dashboardRoute = '/ceo-dashboard'; // Group Heads use CEO dashboard for department oversight
          } else if (roleName.contains('Operations Manager')) {
            dashboardRoute = '/operations-manager-dashboard'; // Operations Managers have Branch Manager-like dashboard
          } else if (roleName.contains('Branch Manager')) {
            dashboardRoute = '/branch-manager-dashboard';
          } else if (roleName.contains('Compliance Officer')) {
            dashboardRoute = '/compliance-officer-dashboard'; // Compliance Officers have Floor Manager-like dashboard
          } else if (roleName.contains('Facility Manager')) {
            dashboardRoute = '/facility-manager-dashboard'; // Facility Managers have Floor Manager-like dashboard
          } else if (roleName.contains('Floor Manager') || 
                     roleName.contains('Manager (Cinema)') ||
                     roleName.contains('Manager (Photo Studio)') ||
                     roleName.contains('Manager (Saloon)') ||
                     roleName.contains('Manager (Arcade') ||
                     roleName.contains('Manager (Casino)') ||
                     roleName.contains('Supervisor (Cinema)') ||
                     roleName.contains('Supervisor (Photo Studio)') ||
                     roleName.contains('Supervisor (Saloon)') ||
                     roleName.contains('Supervisor (Arcade)') ||
                     roleName.contains('Supervisor (Casino)')) {
            dashboardRoute = '/floor-manager-dashboard'; // Floor Managers and Supervisors use same dashboard
          } else if (roleName.contains('Store Manager')) {
            dashboardRoute = '/general-staff-dashboard'; // Store Managers use General Staff dashboard
          } else {
            // General staff (Cashier, Cook, Security, etc.)
            dashboardRoute = '/general-staff-dashboard';
          }
        }
        
        Navigator.of(context).pushReplacementNamed(dashboardRoute);
      } else {
        
        // Login failed - show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Login failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo and branding - UPDATED
                  Center(
                    child: Column(
                      children: [
                        // Shopping cart icon with background circle
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_rounded,
                            size: 64,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App name - Inter Bold
                        Text(
                          'Ace Mall',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4CAF50),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tagline
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 16),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 22),
                        hintText: 'Email',
                        hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.inter(fontSize: 16),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: 'Password',
                        hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign In button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const BouncingDotsLoader(
                            color: Colors.white,
                            size: 10,
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  
                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Forgot Password (below OR)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4CAF50),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}