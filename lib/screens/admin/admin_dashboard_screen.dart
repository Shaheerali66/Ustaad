import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/document_database.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncWithCloud();
  }

  Future<void> _syncWithCloud() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });
    final success = await DocumentDatabase.syncFromCloud();
    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Cloud Database synced successfully!' : 'Offline Mode: Using local storage backup.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: success ? Colors.teal : Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _downloadFile(String? base64, String? name) {
    if (base64 == null || name == null) return;
    final anchor = html.AnchorElement(href: base64)
      ..setAttribute('download', name)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  }

  void _updateStatus(Map<String, dynamic> technician, String status) {
    setState(() {
      technician['status'] = status;
    });
    DocumentDatabase.persistChanges();
    DocumentDatabase.syncToCloud();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Technician ${technician['name']} marked as $status! (Saved to cloud)'),
        backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get master list from static database
    final allTechnicians = DocumentDatabase.onboardedTechnicians;

    // Filter list
    final filteredTechnicians = allTechnicians.where((tech) {
      final matchesSearch = tech['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tech['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter == 'All' || tech['status'] == _selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    // Calculations for metrics
    final totalOnboarded = allTechnicians.length;
    final totalApproved = allTechnicians.where((t) => t['status'] == 'Approved').length;
    final totalPending = allTechnicians.where((t) => t['status'] == 'Pending Approval').length;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    // Responsive Metric Tile
    Widget buildMetricTile(String title, String value, IconData icon, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(minWidth: isMobile ? 140 : 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                Text(
                  value, 
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            )
          ],
        ),
      );
    }

    // Header Metrics builder
    Widget buildMetricsSection() {
      return isMobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  buildMetricTile('Total Onboarded', '$totalOnboarded', Icons.people, Colors.blue),
                  const SizedBox(width: 8),
                  buildMetricTile('Approved', '$totalApproved', Icons.check_circle_outline, Colors.green),
                  const SizedBox(width: 8),
                  buildMetricTile('Pending Review', '$totalPending', Icons.pending_actions, Colors.amber),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONBOARDING TELEMETRY',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                buildMetricTile('Total Onboarded', '$totalOnboarded techs', Icons.people, Colors.blue),
                const SizedBox(height: 12),
                buildMetricTile('Active & Approved', '$totalApproved techs', Icons.check_circle_outline, Colors.green),
                const SizedBox(height: 12),
                buildMetricTile('Pending Verification', '$totalPending reviews', Icons.pending_actions, Colors.amber),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔒 Administrative backend database directory simulation. Active base64 byte streams are persistent during live runtime.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                ),
              ],
            );
    }

    // Premium Card layout builder to completely prevent text wrapping issues
    Widget buildCardContent(Map<String, dynamic> tech, String initials, bool isPending, bool isDynamic) {
      final bool isCardNarrow = screenWidth < 650;

      if (isCardNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isPending ? Colors.amber.shade100 : AppColors.primaryContainer,
                  backgroundImage: tech['profilePhoto'] != null
                      ? MemoryImage(base64Decode(tech['profilePhoto']!.split(',').last))
                      : null,
                  child: tech['profilePhoto'] == null
                      ? Text(
                          initials.toUpperCase(),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tech['name'],
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDynamic) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEW',
                                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        tech['category'],
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              '📞 Phone: ${tech['phone']}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '📍 Area: ${tech['area']}, ${tech['city']}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '💼 Exp: ${tech['experience']} yrs  |  💰 Rate: Rs.${tech['hourlyRate']}/hr',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.amber.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'Pending Review' : 'Approved',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isPending ? Colors.amber.shade800 : Colors.green.shade800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showInspectorDialog(context, tech),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'View Profile',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // Desktop beautiful layout with protection from vertical stretching/squeezing
      return Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isPending ? Colors.amber.shade100 : AppColors.primaryContainer,
            backgroundImage: tech['profilePhoto'] != null
                ? MemoryImage(base64Decode(tech['profilePhoto']!.split(',').last))
                : null,
            child: tech['profilePhoto'] == null
                ? Text(
                    initials.toUpperCase(),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tech['name'],
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    const SizedBox(width: 8),
                    if (isDynamic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW USER',
                          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.build, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      tech['category'],
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.phone, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      tech['phone'],
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Area: ${tech['area']}, ${tech['city']}  |  Exp: ${tech['experience']} yrs  |  Rate: Rs.${tech['hourlyRate']}/hr',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPending ? Colors.amber.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPending ? 'Pending Review' : 'Approved',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isPending ? Colors.amber.shade800 : Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _showInspectorDialog(context, tech),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'View Profile',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-selection'),
        ),
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Backend Admin Directory',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
          ],
        ),
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_sync, color: AppColors.primary),
                  tooltip: 'Sync with Cloud Database',
                  onPressed: _syncWithCloud,
                ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green.shade900),
                )
              ],
            ),
          ),
        ],
      ),
      body: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMetricsSection(),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Master Onboarded Directory',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inspect registrations, CNICs, live profile photos, and onboarding statuses.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        // Search and Filters
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search trades...',
                                  prefixIcon: Icon(Icons.search),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Filter Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.surfaceVariant),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatusFilter,
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface),
                                  items: const [
                                    DropdownMenuItem(value: 'All', child: Text('All')),
                                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                    DropdownMenuItem(value: 'Pending Approval', child: Text('Review')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedStatusFilter = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredTechnicians.isEmpty
                              ? Center(
                                  child: Text(
                                    'No technicians match your filters.',
                                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredTechnicians.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final tech = filteredTechnicians[index];
                                    final isPending = tech['status'] == 'Pending Approval';
                                    final isDynamic = tech['cnicFront'] != null;

                                    String initials = 'W';
                                    final String name = tech['name'];
                                    if (name.isNotEmpty) {
                                      final parts = name.split(' ');
                                      initials = parts[0][0] + (parts.length > 1 ? parts[1][0] : '');
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isPending ? Colors.amber.shade200 : AppColors.surfaceVariant,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: buildCardContent(tech, initials, isPending, isDynamic),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar Panel for Admin Controls
                Expanded(
                  flex: 3,
                  child: Container(
                    color: AppColors.surfaceContainerLowest,
                    padding: const EdgeInsets.all(24),
                    child: buildMetricsSection(),
                  ),
                ),
                // Main Directory Panel
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Master Onboarded Directory',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inspect registrations, review real CNICs/profile photos taken with live cameras, and manage onboarding status.',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),

                        // Search and Filters
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search by technician name, trade...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.surfaceVariant),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatusFilter,
                                  items: const [
                                    DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                    DropdownMenuItem(value: 'Pending Approval', child: Text('Pending Review')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedStatusFilter = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Table of Technicians
                        Expanded(
                          child: filteredTechnicians.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open, size: 64, color: AppColors.outlineVariant),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No technicians match your search filters.',
                                        style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredTechnicians.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final tech = filteredTechnicians[index];
                                    final isPending = tech['status'] == 'Pending Approval';
                                    final isDynamic = tech['cnicFront'] != null;

                                    String initials = 'W';
                                    final String name = tech['name'];
                                    if (name.isNotEmpty) {
                                      final parts = name.split(' ');
                                      initials = parts[0][0] + (parts.length > 1 ? parts[1][0] : '');
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isPending ? Colors.amber.shade200 : AppColors.surfaceVariant,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: buildCardContent(tech, initials, isPending, isDynamic),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showInspectorDialog(BuildContext context, Map<String, dynamic> tech) {
    final bool hasFront = tech['cnicFront'] != null;
    final bool hasBack = tech['cnicBack'] != null;
    final bool hasProfile = tech['profilePhoto'] != null;
    final bool hasCert = tech['certification'] != null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isPending = tech['status'] == 'Pending Approval';
            final double dialogWidth = MediaQuery.of(context).size.width;
            final bool isDialogMobile = dialogWidth < 800;

            // Details list helper
            Widget buildDetailsPanel() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PERSONAL DETAILS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _detailRow('Name', tech['name']),
                  _detailRow('CNIC', tech['cnic']),
                  _detailRow('Phone', tech['phone']),
                  _detailRow('City', tech['city'] ?? 'Islamabad'),
                  const SizedBox(height: 20),
                  Text('SERVICE TRADE DETAILS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _detailRow('Category', tech['category']),
                  _detailRow('Experience', '${tech['experience']} Years'),
                  _detailRow('Preferred Area', tech['area']),
                  _detailRow('Hourly Rate', 'Rs. ${tech['hourlyRate']} / hr'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('AUDIT VERIFICATION ACTIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  if (isPending) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _updateStatus(tech, 'Approved');
                          setDialogState(() {});
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Approve & Onboard', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _updateStatus(tech, 'Rejected');
                          setDialogState(() {});
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Reject Application', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tech['status'] == 'Approved' ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tech['status'] == 'Approved' ? Colors.green.shade200 : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tech['status'] == 'Approved' ? Icons.check_circle : Icons.cancel,
                            color: tech['status'] == 'Approved' ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Onboarding decision completed: marked as ${tech['status']}.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tech['status'] == 'Approved' ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }

            // Documents list helper
            Widget buildDocumentsPanel() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('VERIFICATION DOCUMENTS SUBMISSIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _buildDocPreviewRow(
                    'CNIC Front Side',
                    tech['cnicFrontName'],
                    hasFront,
                    tech['cnicFront'],
                  ),
                  const SizedBox(height: 12),
                  _buildDocPreviewRow(
                    'CNIC Back Side',
                    tech['cnicBackName'],
                    hasBack,
                    tech['cnicBack'],
                  ),
                  const SizedBox(height: 12),
                  _buildDocPreviewRow(
                    'Profile Photo (Taken Live)',
                    tech['profilePhotoName'],
                    hasProfile,
                    tech['profilePhoto'],
                  ),
                  const SizedBox(height: 12),
                  _buildDocPreviewRow(
                    'Certification',
                    tech['certificationName'],
                    hasCert,
                    tech['certification'],
                    isPdf: tech['certificationName']?.toString().toLowerCase().endsWith('.pdf') == true,
                  ),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Technician Audit',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              content: SizedBox(
                width: isDialogMobile ? 400 : 850,
                child: SingleChildScrollView(
                  child: isDialogMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildDetailsPanel(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(),
                            ),
                            buildDocumentsPanel(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: buildDetailsPanel(),
                            ),
                            const SizedBox(width: 24),
                            Container(width: 1, height: 420, color: AppColors.surfaceVariant),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 6,
                              child: buildDocumentsPanel(),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurfaceVariant)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildDocPreviewRow(String title, String? name, bool hasFile, String? base64, {bool isPdf = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          if (hasFile && base64 != null && !isPdf) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Image.memory(
                  base64Decode(base64.split(',').last),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? Colors.red.shade700 : AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  hasFile ? (name ?? 'document.jpg') : 'No file (Mock file)',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontStyle: hasFile ? FontStyle.normal : FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (hasFile) ...[
            IconButton(
              icon: const Icon(Icons.download, color: AppColors.primary, size: 20),
              onPressed: () => _downloadFile(base64, name),
              tooltip: 'Download Submission',
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'MOCK',
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey.shade700),
              ),
            )
          ]
        ],
      ),
    );
  }
}
