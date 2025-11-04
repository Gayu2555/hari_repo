import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:recipe_app/services/auth_storage.dart';
import 'package:recipe_app/login.dart';

// ==================== PROFILE SCREEN (Updated with API) ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthStorage.getUser();
    setState(() {
      _userData = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0.h),
                    Text('Profile',
                        style: Theme.of(context).textTheme.displayLarge),
                    SizedBox(height: 4.0.h),
                    ProfileHeader(userData: _userData),
                    ProfileListView(onLogout: _handleLogout),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthStorage.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }
}

class ProfileListView extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileListView({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          ProfileListTile(
            text: 'Account',
            icon: UniconsLine.user_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Settings',
            icon: UniconsLine.setting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'App Info',
            icon: UniconsLine.info_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, indent: 10.0, endIndent: 10.0),
          ProfileListTile(
            text: 'Logout',
            icon: UniconsLine.sign_out_alt,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const ProfileListTile({
    Key? key,
    required this.text,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.headlineSmall),
      horizontalTitleGap: 5.0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      trailing: Icon(
        UniconsLine.angle_right,
        size: 24.0.sp,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileHeader({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? userData?['username'] ?? 'User';
    final email = userData?['email'] ?? 'email@example.com';
    final avatar = userData?['avatar'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar dengan fallback
        Container(
          height: 20.0.h,
          width: 20.0.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: avatar != null && avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAvatarFallback(name, context);
                    },
                  ),
                )
              : _buildAvatarFallback(name, context),
        ),
        const SizedBox(height: 10.0),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5.0),
        Text(
          email,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(String name, BuildContext context) {
    // Ambil inisial dari nama
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// ==================== ACCOUNT SCREEN (Updated) ====================
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthStorage.getUser();
    if (user != null) {
      setState(() {
        _userData = user;
        _nameController.text = user['name'] ?? user['username'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Akun Saya'),
          leading: IconButton(
            icon: const Icon(UniconsLine.arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final avatar = _userData?['avatar'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 2.0.h),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: avatar != null && avatar.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                avatar,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildAvatarInitial();
                                },
                              ),
                            )
                          : _buildAvatarInitial(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(UniconsLine.camera,
                              size: 20, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur upload foto segera hadir'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0.h),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: UniconsLine.user,
                ),
                SizedBox(height: 2.0.h),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: UniconsLine.envelope,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email tidak bisa diubah
                ),
                SizedBox(height: 2.0.h),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  icon: UniconsLine.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 4.0.h),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Perubahan',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial() {
    final name = _nameController.text;
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Text(
      initial,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Future<void> _updateProfile() async {
    // Update user data di local storage
    if (_userData != null) {
      _userData!['name'] = _nameController.text;
      _userData!['phone'] = _phoneController.text;

      await AuthStorage.saveUser(_userData!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profil berhasil diperbarui'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Kembali ke profile screen
        Navigator.pop(context);
      }
    }
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayVideos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Umum'),
          _buildSwitchTile(
            title: 'Notifikasi',
            subtitle: 'Terima notifikasi resep baru',
            icon: UniconsLine.bell,
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            title: 'Mode Gelap',
            subtitle: 'Aktifkan tema gelap',
            icon: UniconsLine.moon,
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildSwitchTile(
            title: 'Putar Video Otomatis',
            subtitle: 'Video diputar otomatis',
            icon: UniconsLine.play_circle,
            value: _autoPlayVideos,
            onChanged: (value) => setState(() => _autoPlayVideos = value),
          ),
          SizedBox(height: 2.0.h),
          _buildSectionTitle('Privasi'),
          _buildListTile(
            title: 'Ubah Kata Sandi',
            icon: UniconsLine.lock,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ubah password segera hadir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildListTile(
            title: 'Kebijakan Privasi',
            icon: UniconsLine.shield_check,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur privacy policy segera hadir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          SizedBox(height: 2.0.h),
          _buildSectionTitle('Lainnya'),
          _buildListTile(
            title: 'Bahasa',
            icon: UniconsLine.language,
            trailing: 'Indonesia',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur pilih bahasa segera hadir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildListTile(
            title: 'Hapus Cache',
            icon: UniconsLine.trash,
            onTap: () {
              _showClearCacheDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Theme.of(context).iconTheme.color),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        trailing: trailing != null
            ? Text(trailing, style: TextStyle(color: Colors.grey.shade600))
            : Icon(UniconsLine.angle_right,
                color: Theme.of(context).iconTheme.color),
        onTap: onTap,
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Cache'),
          content: const Text('Apakah Anda yakin ingin menghapus semua cache?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

// ==================== APP INFO SCREEN ====================
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Aplikasi'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 2.0.h),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                UniconsLine.restaurant,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 3.0.h),
            Text(
              'Recipe App',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.0.h),
            Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.info_circle,
              title: 'Tentang Aplikasi',
              description:
                  'Recipe App adalah aplikasi untuk menemukan dan menyimpan resep makanan favorit Anda. Jelajahi berbagai resep dari seluruh dunia.',
            ),
            SizedBox(height: 2.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.user_circle,
              title: 'Developer',
              description: 'Dikembangkan oleh Gayu Yunma Ramadhan',
            ),
            SizedBox(height: 2.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.envelope,
              title: 'Kontak',
              description: 'support@recipeapp.com',
            ),
            SizedBox(height: 4.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.file_alt,
              text: 'Syarat & Ketentuan',
              onTap: () {},
            ),
            SizedBox(height: 1.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.shield_check,
              text: 'Kebijakan Privasi',
              onTap: () {},
            ),
            SizedBox(height: 1.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.star,
              text: 'Beri Rating di Play Store',
              onTap: () {},
            ),
            SizedBox(height: 4.0.h),
            Text(
              '© 2024 Recipe App. All rights reserved.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            Icon(
              UniconsLine.angle_right,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}
