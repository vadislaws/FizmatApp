import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SATScreen extends StatelessWidget {
  const SATScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('sat_preparation')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          _buildHeader(theme, l10n),
          const SizedBox(height: 24),

          // What is SAT
          _buildSection(
            theme,
            l10n,
            'what_is_sat',
            'sat_description',
          ),
          const SizedBox(height: 20),

          // Scoring
          _buildSection(
            theme,
            l10n,
            'scoring',
            'sat_scoring',
          ),
          const SizedBox(height: 20),

          // Test Dates 2025
          _buildSection(
            theme,
            l10n,
            'test_dates_2025',
            'sat_dates',
          ),
          const SizedBox(height: 20),

          // Test Centers
          _buildSection(
            theme,
            l10n,
            'test_centers',
            'sat_centers',
          ),
          const SizedBox(height: 20),

          // Cost
          _buildSection(
            theme,
            l10n,
            'cost',
            'sat_cost',
          ),
          const SizedBox(height: 24),

          // Official Links
          Text(
            l10n.translate('official_resources'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildLinkCard(theme, l10n, 'official_sat_website', 'https://satsuite.collegeboard.org'),
          _buildLinkCard(theme, l10n, 'register_sat', 'https://my.collegeboard.org'),
          _buildLinkCard(theme, l10n, 'bluebook_app', 'https://bluebook.collegeboard.org'),
          _buildLinkCard(theme, l10n, 'khan_academy', 'https://www.khanacademy.org/sat'),
          const SizedBox(height: 24),

          // Preparation Tips
          Text(
            l10n.translate('preparation_tips'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipsCard(theme, l10n),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.translate('sat_preparation'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('sat_subtitle'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, AppLocalizations l10n, String titleKey, String contentKey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate(titleKey),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate(contentKey),
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(ThemeData theme, AppLocalizations l10n, String titleKey, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.link,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          l10n.translate(titleKey),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme, AppLocalizations l10n) {
    final tips = [
      l10n.translate('sat_tip_1'),
      l10n.translate('sat_tip_2'),
      l10n.translate('sat_tip_3'),
      l10n.translate('sat_tip_4'),
      l10n.translate('sat_tip_5'),
      l10n.translate('sat_tip_6'),
      l10n.translate('sat_tip_7'),
      l10n.translate('sat_tip_8'),
      l10n.translate('sat_tip_9'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
