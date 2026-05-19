import 'package:cached_network_image/cached_network_image.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/models/book.dart';
import 'package:fizmat_app/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  String _selectedLanguage = 'kk';
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
      final allBooks = await BookService.fetchBooks();

      final books = allBooks.where((book) {
        final gradeNumber = int.tryParse(book.group);
        return gradeNumber != null && gradeNumber >= 7 && gradeNumber <= 11;
      }).toList();

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
        bool groupMatch;
        if (_selectedGroup == 'Others') {
          final gradeNumber = int.tryParse(book.group);
          groupMatch = gradeNumber == null || gradeNumber < 7 || gradeNumber > 11;
        } else {
          groupMatch = book.group == _selectedGroup;
        }
        final langMatch = book.language == _selectedLanguage;
        final nameMatch = searchQuery.isEmpty ||
            book.names.values.any((name) => name.toLowerCase().contains(searchQuery));
        return groupMatch && langMatch && nameMatch;
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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _LangToggleButton(
                  label: 'Қазақша',
                  selected: _selectedLanguage == 'kk',
                  onTap: () => setState(() {
                    _selectedLanguage = 'kk';
                    _filterBooks();
                  }),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LangToggleButton(
                  label: 'Русский',
                  selected: _selectedLanguage == 'ru',
                  onTap: () => setState(() {
                    _selectedLanguage = 'ru';
                    _filterBooks();
                  }),
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.translate('search_users'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _searchController.clear,
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
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
                  onSelected: (_) {
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
    if (group == 'Others') return l10n.translate('others');
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookViewerScreen(book: book)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _BookCoverImage(book: book),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.getName(languageCode),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
  late final WebViewController _controller;
  double _progress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p / 100.0;
              if (p == 100) _isLoading = false;
            });
          }
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.book.pdfUrl));
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = AppLocalizations.of(context).locale.languageCode;
    final title = widget.book.getName(languageCode);

    if (widget.book.pdfUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: const Center(child: Text('Ссылка на учебник недоступна')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        centerTitle: true,
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _BookCoverImage extends StatelessWidget {
  final BookInfo book;
  const _BookCoverImage({required this.book});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    final iconColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    final url = book.image.isNotEmpty ? book.image : book.s3ImageUrl;

    if (url.isEmpty) {
      return Container(color: color, child: Icon(Icons.book, size: 48, color: iconColor));
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: color,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) =>
          Container(color: color, child: Icon(Icons.book, size: 48, color: iconColor)),
    );
  }
}

class _LangToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LangToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
