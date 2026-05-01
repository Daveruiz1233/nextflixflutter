import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/shared/widgets/media_card.dart';

class MediaRow extends StatelessWidget {
  final String title;
  final List<Media>? mediaList;
  final bool isLoading;

  const MediaRow({
    required this.title,
    this.mediaList,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: isLoading
              ? _buildShimmer()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: mediaList?.length ?? 0,
                  itemBuilder: (context, index) {
                    return MediaCard(
                      media: mediaList![index],
                      heroContext: title,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}
