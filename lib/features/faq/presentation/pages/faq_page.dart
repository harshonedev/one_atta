import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/faq/domain/entities/faq_entity.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_bloc.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_event.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_state.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<FaqEntity> _displayedFaqs = [];

  final List<Map<String, dynamic>> _categories = [
    {'value': null, 'label': 'All'},
    {'value': 'general', 'label': 'General'},
    {'value': 'orders', 'label': 'Orders'},
    {'value': 'delivery', 'label': 'Delivery'},
    {'value': 'payment', 'label': 'Payment'},
    {'value': 'account', 'label': 'Account'},
    {'value': 'products', 'label': 'Products'},
    {'value': 'loyalty', 'label': 'Loyalty'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<FaqBloc>().add(const LoadFaqs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      if (_selectedCategory != null) {
        context.read<FaqBloc>().add(LoadFaqsByCategory(_selectedCategory!));
        return;
      }
      context.read<FaqBloc>().add(LoadFaqs());
    } else {
      context.read<FaqBloc>().add(SearchFaqs(query));
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
    if (category == null) {
      context.read<FaqBloc>().add(const LoadFaqs());
    } else {
      context.read<FaqBloc>().add(LoadFaqsByCategory(category));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'FAQs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.inverseSurface.withValues(alpha: 0.1),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category['label']),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryChanged(category['value']),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.inverseSurface.withValues(alpha: 0.1),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // FAQ List
          Expanded(
            child: BlocConsumer<FaqBloc, FaqState>(
              listener: (context, state) {
                if (state is FaqLoaded) {
                  setState(() {
                    _displayedFaqs = state.faqs;
                  });
                } else if (state is FaqHelpfulMarked) {
                  // Reload FAQs after marking as helpful
                  context.read<FaqBloc>().add(const RestoreFaqs());
                  SnackbarUtils.showSuccess(
                    context,
                    'Thank you for your feedback!',
                  );
                } else if (state is FaqError) {
                  SnackbarUtils.showError(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is FaqLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                if (_displayedFaqs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No FAQs found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _displayedFaqs.length,
                  itemBuilder: (context, index) {
                    final faq = _displayedFaqs[index];
                    return _FaqItem(
                      faq: faq,
                      onHelpful: () {
                        context.read<FaqBloc>().add(MarkFaqAsHelpful(faq.id));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final FaqEntity faq;
  final VoidCallback onHelpful;

  const _FaqItem({required this.faq, required this.onHelpful});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            widget.faq.question,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.faq.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Was this helpful?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: widget.onHelpful,
                  icon: Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Helpful (${widget.faq.helpfulCount})',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
