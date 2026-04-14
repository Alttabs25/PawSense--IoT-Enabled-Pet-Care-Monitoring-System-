import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _olive = Color(0xFFA4B189);
  static const Color _softGray = Color(0xFFD3D3D3);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _petNameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.authService.currentUser?.name ?? '');
    _petNameController = TextEditingController(
      text: widget.authService.currentUser?.petName ?? '',
    );
    widget.authService.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _petNameController.dispose();
    widget.authService.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    final user = widget.authService.currentUser;
    if (user == null) {
      return;
    }

    _nameController.text = user.name;
    _petNameController.text = user.petName;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showEditDialog() async {
    final user = widget.authService.currentUser;
    if (user == null) {
      return;
    }

    _nameController.text = user.name;
    _petNameController.text = user.petName;

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _petNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pet name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _olive),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(this.context);

                          setDialogState(() => isSaving = true);

                          final success = await widget.authService.updateProfile(
                            name: _nameController.text.trim(),
                            petName: _petNameController.text.trim(),
                          );

                          if (!mounted) {
                            return;
                          }

                          setDialogState(() => isSaving = false);

                          if (success) {
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.authService.errorMessage ??
                                      'Failed to update profile.',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendPasswordReset() async {
    final success = await widget.authService.sendPasswordResetEmail();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Password reset email sent.'
              : (widget.authService.errorMessage ??
                    'Failed to send password reset email.'),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _olive),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    final pet = user.petProfile;

    return RefreshIndicator(
      onRefresh: widget.authService.reloadCurrentUser,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            color: _softGray,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: _olive,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    label: 'Display Name',
                    value: user.name,
                  ),
                  const Divider(height: 0),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(height: 0),
                  _buildInfoTile(
                    icon: Icons.pets_outlined,
                    label: 'Pet Name',
                    value: user.petName,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Pet Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Breed',
                    value: pet?.breed ?? 'Not set',
                  ),
                  const Divider(height: 0),
                  _buildInfoTile(
                    icon: Icons.cake_outlined,
                    label: 'Age Category',
                    value: pet?.ageCategory ?? 'Not set',
                  ),
                  const Divider(height: 0),
                  _buildInfoTile(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: pet == null
                        ? 'Not set'
                        : '${pet.weight.toStringAsFixed(1)} ${pet.weightUnit}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            style: FilledButton.styleFrom(
              backgroundColor: _olive,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _sendPasswordReset,
            icon: const Icon(Icons.lock_reset_outlined),
            label: const Text('Send Password Reset Email'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh profile data from Firestore.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (widget.authService.errorMessage != null)
            Text(
              widget.authService.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
