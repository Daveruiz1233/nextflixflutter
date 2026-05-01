import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:go_router/go_router.dart';
import 'package:nextflix/features/library/providers/library_provider.dart';
import 'package:nextflix/core/theme/app_colors.dart';

class MediaCard extends ConsumerStatefulWidget {
  final Media media;
  final String heroContext;

  const MediaCard({
    required this.media,
    this.heroContext = 'default',
    super.key,
  });

  @override
  ConsumerState<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends ConsumerState<MediaCard> {
  bool isHovered = false;

  void _showContextMenu(BuildContext context, Offset position) {
    final isInLibrary = ref.read(libraryProvider.notifier).isInLibrary(widget.media.id);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem(
          onTap: () => context.push('/details', extra: {
            'media': widget.media,
            'heroContext': widget.heroContext,
          }),
          child: const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white),
            title: Text('View Details', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          onTap: () => ref.read(libraryProvider.notifier).toggleLibrary(widget.media),
          child: ListTile(
            leading: Icon(isInLibrary ? Icons.remove_circle_outline : Icons.add_circle_outline, color: Colors.white),
            title: Text(isInLibrary ? 'Remove from My List' : 'Add to My List', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/details', extra: {
          'media': widget.media,
          'heroContext': widget.heroContext,
        });
      },
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Hero(
            tag: 'media-${widget.media.id}-${widget.heroContext}',
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                border: Border.all(
                  color: isHovered ? AppColors.primary : AppColors.glassBorder,
                  width: isHovered ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.media.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.movie, size: 50, color: AppColors.textDim),
                      ),
                    ),
                    // Glass Overlay on Hover
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withOpacity(0.9),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.media.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: AppColors.primary, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  widget.media.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
