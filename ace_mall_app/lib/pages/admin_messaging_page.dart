import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/branch.dart';

class AdminMessagingPage extends StatefulWidget {
  const AdminMessagingPage({super.key});

  @override
  State<AdminMessagingPage> createState() => _AdminMessagingPageState();
}

class _AdminMessagingPageState extends State<AdminMessagingPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _targetType = 'all';
  Branch? _selectedBranch;
  List<Branch> _branches = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    try {
      final branches = await _apiService.getBranches();
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_targetType == 'branch' && _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a branch'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _apiService.sendMessage(
        title: _titleController.text,
        content: _contentController.text,
        targetType: _targetType,
        targetBranchId: _selectedBranch?.id != null ? int.parse(_selectedBranch!.id) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _targetType = 'all';
          _selectedBranch = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Send Message',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Broadcast Message',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Send to all staff or specific branch',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message Details',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter message title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        hintText: 'Enter your message',
                        prefixIcon: const Icon(Icons.message),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Target Audience',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _targetType = 'all';
                                _selectedBranch = null;
                              });
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'all',
                                  groupValue: _targetType,
                                  onChanged: (value) {
                                    setState(() {
                                      _targetType = value!;
                                      _selectedBranch = null;
                                    });
                                  },
                                  activeColor: const Color(0xFF4CAF50),
                                ),
                                Text(
                                  'All Staff',
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _targetType = 'branch');
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'branch',
                                  groupValue: _targetType,
                                  onChanged: (value) {
                                    setState(() => _targetType = value!);
                                  },
                                  activeColor: const Color(0xFF4CAF50),
                                ),
                                Flexible(
                                  child: Text(
                                    'Specific Branch',
                                    style: GoogleFonts.inter(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_targetType == 'branch') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Branch>(
                        value: _selectedBranch,
                        decoration: InputDecoration(
                          labelText: 'Select Branch',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _branches.map((branch) {
                          return DropdownMenuItem(
                            value: branch,
                            child: Text(branch.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBranch = value);
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: BouncingDotsLoader(
                                  color: Colors.white,
                                  
                                ),
                              )
                            : Text(
                                'Send Message',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Messages expire after 1 week and will be sent as notifications to all selected staff.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.blue[900],
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
