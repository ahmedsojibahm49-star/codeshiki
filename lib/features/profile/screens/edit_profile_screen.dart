import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/hive_boxes.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Edit profile [H09]. Saves to Hive `auth` box key `profile` and
/// invalidates [authProvider] so the UI refreshes.
///
/// NOTE: whether the profile UI visibly updates after save depends on
/// AuthNotifier reading the `profile` key — see the builder report.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _avatarOptions = [
    'assets/photos/person-male-park.jpg',
    'assets/photos/person-male-cap.jpg',
    'assets/photos/person-male-glasses.jpg',
    'assets/photos/dhaka-student-male.jpg',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late String _avatarPhoto;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user ?? DemoData.me;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _avatarPhoto = user.avatarPhoto.isNotEmpty
        ? user.avatarPhoto
        : _avatarOptions.first;
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      'avatarPhoto': _avatarPhoto,
    });
    ref.invalidate(authProvider);
    showCsToast(context, 'Profile updated');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    assert(_initialized);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Edit profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            'Profile photo',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _avatarOptions.map((asset) {
              final selected = asset == _avatarPhoto;
              return GestureDetector(
                onTap: () => setState(() => _avatarPhoto = asset),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: cs.primary, width: 3)
                            : null,
                      ),
                      child: CsAvatar(
                        photoAsset: asset,
                        name: 'Avatar',
                        size: 64,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            AppIcons.check,
                            size: 12,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          CsTextField(
            label: 'Name',
            hint: 'Your full name',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          CsTextField(
            label: 'Bio',
            hint: 'Tell the community about yourself…',
            controller: _bioController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          CsButton(label: 'Save changes', onPressed: _save),
        ],
      ),
    );
  }
}
