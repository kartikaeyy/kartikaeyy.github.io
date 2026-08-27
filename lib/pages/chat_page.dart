import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/actions.dart';
import '../widgets/reveal.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    return Container(
      color: pal.background,
      child: ContentFrame(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Reveal(
              child: Center(child: Eyebrow(label: 'Contact')),
            ),
            SizedBox(height: isMobile ? Space.md : Space.md),
            Reveal(
              delay: const Duration(milliseconds: 60),
              child: SectionTitle(
               "Let's build something",
                align: TextAlign.center,
                minSize: 36,
                maxSize: 66,
              ),
            ),
            SizedBox(height: isMobile ? Space.md : Space.md),
            Reveal(
              delay: const Duration(milliseconds: 60),
              child: SectionTitle(
               "COOL!",
                align: TextAlign.center,
                minSize: 36,
                maxSize: 66,
              ),
            ),
            SizedBox(height: isMobile ? Space.xl : 56),
            const Reveal(
              delay: Duration(milliseconds: 180),
              child: _PrimaryContactActions(),
            ),
            SizedBox(height: isMobile ? Space.xl : 64), 
          ],
        ),
      ),
    );
  }
}

class _PrimaryContactActions extends StatelessWidget {
  const _PrimaryContactActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 14,
      children: [
        ActionButton(
          label: 'Say hello',
          icon: Icons.arrow_outward_rounded,
          onPressed: () => launchUrl(Uri.parse('mailto:$kEmail')),
          tooltip: kEmail,
        ),
      ],
    );
  }
}