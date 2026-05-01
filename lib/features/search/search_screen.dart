import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/core/theme/app_colors.dart';
import 'package:nextflix/features/search/providers/search_providers.dart';
import 'package:nextflix/shared/widgets/media_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Color(0xFF1A1A2E),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(context, ref, searchState),
                _buildFilters(ref, searchState),
                Expanded(
                  child: resultsAsync.when(
                    data: (results) {
                      if (results.isEmpty && searchState.query.isNotEmpty) {
                        return _buildEmptyState(
                          'No results found',
                          'We couldn\'t find any matches for "${searchState.query}". Try different keywords.',
                          Icons.search_off_rounded,
                        );
                      }
                      if (results.isEmpty) {
                        return _buildEmptyState(
                          'Discover Magic',
                          'Find your favorite movies, TV shows, and more from our vast collection.',
                          Icons.explore_rounded,
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 140,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) => MediaCard(
                          media: results[index],
                          heroContext: 'search',
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    error: (e, s) => _buildEmptyState(
                      'Oops!',
                      'Something went wrong while searching. Please check your connection.',
                      Icons.error_outline_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, WidgetRef ref, SearchState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          ClipOval(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Search for movies, shows...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: state.query.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white30, size: 18),
                        onPressed: () => ref.read(searchStateProvider.notifier).state = state.copyWith(query: ''),
                      )
                    : null,
                ),
                onChanged: (val) {
                  ref.read(searchStateProvider.notifier).state = state.copyWith(query: val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(WidgetRef ref, SearchState state) {
    return Column(
      children: [
        // Type Tabs
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _FilterChip(
                label: 'All Results',
                isSelected: state.type == 'all',
                onTap: () => _updateType(ref, state, 'all'),
              ),
              _FilterChip(
                label: 'Movies',
                isSelected: state.type == 'movie',
                onTap: () => _updateType(ref, state, 'movie'),
              ),
              _FilterChip(
                label: 'TV Series',
                isSelected: state.type == 'tv',
                onTap: () => _updateType(ref, state, 'tv'),
              ),
            ],
          ),
        ),
        
        // Genre Pills (Animated Visibility)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: state.type != 'all'
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _GenreFilterBar(ref: ref, state: state),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _updateType(WidgetRef ref, SearchState state, String type) {
    HapticFeedback.lightImpact();
    ref.read(searchStateProvider.notifier).state = state.copyWith(
      type: type,
      selectedGenreId: null,
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.white.withOpacity(0.1)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreFilterBar extends ConsumerWidget {
  final WidgetRef ref;
  final SearchState state;

  const _GenreFilterBar({required this.ref, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = state.type == 'movie' 
        ? ref.watch(movieGenresProvider) 
        : ref.watch(tvGenresProvider);

    return genresAsync.when(
      data: (genres) => Container(
        height: 34,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            final id = genre['id'];
            final isSelected = state.selectedGenreId == id;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(searchStateProvider.notifier).state = state.copyWith(
                  selectedGenreId: isSelected ? null : id,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  genre['name'],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white54,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
