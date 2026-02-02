import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await _apiService.getMyReviews();
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }


  Map<String, List<Map<String, dynamic>>> _groupReviewsByMonth() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var review in _reviews) {
      final date = DateTime.parse(review['date']);
      final key = DateFormat('MMMM yyyy').format(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(review);
    }

    return grouped;
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
          'My Reviews',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading reviews',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadReviews,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your performance reviews will appear here',
                            style: GoogleFonts.inter(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReviews,
                      color: const Color(0xFF4CAF50),
                      child: _buildGroupedReviews(),
                    ),
    );
  }

  Widget _buildGroupedReviews() {
    // If more than 4 reviews, group by month
    if (_reviews.length > 4) {
      return _buildMonthlyGroupedReviews();
    } else {
      // Show weekly reviews
      return _buildWeeklyReviews();
    }
  }

  Widget _buildMonthlyGroupedReviews() {
    final grouped = _groupReviewsByMonth();
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final monthKey = sortedKeys[index];
        final monthReviews = grouped[monthKey]!;
        final avgRating = monthReviews.map((r) => (r['rating'] ?? 0).toDouble()).reduce((a, b) => a + b) / monthReviews.length;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Color(0xFF4CAF50),
              ),
            ),
            title: Text(
              monthKey,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[700],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${monthReviews.length} review${monthReviews.length > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            children: monthReviews.map((review) => _buildReviewCard(review)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyReviews() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(_reviews[index]);
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0).toDouble();
    final date = DateTime.parse(review['date']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scores
          Row(
            children: [
              Expanded(
                child: _buildScoreChip(
                  'Attendance',
                  (review['attendance_score'] ?? 0).toDouble(),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreChip(
                  'Punctuality',
                  (review['punctuality_score'] ?? 0).toDouble(),
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreChip(
                  'Performance',
                  (review['performance_score'] ?? 0).toDouble(),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Remarks
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager\'s Remarks',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review['remarks'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reviewer info
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Reviewed by ${review['reviewer_name']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildScoreChip(String label, double score, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
