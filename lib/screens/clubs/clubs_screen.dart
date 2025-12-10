import 'package:fizmat_app/data/club_data.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/club_models.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> _allClubs = [];
  List<Club> _filteredClubs = [];
  ClubCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allClubs = ClubData.getAllClubs();
    _filteredClubs = _allClubs;
  }

  void _applyFilters() {
    setState(() {
      _filteredClubs = _allClubs.where((club) {
        // Category filter
        if (_selectedCategory != null && club.category != _selectedCategory) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final clubName = club.name.toLowerCase();
          final leaderName = club.leader.fullName.toLowerCase();

          if (!clubName.contains(query) && !leaderName.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _filteredClubs = _allClubs;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showClubDetails(Club club) {
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Club name
              Text(
                club.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(club.category).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  club.category.getDisplayName(locale.languageCode),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(club.category),
                  ),
                ),
              ),

              if (club.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  club.description!,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              const SizedBox(height: 24),

              // Leader info
              Text(
                locale.languageCode == 'ru'
                    ? 'Руководитель'
                    : locale.languageCode == 'kk'
                        ? 'Жетекші'
                        : 'Club Leader',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          child: Text(
                            club.leader.firstName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                club.leader.fullName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.translate('class_grade')}: ${club.leader.classGrade}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl('tel:${club.leader.phone}'),
                            icon: const Icon(Icons.phone, size: 18),
                            label: Text(club.leader.phone),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Instagram link
              if (club.instagramHandle != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(club.instagramUrl),
                    icon: const FaIcon(FontAwesomeIcons.instagram, size: 20),
                    label: Text(
                      '${locale.languageCode == 'ru' ? 'Открыть Instagram' : locale.languageCode == 'kk' ? 'Instagram-ды ашу' : 'Open Instagram'} (${club.instagramHandle})',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFE1306C), // Instagram color
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ClubCategory category) {
    switch (category) {
      case ClubCategory.academic:
        return Colors.blue;
      case ClubCategory.sports:
        return Colors.green;
      case ClubCategory.artsAndCulture:
        return Colors.purple;
      case ClubCategory.technology:
        return Colors.orange;
      case ClubCategory.social:
        return Colors.teal;
      case ClubCategory.hobbies:
        return Colors.pink;
      case ClubCategory.language:
        return Colors.indigo;
      case ClubCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('clubs')),
        actions: [
          if (_selectedCategory != null || _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: l10n.translate('clear_filters'),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: locale.languageCode == 'ru'
                    ? 'Поиск клуба или руководителя...'
                    : locale.languageCode == 'kk'
                        ? 'Клуб немесе жетекшіні іздеу...'
                        : 'Search club or leader...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),
          ),

          // Category chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // All categories chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l10n.translate('all')),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _applyFilters();
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                ),
                // Category chips
                ...ClubCategory.values.map((category) {
                  // Only show categories that have clubs
                  final hasClubs = _allClubs.any((club) => club.category == category);
                  if (!hasClubs) return const SizedBox.shrink();

                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.getDisplayName(locale.languageCode)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        _applyFilters();
                      },
                      backgroundColor: _getCategoryColor(category).withValues(alpha: 0.1),
                      selectedColor: _getCategoryColor(category).withValues(alpha: 0.3),
                      checkmarkColor: _getCategoryColor(category),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Clubs list/grid
          Expanded(
            child: _filteredClubs.isEmpty
                ? _buildEmptyState(theme, l10n, locale)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredClubs.length,
                    itemBuilder: (context, index) {
                      return _buildClubCard(theme, locale, _filteredClubs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n, Locale locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            locale.languageCode == 'ru'
                ? 'Клубы не найдены'
                : locale.languageCode == 'kk'
                    ? 'Клубтар табылмады'
                    : 'No clubs found',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(ThemeData theme, Locale locale, Club club) {
    final categoryColor = _getCategoryColor(club.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: categoryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showClubDetails(club),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(club.category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Club info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.leader.fullName,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.category.getDisplayName(locale.languageCode),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Instagram indicator
              if (club.instagramHandle != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1306C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Color(0xFFE1306C),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ClubCategory category) {
    switch (category) {
      case ClubCategory.academic:
        return Icons.school;
      case ClubCategory.sports:
        return Icons.fitness_center;
      case ClubCategory.artsAndCulture:
        return Icons.palette;
      case ClubCategory.technology:
        return Icons.computer;
      case ClubCategory.social:
        return Icons.people;
      case ClubCategory.hobbies:
        return Icons.sports_esports;
      case ClubCategory.language:
        return Icons.language;
      case ClubCategory.other:
        return Icons.more_horiz;
    }
  }
}
