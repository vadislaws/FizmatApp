import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/book.dart';
import 'package:fizmat_app/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FizBookOnline extends StatefulWidget {
  const FizBookOnline({super.key});

  @override
  State<FizBookOnline> createState() => _FizBookOnlineState();
}

class _FizBookOnlineState extends State<FizBookOnline> {
  List<BookInfo> _allBooks = [];
  List<BookInfo> _filteredBooks = [];
  List<String> _groups = [];
  String? _selectedGroup;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch books from GitHub via BookService
      final allBooks = await BookService.fetchBooks();

      // TEMPORARY: Filter to show only Algebra 7th grade for testing
      final books = allBooks.where((book) {
        // Check if book name contains "Алгебра" or "Algebra" and group is "7"
        final hasAlgebra = book.names.values.any((name) =>
          name.toLowerCase().contains('алгебра') ||
          name.toLowerCase().contains('algebra')
        );
        final isGrade7 = book.group == '7';
        return hasAlgebra && isGrade7;
      }).toList();

      // Extract unique groups and categorize
      final uniqueGroups = BookService.getUniqueGroups(books);

      setState(() {
        _allBooks = books;
        _groups = uniqueGroups;
        _selectedGroup = uniqueGroups.isNotEmpty ? uniqueGroups.first : null;
        _filterBooks();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterBooks() {
    if (_selectedGroup == null) return;

    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredBooks = _allBooks.where((book) {
        // Check group match
        bool groupMatch;
        if (_selectedGroup == 'Others') {
          final gradeNumber = int.tryParse(book.group);
          groupMatch = gradeNumber == null || gradeNumber < 7 || gradeNumber > 11;
        } else {
          groupMatch = book.group == _selectedGroup;
        }

        // Check search match - search in all language names
        final nameMatch = searchQuery.isEmpty ||
                         book.names.values.any((name) => name.toLowerCase().contains(searchQuery));

        return groupMatch && nameMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('books')),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchBooks,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(theme, l10n)
              : _buildBooksList(context, theme, l10n),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('error'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBooks,
              child: Text(l10n.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.translate('search_users'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final group = _groups[index];
              final isSelected = group == _selectedGroup;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getGroupLabel(group, l10n)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGroup = group;
                      _filterBooks();
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Books grid
        Expanded(
          child: _filteredBooks.isEmpty
              ? _buildEmptyState(theme, l10n)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    return _buildBookCard(_filteredBooks[index], theme);
                  },
                ),
        ),
      ],
    );
  }

  String _getGroupLabel(String group, AppLocalizations l10n) {
    if (group == 'Others') {
      return l10n.translate('others');
    }
    return '${l10n.translate('grade_number')} $group';
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('no_events_found'),
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookInfo book, ThemeData theme) {
    final languageCode = AppLocalizations.of(context).locale.languageCode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookViewerScreen(book: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  book.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.getName(languageCode),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookViewerScreen extends StatefulWidget {
  final BookInfo book;

  const BookViewerScreen({super.key, required this.book});

  @override
  State<BookViewerScreen> createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.getName(languageCode)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.book.pdfUrl),
            ),
            initialSettings: InAppWebViewSettings(
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              javaScriptEnabled: true,
              useOnDownloadStart: true,
            ),
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onReceivedError: (controller, request, error) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
