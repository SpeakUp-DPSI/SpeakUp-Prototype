import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/admin_user_model.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _selectedRole = '';  // '' = Semua Role

  static const _roleFilters = [
    {'value': '', 'label': 'Semua Role'},
    {'value': 'siswa', 'label': 'Siswa'},
    {'value': 'guru_bk', 'label': 'Guru BK'},
    {'value': 'kepsek', 'label': 'Kepsek'},
    {'value': 'orangtua', 'label': 'Orang Tua'},
    {'value': 'admin', 'label': 'Admin'},
  ];

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _searchQuery = v.trim().toLowerCase());
    });
  }

  List<AdminUserModel> _applyFilters(List<AdminUserModel> all) {
    var result = all;
    if (_selectedRole.isNotEmpty) {
      result = result
          .where((u) => u.roles.contains(_selectedRole))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((u) =>
              u.name.toLowerCase().contains(_searchQuery) ||
              u.email.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(adminUsersProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildHeader(context),
                ),
              ),

              // ── Search + dropdown ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _buildSearchRow(),
                ),
              ),

              // ── Count label ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: usersAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (all) {
                    final filtered = _applyFilters(all);
                    return Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 10, 16, 2),
                      child: Text(
                        '${filtered.length} pengguna',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── User list ─────────────────────────────────────────────────
              usersAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _ErrorState(message: '$e'),
                ),
                data: (all) {
                  final filtered = _applyFilters(all);
                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      child: _EmptyState(),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final isLast = i == filtered.length - 1;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                              16, 0, 16, isLast ? 32 : 0),
                          child: _UserCard(
                            user: filtered[i],
                            onEdit: () =>
                                _openUserForm(context, user: filtered[i]),
                            onDelete: () =>
                                _confirmDelete(context, filtered[i]),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen Pengguna',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola akun pengguna sistem SpeakUp',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.neutral500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _openUserForm(context),
          icon: const Icon(Icons.person_add_outlined, size: 17),
          label: const Text('Tambah'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary600,
            side: const BorderSide(color: AppTheme.primary600, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ── Search + Role filter ─────────────────────────────────────────────────────

  Widget _buildSearchRow() {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neutral300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search,
                    color: AppTheme.neutral400, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.neutral900),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau email',
                      hintStyle: TextStyle(
                          color: AppTheme.neutral400, fontSize: 13),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 13),
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close,
                        size: 16, color: AppTheme.neutral400),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Role dropdown
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.neutral300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppTheme.neutral500),
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.neutral700,
                  fontWeight: FontWeight.w500),
              items: _roleFilters.map((f) {
                return DropdownMenuItem<String>(
                  value: f['value']!,
                  child: Text(f['label']!),
                );
              }).toList(),
              onChanged: (v) =>
                  setState(() => _selectedRole = v ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  // ── Dialog tambah / edit ─────────────────────────────────────────────────────

  void _openUserForm(BuildContext context, {AdminUserModel? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserFormSheet(
        existingUser: user,
        onSubmit: (data) async {
          try {
            if (user == null) {
              await ref
                  .read(adminUsersProvider.notifier)
                  .createUser(data);
            } else {
              await ref
                  .read(adminUsersProvider.notifier)
                  .updateUser(user.id, data);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(user == null
                      ? 'Pengguna berhasil ditambahkan'
                      : 'Pengguna berhasil diperbarui'),
                  backgroundColor: AppTheme.success600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal: $e'),
                  backgroundColor: AppTheme.danger600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // ── Dialog hapus ─────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, AdminUserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Pengguna?',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.neutral900),
        ),
        content: Text(
          'Akun "${user.name}" (${user.email}) akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
              fontSize: 13, color: AppTheme.neutral600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.neutral600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(adminUsersProvider.notifier)
                    .deleteUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Pengguna "${user.name}" berhasil dihapus'),
                      backgroundColor: AppTheme.success600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: AppTheme.danger600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = user.emailVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _roleColor(user.primaryRole).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _roleColor(user.primaryRole),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + role chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.neutral900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _RoleChip(role: user.primaryRole, label: user.roleLabel),
                  ],
                ),
                const SizedBox(height: 3),

                // Email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutral500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Status badge
                _VerifiedBadge(verified: isVerified),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Aksi ──────────────────────────────────────────────────────
          Column(
            children: [
              _IconAction(
                icon: Icons.edit_outlined,
                color: AppTheme.info600,
                tooltip: 'Edit pengguna',
                onTap: onEdit,
              ),
              const SizedBox(height: 4),
              _IconAction(
                icon: Icons.delete_outline,
                color: AppTheme.danger600,
                tooltip: 'Hapus pengguna',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.danger600;
      case 'kepsek':
        return const Color(0xFF0D2149); // navy — sama dengan stat card principal
      case 'guru_bk':
        return AppTheme.primary600;
      case 'orangtua':
        return AppTheme.purple600;
      default:
        return AppTheme.neutral500;
    }
  }
}

// ─── Small widgets ────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String role;
  final String label;
  const _RoleChip({required this.role, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary200),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary600,
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool verified;
  const _VerifiedBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: verified
            ? AppTheme.success100
            : AppTheme.warning100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.verified_outlined
                : Icons.schedule_outlined,
            size: 11,
            color: verified
                ? AppTheme.success600
                : AppTheme.warning600,
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'Aktif' : 'Belum Verifikasi',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: verified
                  ? AppTheme.success600
                  : AppTheme.warning600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ─── User Form Bottom Sheet ───────────────────────────────────────────────────

class _UserFormSheet extends ConsumerStatefulWidget {
  final AdminUserModel? existingUser;
  final Future<void> Function(Map<String, dynamic>) onSubmit;

  const _UserFormSheet({
    this.existingUser,
    required this.onSubmit,
  });

  @override
  ConsumerState<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  String _selectedRole = 'siswa';
  bool _isLoading = false;

  static const _roles = [
    {'value': 'siswa', 'label': 'Siswa'},
    {'value': 'guru_bk', 'label': 'Guru BK'},
    {'value': 'kepsek', 'label': 'Kepsek'},
    {'value': 'orangtua', 'label': 'Orang Tua'},
    {'value': 'admin', 'label': 'Admin'},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.existingUser?.name ?? '');
    _emailCtrl = TextEditingController(
        text: widget.existingUser?.email ?? '');
    _passwordCtrl = TextEditingController();
    _selectedRole =
        widget.existingUser?.primaryRole ?? 'siswa';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingUser != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral900,
            ),
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Nama
                _formField(
                  controller: _nameCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                // Email
                _formField(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password (only required on create)
                _formField(
                  controller: _passwordCtrl,
                  label: isEdit ? 'Password Baru (opsional)' : 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: isEdit
                      ? null
                      : (v) => v == null || v.length < 6
                          ? 'Password minimal 6 karakter'
                          : null,
                ),
                const SizedBox(height: 12),

                // Role dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutral300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          size: 18, color: AppTheme.neutral500),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.neutral900),
                            icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppTheme.neutral500),
                            items: _roles.map((r) {
                              return DropdownMenuItem<String>(
                                value: r['value'],
                                child: Text(r['label']!),
                              );
                            }).toList(),
                            onChanged: (v) => setState(
                                () => _selectedRole = v ?? 'siswa'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Pengguna',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppTheme.neutral900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, color: AppTheme.neutral500),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.neutral400),
        filled: true,
        fillColor: AppTheme.neutral50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.neutral300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.neutral300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primary600, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.danger600)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        isDense: true,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'roles': [_selectedRole],
      };
      if (_passwordCtrl.text.isNotEmpty) {
        data['password'] = _passwordCtrl.text;
      }
      await widget.onSubmit(data);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.people_outline,
                  size: 36, color: AppTheme.neutral400),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pengguna',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tambahkan pengguna pertama menggunakan\ntombol "+ Tambah" di atas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off,
                size: 48, color: AppTheme.neutral300),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.neutral500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Endpoint belum tersedia di backend.',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.warning600,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
