import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/models/film_model.dart';

class FilmCard extends StatelessWidget {
  final FilmModel film;

  const FilmCard({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 34) / 2;

    return GestureDetector(
      onTap: () => context.push('/detail/${film.id}'),
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: film.gambarPoster,
                width: cardWidth,
                height: cardWidth * 1.4,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  width: cardWidth,
                  height: cardWidth * 1.4,
                  color: AppTheme.surface,
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2),
                  ),
                ),
                errorWidget: (ctx, url, err) => Container(
                  width: cardWidth,
                  height: cardWidth * 1.4,
                  color: AppTheme.surface,
                  child: const Icon(Icons.movie,
                      color: AppTheme.textSecondary, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              film.judul,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 13),
                const SizedBox(width: 3),
                Text(
                  film.ratingDesimal.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    film.kategori,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
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
