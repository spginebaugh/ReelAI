import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/auth/providers/user_provider.dart';
import 'package:reel_ai/features/auth/providers/auth_provider.dart';
import 'package:reel_ai/common/widgets/error_text.dart';
import 'package:reel_ai/common/theme/app_theme.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authController = ref.watch(authControllerProvider.notifier);
    final usernameController = useTextEditingController();
    final bioController = useTextEditingController();
    final errorMessage = useState<String?>(null);

    // Update controllers when user changes
    useEffect(() {
      if (userAsync.value != null) {
        usernameController.text = userAsync.value!.username;
        bioController.text = userAsync.value!.bio ?? '';
      }
      return null;
    }, [userAsync.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
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
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await authController.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => user == null
            ? const Center(
                child: Text(
                  'No user found',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (errorMessage.value != null)
                    ErrorText(message: errorMessage.value!),
                  Card(
                    color: AppColors.lightBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.surfaceColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          InfoTile(
                            label: 'Email',
                            value: user.email,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: bioController,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              border: OutlineInputBorder(),
                              hintText: 'Tell us about yourself',
                            ),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () async {
                                errorMessage.value = null;
                                final newUsername =
                                    usernameController.text.trim();
                                final newBio = bioController.text.trim();

                                if (newUsername.isEmpty) {
                                  errorMessage.value =
                                      'Username cannot be empty';
                                  return;
                                }

                                if (newUsername != user.username ||
                                    newBio != user.bio) {
                                  try {
                                    await ref
                                        .read(userNotifierProvider.notifier)
                                        .updateProfile(
                                          username: newUsername,
                                          bio: newBio.isEmpty ? null : newBio,
                                        );
                                  } catch (e) {
                                    if (context.mounted) {
                                      errorMessage.value =
                                          'Error: ${e.toString()}';
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: ErrorText(
            message: error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value),
    );
  }
}
