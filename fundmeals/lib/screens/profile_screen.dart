import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(text: authProvider.user?.name ?? '');
    _emailController = TextEditingController(text: authProvider.user?.email ?? '');
    _phoneController = TextEditingController(text: authProvider.user?.phone ?? '');
    _addressController = TextEditingController(text: authProvider.user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleUpdateProfile(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    });

    if (!mounted) return;

    Navigator.pop(context); // Close bottom sheet

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Gagal memperbarui profil'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nomor Telepon',
                  hint: 'Masukkan nomor telepon',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Alamat Pengiriman',
                  hint: 'Masukkan alamat pengiriman',
                  controller: _addressController,
                  maxLines: 3,
                  minLines: 3,
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return AppButton(
                      label: 'Simpan Perubahan',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleUpdateProfile(context),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Bahasa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                title: const Text('Bahasa Indonesia'),
                trailing: const Icon(Icons.check_circle, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('English language will be supported soon!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrenciesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Mata Uang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: const Text('Rupiah (IDR)'),
                trailing: const Icon(Icons.check_circle, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tampilan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_rounded, color: Colors.orange),
                    title: const Text('Mode Terang'),
                    trailing: !themeProvider.isDarkMode ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () {
                      themeProvider.toggleTheme(false);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.nightlight_round, color: Colors.grey),
                    title: const Text('Mode Gelap'),
                    trailing: themeProvider.isDarkMode ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () {
                      themeProvider.toggleTheme(true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSecuritySheet(BuildContext context) {
    bool is2faEnabled = StorageService.getBool('is2faEnabled') ?? false;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keamanan Aplikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Autentikasi Biometrik (Sidik Jari/Wajah)'),
                    value: true,
                    activeColor: AppColors.primary,
                    onChanged: (val) {},
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SwitchListTile(
                        title: const Text('Verifikasi 2 Langkah (2FA)'),
                        subtitle: const Text('Gunakan Authenticator'),
                        value: is2faEnabled,
                        activeColor: AppColors.primary,
                        onChanged: authProvider.isLoading
                            ? null
                            : (val) async {
                                if (val) {
                                  final success = await authProvider.enable2FA();
                                  if (success && authProvider.twoFactorSecret != null) {
                                    setStateModal(() => is2faEnabled = val);
                                    await StorageService.saveBool('is2faEnabled', val);
                                    if (context.mounted) {
                                      _show2FASecretDialog(context, authProvider.twoFactorSecret!);
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(authProvider.error ?? 'Gagal mengaktifkan 2FA')),
                                      );
                                    }
                                  }
                                } else {
                                  final success = await authProvider.disable2FA();
                                  if (success) {
                                    setStateModal(() => is2faEnabled = val);
                                    await StorageService.saveBool('is2faEnabled', val);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('2FA (Authenticator) dinonaktifkan!')),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(authProvider.error ?? 'Gagal menonaktifkan 2FA')),
                                      );
                                    }
                                  }
                                }
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _show2FASecretDialog(BuildContext context, String secret) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Setup 2FA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kode rahasia ini ke aplikasi Google Authenticator Anda:'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  secret,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Simpan kode ini baik-baik. Anda tidak akan bisa melihatnya lagi.',
                style: TextStyle(color: AppColors.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showManageDevicesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Perangkat Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone_android, color: AppColors.primary),
                title: const Text('Perangkat Ini'),
                subtitle: const Text('Sedang aktif'),
                trailing: const Text('Online', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.computer, color: Colors.grey),
                title: const Text('Windows PC'),
                subtitle: const Text('Terakhir aktif: Kemarin'),
                trailing: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ganti Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password Lama', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: AppColors.success));
                  },
                  child: const Text('Simpan Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Akun', style: TextStyle(color: AppColors.error)),
          content: const Text(
            'Apakah Anda yakin ingin menghapus akun ini secara permanen? '
            'Semua data Anda akan dihapus dari server dan tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.deleteAccount();
                
                if (!mounted) return;
                
                if (success) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun berhasil dihapus secara permanen.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.error ?? 'Gagal menghapus akun.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? AppColors.error : const Color(0xFF1E293B),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.error : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDestructive ? AppColors.error.withOpacity(0.5) : const Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background Gradient (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    const Color(0xFFFAFAFA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button & Title
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black),
                      onPressed: () {}, // Since this is a tab, back button might just be visual, or we can leave it empty
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gray200,
                                image: authProvider.user?.profileImage != null
                                    ? DecorationImage(
                                        image: NetworkImage(authProvider.user!.profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: authProvider.user?.profileImage == null
                                  ? const Icon(Icons.person, size: 40, color: AppColors.textTertiary)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              authProvider.user?.name ?? 'Pengguna',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text(
                              'Anggota Terverifikasi',
                              style: TextStyle(
                                fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•', style: TextStyle(color: AppColors.textTertiary)),
                                ),
                                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                const Text(
                                  'Indonesia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () => _showEditProfileSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Menu Options
                  _buildMenuTile(
                    icon: Icons.language_rounded,
                    title: 'Bahasa',
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.payments_outlined,
                    title: 'Mata Uang',
                    onTap: () => _showCurrenciesDialog(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.palette_outlined,
                    title: 'Tampilan',
                    onTap: () => _showAppearanceDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.security_outlined,
                    title: 'Keamanan Aplikasi',
                    onTap: () => _showSecuritySheet(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.devices_outlined,
                    title: 'Kelola Perangkat',
                    onTap: () => _showManageDevicesSheet(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    onTap: () => _handleLogout(context),
                    isDestructive: true,
                  ),
                  _buildMenuTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Hapus Akun Permanen',
                    onTap: () => _handleDeleteAccount(context),
                    isDestructive: true,
                  ),

                  const SizedBox(height: 100), // Spacing for bottom navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
