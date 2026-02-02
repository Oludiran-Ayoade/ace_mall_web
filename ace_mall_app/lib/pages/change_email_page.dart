import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import '../services/api_service.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentEmail() async {
    try {
      final user = await _apiService.getCurrentUser();
      setState(() {
        _currentEmail = user['email'] ?? '';
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _changeEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _apiService.updateEmail(
      _newEmailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Email updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Show dialog that they need to sign in again
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Email Updated'),
            content: const Text('Your email has been updated successfully. Please sign in again with your new email.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Clear token and navigate to sign in
                  _apiService.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to update email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Change Email'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will need to sign in again after changing your email',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Current Email (Read-only)
                Text(
                  'Current Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _currentEmail,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // New Email
                Text(
                  'New Email Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter new email address',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    if (value.trim() == _currentEmail) {
                      return 'New email must be different from current email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Password for Confirmation
                Text(
                  'Current Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password to confirm',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                // Update Email Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const BouncingDotsLoader(
                            color: Colors.white,
                            size: 10,
                          )
                        : const Text(
                            'Update Email',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
