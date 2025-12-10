import 'package:fizmat_app/data/formula_data.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/formula_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FizFormula extends StatefulWidget {
  const FizFormula({super.key});

  @override
  State<FizFormula> createState() => _FizFormulaState();
}

class _FizFormulaState extends State<FizFormula> {
  List<Formula> _allFormulas = [];
  List<Formula> _filteredFormulas = [];

  // Filter state
  FormulaSubject? _selectedSubject;
  String? _selectedTopic;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allFormulas = FormulaData.getAllFormulas();
    _filteredFormulas = _allFormulas;
  }

  void _applyFilters() {
    setState(() {
      _filteredFormulas = _allFormulas.where((formula) {
        // Subject filter
        if (_selectedSubject != null && formula.subject != _selectedSubject) {
          return false;
        }

        // Topic filter
        if (_selectedTopic != null && formula.topic != _selectedTopic) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final locale = Localizations.localeOf(context);
          final name = formula.getName(locale.languageCode).toLowerCase();
          final description = formula.getDescription(locale.languageCode)?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();

          if (!name.contains(query) && !description.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedTopic = null;
      _searchQuery = '';
      _filteredFormulas = _allFormulas;
    });
  }

  List<String> _getAvailableTopics() {
    if (_selectedSubject == null) {
      return _allFormulas.map((f) => f.topic).toSet().toList()..sort();
    }
    return FormulaData.getTopicsForSubject(_selectedSubject!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('formulas')),
        actions: [
          if (_selectedSubject != null || _selectedTopic != null || _searchQuery.isNotEmpty)
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
          _buildSearchBar(theme, l10n),

          // Filter chips
          _buildFilterChips(theme, l10n, locale),

          // Formulas list
          Expanded(
            child: _filteredFormulas.isEmpty
                ? _buildEmptyState(theme, l10n)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFormulas.length,
                    itemBuilder: (context, index) {
                      return _buildFormulaCard(
                        theme,
                        l10n,
                        locale,
                        _filteredFormulas[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: '${l10n.translate('filter')}...',
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
    );
  }

  Widget _buildFilterChips(ThemeData theme, AppLocalizations l10n, Locale locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject filter
          Text(
            l10n.translate('subjects'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FormulaSubject.values.map((subject) {
              final isSelected = _selectedSubject == subject;
              String subjectName;
              switch (locale.languageCode) {
                case 'ru':
                  subjectName = subject.displayNameRu;
                  break;
                case 'kk':
                  subjectName = subject.displayNameKk;
                  break;
                default:
                  subjectName = subject.displayName;
              }

              return FilterChip(
                label: Text(subjectName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSubject = selected ? subject : null;
                    _selectedTopic = null; // Reset topic when subject changes
                  });
                  _applyFilters();
                },
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                checkmarkColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),

          // Topic filter (only show if subject is selected)
          if (_selectedSubject != null) ...[
            const SizedBox(height: 16),
            Text(
              'Topic',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getAvailableTopics().map((topic) {
                final isSelected = _selectedTopic == topic;
                return FilterChip(
                  label: Text(topic),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTopic = selected ? topic : null;
                    });
                    _applyFilters();
                  },
                  selectedColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  checkmarkColor: theme.colorScheme.secondary,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.functions,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No formulas found',
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

  Widget _buildFormulaCard(
    ThemeData theme,
    AppLocalizations l10n,
    Locale locale,
    Formula formula,
  ) {
    final name = formula.getName(locale.languageCode);
    final description = formula.getDescription(locale.languageCode);

    Color subjectColor;
    switch (formula.subject) {
      case FormulaSubject.mathematics:
        subjectColor = Colors.blue;
        break;
      case FormulaSubject.physics:
        subjectColor = Colors.green;
        break;
      case FormulaSubject.chemistry:
        subjectColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: subjectColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formula.topic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subjectColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Formula name
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Formula (LaTeX rendered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    formula.formulaLatex,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            // Description (if available)
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
