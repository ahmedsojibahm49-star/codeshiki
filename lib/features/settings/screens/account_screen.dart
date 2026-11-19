import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/hive_boxes.dart';
import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_prefs.dart';
import '../widgets/settings_row.dart';

/// Account [K02]: name / email / bio + linked accounts + devices.
///
/// Save writes `{name, bio}` to the Hive `auth` box under key `profile` and
/// invalidates [authProvider]. NOTE: [AuthNotifier.build] does not read the
/// `profile` key, so the edited name does NOT visibly reflect anywhere yet —
/// the coordinator needs an `updateProfile` method (or build-time `profile`
/// merge) for that. See the builder report.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  late bool _googleLinked;
  final List<String> _devices = ['This phone · Android', 'Chrome on Windows'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user ?? DemoData.me;
    final savedProfile = HiveBoxes.auth.mapAt('profile');
    _nameController = TextEditingController(
      text: savedProfile?['name'] as String? ?? user.name,
    );
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(
      text: savedProfile?['bio'] as String? ?? user.bio,
    );
    _googleLinked =
        SettingsPrefs.boolPref('pref_googleLinked', defaultValue: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCsToast(context, 'Please enter your name', isError: true);
      return;
    }
    HiveBoxes.auth.put('profile', {
      'name': name,
      'bio': _bioController.text.trim(),
    });
    ref.invalidate(authProvider);
    showCsToast(context, 'Saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final user = ref.watch(authProvider).user ?? DemoData.me;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Account'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: CsAvatar(
              photoAsset: user.avatarPhoto,
              name: user.name,
              size: 88,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Profile photo cannot be changed in the demo.',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
          ),
          const SizedBox(height: 24),
          CsTextField(
            label: context.tr('name'),
            controller: _nameController,
            prefixIcon: AppIcons.user,
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: context.tr('email'),
            controller: _emailController,
            prefixIcon: AppIcons.message,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
          ),
          const SizedBox(height: 6),
          Text(
            'Your email address cannot be changed in the demo.',
            style: AppText.caption.copyWith(color: cs.textTertiary),
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: 'Bio',
            hint: 'Tell others a little about yourself',
            controller: _bioController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          CsButton(label: context.tr('save'), onPressed: _save),
          const SizedBox(height: 28),
          CsSettingsSection(
            title: 'Linked accounts',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.globe,
                title: 'Google',
                subtitle: _googleLinked ? 'Connected' : 'Not connected',
                value: _googleLinked,
                onChanged: (value) {
                  setState(() => _googleLinked = value);
                  SettingsPrefs.setBoolPref('pref_googleLinked', value);
                  showCsToast(
                    context,
                    value
                        ? 'Google account connected'
                        : 'Google account disconnected',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Devices',
            children: [
              for (final device in _devices)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.sunken,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.security,
                          size: 20,
                          color: cs.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          device,
                          style: AppText.body.copyWith(
                            color: cs.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _devices.remove(device));
                          showCsToast(
                            context,
                            'Signed out from $device',
                          );
                        },
                        child: Text(
                          'Sign out',
                          style: AppText.label.copyWith(color: cs.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No other devices signed in.',
                    style: AppText.bodySmall.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
