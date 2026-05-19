import 'dart:async';
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
  bool _isConnected = true;
  String _activeNav = 'Dashboard Overview';
  Timer? _pollTimer;
  List<Map<String, dynamic>> _newAlerts = [];

  final List<_NavItem> _navItems = [
    _NavItem('Dashboard Overview', Icons.dashboard_rounded),
    _NavItem('Worker Applications', Icons.assignment_ind_rounded),
    _NavItem('Approved Workers', Icons.check_circle_rounded),
    _NavItem('Rejected Workers', Icons.cancel_rounded),
    _NavItem('Pending Review', Icons.pending_actions_rounded),
    _NavItem('Settings', Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _syncWithCloud();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _pollForUpdates());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncWithCloud() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    final result = await DocumentDatabase.syncFromCloudWithInfo();
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _isConnected = true;
        if (result.newEntries.isNotEmpty) {
          _newAlerts.addAll(result.newEntries);
        }
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cloud synced!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _pollForUpdates() async {
    final result = await DocumentDatabase.syncFromCloudWithInfo();
    if (mounted) {
      setState(() {
        _isConnected = true;
        if (result.newEntries.isNotEmpty) {
          _newAlerts.addAll(result.newEntries);
        }
      });
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

  Future<void> _updateStatus(Map<String, dynamic> tech, String status) async {
    setState(() => tech['status'] = status);
    await DocumentDatabase.updateTechnician(tech['id'].toString(), {'status': status});
    if (mounted) {
      setState(() {
        _isConnected = true;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tech['name']} marked as $status!'),
        backgroundColor: status == 'Approved' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.orange),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _onNavTap(String label) {
    setState(() {
      _activeNav = label;
      if (label == 'Approved Workers') _selectedStatusFilter = 'Approved';
      else if (label == 'Rejected Workers') _selectedStatusFilter = 'Rejected';
      else if (label == 'Pending Review') _selectedStatusFilter = 'Pending Approval';
      else if (label == 'Worker Applications' || label == 'Dashboard Overview') _selectedStatusFilter = 'All';
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'W';
    final parts = name.split(' ');
    return (parts[0][0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final all = DocumentDatabase.onboardedTechnicians;
    final filtered = all.where((t) {
      final matchSearch = t['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _selectedStatusFilter == 'All' || t['status'] == _selectedStatusFilter;
      return matchSearch && matchStatus;
    }).toList();

    final totalCount = all.length;
    final approvedCount = all.where((t) => t['status'] == 'Approved').length;
    final pendingCount = all.where((t) => t['status'] == 'Pending Approval').length;
    final rejectedCount = all.where((t) => t['status'] == 'Rejected').length;
    final resubCount = all.where((t) => t['status'] == 'Resubmission Requested').length;

    final double sw = MediaQuery.of(context).size.width;
    final bool isMobile = sw < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? _buildDrawer(pendingCount) : null,
      body: isMobile
          ? _buildMobileBody(filtered, totalCount, approvedCount, pendingCount, rejectedCount, resubCount)
          : _buildDesktopBody(filtered, totalCount, approvedCount, pendingCount, rejectedCount, resubCount),
    );
  }

  // ─── DRAWER (Mobile sidebar) ───
  Widget _buildDrawer(int pendingCount) {
    return Drawer(
      backgroundColor: const Color(0xFF0F1B2D),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text('Khidmat-AI', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
            const SizedBox(height: 8),
            Text('Admin Panel', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            ..._navItems.map((item) => _buildNavTile(item, pendingCount, true)),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () => context.go('/role-selection'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(_NavItem item, int pendingCount, bool inDrawer) {
    final isActive = _activeNav == item.label;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(item.icon, color: isActive ? Colors.white : Colors.white54, size: 20),
        title: Text(item.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? Colors.white : Colors.white70)),
        trailing: item.label == 'Pending Review' && pendingCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                child: Text('$pendingCount', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
              )
            : null,
        onTap: () {
          _onNavTap(item.label);
          if (inDrawer) Navigator.pop(context);
        },
      ),
    );
  }

  // ─── TOP HEADER BAR ───
  PreferredSizeWidget _buildTopBar(int pendingCount, bool isMobile) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      leading: isMobile
          ? Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))
          : null,
      automaticallyImplyLeading: false,
      title: isMobile
          ? Row(children: [
              const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text('Admin Panel', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ])
          : Text('Worker Management Dashboard', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
      actions: [
        // Sync Indicator
        InkWell(
          onTap: _syncWithCloud,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isConnected
                    ? const PulsingDot(color: Colors.green)
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Connected' : 'Sync Paused',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                if (_isSyncing) ...[
                  const SizedBox(width: 6),
                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary)),
                ],
              ],
            ),
          ),
        ),
        // Notification Bell
        Stack(children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              if (_newAlerts.isNotEmpty) {
                _showNewAlertDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new notifications'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
              }
            },
          ),
          if (pendingCount > 0)
            Positioned(right: 6, top: 6, child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('$pendingCount', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
            )),
        ]),
        // Admin avatar
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: AppColors.primaryContainer, child: Text('A', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary))),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Text('Admin', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        if (!isMobile)
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20), tooltip: 'Logout', onPressed: () => context.go('/role-selection')),
      ],
    );
  }

  void _showNewAlertDialog() {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.fiber_new, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text('New Applications', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: _newAlerts.map((a) => ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person_add, color: Colors.white, size: 18)),
            title: Text(a['name'] ?? 'Unknown', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text(a['category'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
          )).toList()),
        ),
        actions: [
          TextButton(onPressed: () { setState(() => _newAlerts.clear()); Navigator.pop(ctx); }, child: const Text('Dismiss')),
          ElevatedButton(
            onPressed: () { setState(() { _newAlerts.clear(); _selectedStatusFilter = 'Pending Approval'; _activeNav = 'Pending Review'; }); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('View Now'),
          ),
        ],
      );
    });
  }
  // ─── MOBILE BODY ───
  Widget _buildMobileBody(List<Map<String, dynamic>> filtered, int total, int approved, int pending, int rejected, int resub) {
    return Column(children: [
      _buildTopBar(pending, true),
      // New application alert banner
      if (_newAlerts.isNotEmpty)
        _buildAlertBanner(),
      // Offline warning banner
      if (!_isConnected)
        _buildOfflineBanner(),
      // Stats row
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _statChip('Total', '$total', Icons.people, Colors.blue),
          const SizedBox(width: 8),
          _statChip('Approved', '$approved', Icons.check_circle_outline, Colors.green),
          const SizedBox(width: 8),
          _statChip('Pending', '$pending', Icons.pending_actions, Colors.amber),
          const SizedBox(width: 8),
          _statChip('Rejected', '$rejected', Icons.cancel_outlined, Colors.red),
        ]),
      ),
      const Divider(height: 1),
      // Search + filter
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: TextField(
            decoration: const InputDecoration(hintText: 'Search workers...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 8)),
            onChanged: (v) => setState(() => _searchQuery = v),
          )),
          const SizedBox(width: 8),
          _buildFilterDropdown(),
        ]),
      ),
      // Worker list
      Expanded(
        child: filtered.isEmpty
            ? Center(child: Text('No workers match filters.', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)))
            : RefreshIndicator(
                onRefresh: _syncWithCloud,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _i) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _buildWorkerCard(filtered[i], true),
                ),
              ),
      ),
    ]);
  }

  // ─── DESKTOP BODY ───
  Widget _buildDesktopBody(List<Map<String, dynamic>> filtered, int total, int approved, int pending, int rejected, int resub) {
    return Row(children: [
      // Left Sidebar
      Container(
        width: 260,
        color: const Color(0xFF0F1B2D),
        child: SafeArea(child: Column(children: [
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text('Khidmat-AI', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
          const SizedBox(height: 4),
          Text('Admin Panel', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          ..._navItems.map((item) => _buildNavTile(item, pending, false)),
          const Spacer(),
          // Sidebar stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TELEMETRY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1)),
                const SizedBox(height: 10),
                _sidebarStat('Total Workers', '$total', Colors.blue),
                _sidebarStat('Approved', '$approved', Colors.green),
                _sidebarStat('Pending', '$pending', Colors.amber),
                _sidebarStat('Rejected', '$rejected', Colors.red),
                if (resub > 0) _sidebarStat('Resubmission', '$resub', Colors.orange),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            title: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13)),
            onTap: () => context.go('/role-selection'),
          ),
          const SizedBox(height: 12),
        ])),
      ),
      // Main content
      Expanded(child: Column(children: [
        _buildTopBar(pending, false),
        if (_newAlerts.isNotEmpty) _buildAlertBanner(),
        if (!_isConnected) _buildOfflineBanner(),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Worker Management Directory', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Inspect, edit, approve, or reject worker applications across all devices in real time.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 20),
            // Search + filter
            Row(children: [
              Expanded(child: TextField(
                decoration: const InputDecoration(hintText: 'Search by name, trade...', prefixIcon: Icon(Icons.search)),
                onChanged: (v) => setState(() => _searchQuery = v),
              )),
              const SizedBox(width: 16),
              _buildFilterDropdown(),
            ]),
            const SizedBox(height: 20),
            // 2-col grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.folder_open, size: 64, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      Text('No workers match filters.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant)),
                    ]))
                  : LayoutBuilder(builder: (ctx, constraints) {
                      final cols = constraints.maxWidth > 900 ? 2 : 1;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: cols == 2 ? 2.2 : 3.5,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _buildWorkerCard(filtered[i], false),
                      );
                    }),
            ),
          ]),
        )),
      ])),
    ]);
  }

  // ─── REUSABLE WIDGETS ───
  Widget _buildAlertBanner() {
    final latest = _newAlerts.last;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.amber.shade50,
      child: Row(children: [
        const Icon(Icons.fiber_new, color: Colors.amber, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('New application: ${latest['name']} — ${latest['category']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600))),
        TextButton(
          onPressed: () { setState(() { _newAlerts.clear(); _selectedStatusFilter = 'Pending Approval'; _activeNav = 'Pending Review'; }); },
          child: Text('View Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _newAlerts.clear())),
      ]),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }

  Widget _sidebarStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: _selectedStatusFilter,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface),
        items: const [
          DropdownMenuItem(value: 'All', child: Text('All Statuses')),
          DropdownMenuItem(value: 'Approved', child: Text('Approved')),
          DropdownMenuItem(value: 'Pending Approval', child: Text('Pending')),
          DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
          DropdownMenuItem(value: 'Resubmission Requested', child: Text('Resubmission')),
        ],
        onChanged: (v) { if (v != null) setState(() => _selectedStatusFilter = v); },
      )),
    );
  }
  // ─── WORKER CARD ───
  Widget _buildWorkerCard(Map<String, dynamic> tech, bool isMobile) {
    final isPending = tech['status'] == 'Pending Approval';
    final isRejected = tech['status'] == 'Rejected';
    final isResub = tech['status'] == 'Resubmission Requested';
    final isDynamic = tech['cnicFront'] != null;
    final initials = _getInitials(tech['name'] ?? '');

    MaterialColor statusColor = Colors.green;
    String statusLabel = 'Approved';
    if (isPending) { statusColor = Colors.amber; statusLabel = 'Pending Review'; }
    else if (isRejected) { statusColor = Colors.red; statusLabel = 'Rejected'; }
    else if (isResub) { statusColor = Colors.orange; statusLabel = 'Resubmission'; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? Colors.amber.shade200 : AppColors.surfaceVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: isMobile ? 22 : 26,
            backgroundColor: isPending ? Colors.amber.shade100 : AppColors.primaryContainer,
            backgroundImage: tech['profilePhoto'] != null ? MemoryImage(base64Decode(tech['profilePhoto']!.split(',').last)) : null,
            child: tech['profilePhoto'] == null ? Text(initials, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: isMobile ? 12 : 14)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(tech['name'] ?? '', style: GoogleFonts.inter(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (isDynamic) ...[const SizedBox(width: 6), Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(4)),
                child: Text('NEW', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary)),
              )],
            ]),
            Text(tech['category'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.shade100, borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor.shade800)),
          ),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Text('📞 ${tech['phone']}  •  📍 ${tech['area']}, ${tech['city']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text('💼 ${tech['experience']} yrs  •  💰 Rs.${tech['hourlyRate']}/hr', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        // Action buttons
        Wrap(spacing: 8, runSpacing: 8, children: [
          _actionBtn('View Profile', Icons.visibility, AppColors.primary, () => _showInspectorDialog(context, tech)),
          _actionBtn('Edit', Icons.edit, Colors.blue, () => _showEditDialog(context, tech)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  // ─── VIEW PROFILE DIALOG (Inspector) ───
  void _showInspectorDialog(BuildContext context, Map<String, dynamic> tech) {
    final bool hasFront = tech['cnicFront'] != null;
    final bool hasBack = tech['cnicBack'] != null;
    final bool hasProfile = tech['profilePhoto'] != null;
    final bool hasCert = tech['certification'] != null;

    showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (context, setDialogState) {
        final isPending = tech['status'] == 'Pending Approval';
        final isResub = tech['status'] == 'Resubmission Requested';
        final dw = MediaQuery.of(context).size.width;
        final isNarrow = dw < 800;

        Widget detailsPanel() {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('PERSONAL DETAILS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12),
            _detailRow('Name', tech['name'] ?? ''),
            _detailRow('CNIC', tech['cnic'] ?? ''),
            _detailRow('Phone', tech['phone'] ?? ''),
            _detailRow('City', tech['city'] ?? 'Islamabad'),
            const SizedBox(height: 16),
            Text('SERVICE DETAILS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12),
            _detailRow('Category', tech['category'] ?? ''),
            _detailRow('Experience', '${tech['experience']} Years'),
            _detailRow('Area', tech['area'] ?? ''),
            _detailRow('Rate', 'Rs. ${tech['hourlyRate']} / hr'),
            if (tech['adminNotes'] != null && tech['adminNotes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('ADMIN NOTES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.deepPurple)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(tech['adminNotes'], style: GoogleFonts.inter(fontSize: 12, color: Colors.deepPurple.shade900)),
              ),
            ],
            const SizedBox(height: 20), const Divider(), const SizedBox(height: 12),
            Text('ACTIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12),
            if (isPending || isResub) ...[
              _fullBtn('Approve & Onboard', Colors.green, () async { await _updateStatus(tech, 'Approved'); setDialogState(() {}); setState(() {}); }),
              const SizedBox(height: 8),
              _fullBtn('Reject Application', Colors.red, () async { await _updateStatus(tech, 'Rejected'); setDialogState(() {}); setState(() {}); }),
              const SizedBox(height: 8),
              _fullBtn('Request Resubmission', Colors.orange, () async { await _updateStatus(tech, 'Resubmission Requested'); setDialogState(() {}); setState(() {}); }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: tech['status'] == 'Approved' ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: tech['status'] == 'Approved' ? Colors.green.shade200 : Colors.red.shade200)),
                child: Row(children: [
                  Icon(tech['status'] == 'Approved' ? Icons.check_circle : Icons.cancel, color: tech['status'] == 'Approved' ? Colors.green.shade800 : Colors.red.shade800),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Status: ${tech['status']}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: tech['status'] == 'Approved' ? Colors.green.shade900 : Colors.red.shade900))),
                ]),
              ),
            ],
            const SizedBox(height: 12),
            _fullBtn('Edit Profile', Colors.blue, () { Navigator.pop(ctx); _showEditDialog(context, tech); }),
          ]);
        }

        Widget docsPanel() {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('DOCUMENTS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 16),
            _docRow('CNIC Front', tech['cnicFrontName'], hasFront, tech['cnicFront']),
            const SizedBox(height: 10),
            _docRow('CNIC Back', tech['cnicBackName'], hasBack, tech['cnicBack']),
            const SizedBox(height: 10),
            _docRow('Profile Photo', tech['profilePhotoName'], hasProfile, tech['profilePhoto']),
            const SizedBox(height: 10),
            _docRow('Certification', tech['certificationName'], hasCert, tech['certification'], isPdf: tech['certificationName']?.toString().toLowerCase().endsWith('.pdf') == true),
          ]);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.verified_user, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Worker Audit', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ]),
          content: SizedBox(
            width: isNarrow ? 400 : 850,
            child: SingleChildScrollView(
              child: isNarrow
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [detailsPanel(), const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()), docsPanel()])
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 4, child: detailsPanel()),
                      const SizedBox(width: 24),
                      Container(width: 1, height: 420, color: AppColors.surfaceVariant),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: docsPanel()),
                    ]),
            ),
          ),
        );
      });
    });
  }

  Widget _fullBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
    ));
  }

  // ─── EDIT DIALOG ───
  void _showEditDialog(BuildContext context, Map<String, dynamic> tech) {
    final nameC = TextEditingController(text: tech['name'] ?? '');
    final phoneC = TextEditingController(text: tech['phone'] ?? '');
    final cnicC = TextEditingController(text: tech['cnic'] ?? '');
    final expC = TextEditingController(text: tech['experience']?.toString() ?? '');
    final rateC = TextEditingController(text: tech['hourlyRate']?.toString() ?? '');
    final areaC = TextEditingController(text: tech['area'] ?? '');
    final cityC = TextEditingController(text: tech['city'] ?? '');
    final notesC = TextEditingController(text: tech['adminNotes'] ?? '');
    String selectedCategory = tech['category'] ?? 'General Trades';

    final categories = ['AC Technician', 'Plumber', 'Electrician', 'Carpenter', 'Painter', 'Cleaner', 'Beautician', 'Tutor', 'General Trades'];
    if (!categories.contains(selectedCategory)) categories.add(selectedCategory);

    showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (context, setDialogState) {
        final dw = MediaQuery.of(context).size.width;
        final isNarrow = dw < 700;

        Widget field(String label, TextEditingController ctrl, {int lines = 1, TextInputType? type}) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            TextField(
              controller: ctrl, maxLines: lines, keyboardType: type,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
          ]);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Edit Worker Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ]),
          content: SizedBox(
            width: isNarrow ? 400 : 700,
            child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!isNarrow)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(children: [
                    field('Full Name', nameC),
                    field('Phone Number', phoneC, type: TextInputType.phone),
                    field('CNIC Number', cnicC),
                    // Category dropdown
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('Trade / Service Category', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                          value: selectedCategory, isExpanded: true,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) { if (v != null) setDialogState(() => selectedCategory = v); },
                        )),
                      ),
                      const SizedBox(height: 12),
                    ]),
                  ])),
                  const SizedBox(width: 20),
                  Expanded(child: Column(children: [
                    field('Years of Experience', expC, type: TextInputType.number),
                    field('Rate per Hour (Rs.)', rateC, type: TextInputType.number),
                    field('Service Area', areaC),
                    field('City', cityC),
                  ])),
                ])
              else ...[
                field('Full Name', nameC),
                field('Phone Number', phoneC, type: TextInputType.phone),
                field('CNIC Number', cnicC),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text('Trade / Service Category', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                      value: selectedCategory, isExpanded: true,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) { if (v != null) setDialogState(() => selectedCategory = v); },
                    )),
                  ),
                  const SizedBox(height: 12),
                ]),
                field('Years of Experience', expC, type: TextInputType.number),
                field('Rate per Hour (Rs.)', rateC, type: TextInputType.number),
                field('Service Area', areaC),
                field('City', cityC),
              ],
              const Divider(),
              const SizedBox(height: 8),
              Text('ADMIN INTERNAL NOTES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.deepPurple)),
              const SizedBox(height: 4),
              Text('Only visible to admins. Workers cannot see these notes.', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              field('Notes', notesC, lines: 3),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameC.text,
                  'phone': phoneC.text,
                  'cnic': cnicC.text,
                  'category': selectedCategory,
                  'experience': int.tryParse(expC.text) ?? tech['experience'],
                  'hourlyRate': int.tryParse(rateC.text) ?? tech['hourlyRate'],
                  'area': areaC.text,
                  'city': cityC.text,
                  'adminNotes': notesC.text,
                };

                // Optimistic local update
                setState(() {
                  updatedData.forEach((key, value) {
                    tech[key] = value;
                  });
                });

                await DocumentDatabase.updateTechnician(tech['id'].toString(), updatedData);
                if (mounted) {
                  setState(() {
                    _isConnected = true;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${nameC.text} updated successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      });
    });
  }

  // ─── HELPERS ───
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(bottom: BorderSide(color: Colors.red.shade100)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off, color: Colors.red, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'You are currently offline. New applications may not appear until connection is restored.',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade900),
          ),
        ),
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
      Text('$label: ', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurfaceVariant)),
      Flexible(child: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.onSurface))),
    ]));
  }

  Widget _docRow(String title, String? name, bool hasFile, String? base64, {bool isPdf = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceVariant)),
      child: Row(children: [
        if (hasFile && base64 != null && !isPdf)
          ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 44, height: 44, child: Image.memory(base64Decode(base64.split(',').last), fit: BoxFit.cover)))
        else
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)), child: Icon(isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file, color: isPdf ? Colors.red.shade700 : AppColors.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(hasFile ? (name ?? 'document.jpg') : 'No file (Mock)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontStyle: hasFile ? FontStyle.normal : FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        if (hasFile) IconButton(icon: const Icon(Icons.download, color: AppColors.primary, size: 20), onPressed: () => _downloadFile(base64, name), tooltip: 'Download')
        else Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)), child: Text('MOCK', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey.shade700))),
      ]),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class PulsingDot extends StatefulWidget {
  final Color color;
  const PulsingDot({super.key, required this.color});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.4 * (1.0 - _controller.value)),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
