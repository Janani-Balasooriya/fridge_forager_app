import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/hive_service.dart';
import '../../logic/auth_notifier.dart';
import '../../logic/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _hiveService = HiveService();
  bool _isEditing = false;
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadUserData(String uid) {
    final user = _hiveService.getUser(uid);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _locationController.text = user.location ?? '';
      _bioController.text = user.bio ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _selectedGender = user.gender;
    } else if (firebaseUser?.displayName != null) {
      _nameController.text = firebaseUser!.displayName!;
    }
  }

  void _handleSaveProfile(String uid) async {
    final user = _hiveService.getUser(uid);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (_nameController.text.isNotEmpty) {
      await firebaseUser?.updateDisplayName(_nameController.text);

      final updatedUser = (user ??
              UserModel(
                uid: uid,
                email: firebaseUser?.email ?? '',
                name: _nameController.text,
                createdAt: DateTime.now(),
              ))
          .copyWith(
        name: _nameController.text,
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        age: _ageController.text.isEmpty
            ? null
            : int.tryParse(_ageController.text),
        gender: _selectedGender,
        updatedAt: DateTime.now(),
      );

      await _hiveService.saveUser(updatedUser);

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(authNotifierProvider.notifier).logout();
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed')),
          );
        }
      }
    }
  }

  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content:
            const Text('A password reset link will be sent to your email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: user!.email!,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing && currentUser != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
                _loadUserData(currentUser.uid);
              },
            ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Not logged in'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          final cachedUser = _hiveService.getUser(user.uid);
          final displayName = cachedUser?.name ?? user.displayName ?? 'User';
          final email = user.email ?? 'Not available';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Text(
                              displayName.characters.first.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditing) ...[
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.wc),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Prefer not to say',
                                child: Text('Prefer not to say'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedGender = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              prefixIcon: Icon(Icons.description),
                              hintText: 'Tell us about yourself',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _handleSaveProfile(user.uid),
                            icon: const Icon(Icons.check),
                            label: const Text('Save Changes'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _isEditing = false),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: email,
                          onTap: null,
                        ),
                        _SettingsTile(
                          icon: Icons.calendar_today,
                          title: 'Member Since',
                          subtitle: cachedUser?.createdAt != null
                              ? _formatDate(cachedUser!.createdAt)
                              : _formatDate(
                                  user.metadata.creationTime ?? DateTime.now()),
                          onTap: null,
                        ),
                        if (cachedUser?.age != null)
                          _SettingsTile(
                            icon: Icons.cake,
                            title: 'Age',
                            subtitle: cachedUser!.age.toString(),
                            onTap: null,
                          ),
                        if (cachedUser?.gender != null)
                          _SettingsTile(
                            icon: Icons.wc,
                            title: 'Gender',
                            subtitle: cachedUser!.gender!,
                            onTap: null,
                          ),
                        if (cachedUser?.phoneNumber != null)
                          _SettingsTile(
                            icon: Icons.phone,
                            title: 'Phone',
                            subtitle: cachedUser!.phoneNumber!,
                            onTap: null,
                          ),
                        if (cachedUser?.location != null)
                          _SettingsTile(
                            icon: Icons.location_on,
                            title: 'Location',
                            subtitle: cachedUser!.location!,
                            onTap: null,
                          ),
                        if (cachedUser?.bio != null)
                          _SettingsTile(
                            icon: Icons.description,
                            title: 'Bio',
                            subtitle: cachedUser!.bio!,
                            onTap: null,
                          ),
                        _SettingsTile(
                          icon: Icons.lock,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: _handleChangePassword,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
      ),
    );
  }
}
