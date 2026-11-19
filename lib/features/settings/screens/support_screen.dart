import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Contact support [K17]: topic chips + message field. Sending is a demo
/// action (toast + pop) — there is no backend in the demo.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const List<String> _topics = [
    'Payment',
    'Lesson',
    'Account',
    'Bug',
    'Other',
  ];

  final _messageController = TextEditingController();
  String _topic = 'Payment';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    if (_messageController.text.trim().isEmpty) {
      showCsToast(context, 'Please write your message first', isError: true);
      return;
    }
    showCsToast(context, "Message sent — we'll reply within 24 hours");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('contactSupport')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Tell us what is going on and we will get back to you.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(
            'TOPIC',
            style: AppText.caption.copyWith(
              color: cs.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final topic in _topics)
                CsFilterChip(
                  label: topic,
                  selected: _topic == topic,
                  onTap: () => setState(() => _topic = topic),
                ),
            ],
          ),
          const SizedBox(height: 20),
          CsTextField(
            label: 'Your message',
            hint: 'Describe your issue in detail…',
            controller: _messageController,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          CsButton(label: 'Send message', onPressed: _send),
        ],
      ),
    );
  }
}
