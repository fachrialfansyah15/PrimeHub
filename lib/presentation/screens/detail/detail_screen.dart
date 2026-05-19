import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme.dart';
import '../../../data/models/film_model.dart';
import '../../../providers/providers.dart';
import '../edit_film/edit_film_screen.dart';

class DetailScreen extends ConsumerWidget {
  final String filmId;

  const DetailScreen({super.key, required this.filmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmAsync = ref.watch(filmDetailProvider(filmId));

    return filmAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.primary, size: 64),
              const SizedBox(height: 16),
              const Text('Gagal memuat detail film',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
              const SizedBox(height: 8),
              Text('$e',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      data: (film) => _DetailView(film: film),
    );
  }
}

class _DetailView extends ConsumerStatefulWidget {
  final FilmModel film;
  const _DetailView({required this.film});

  @override
  ConsumerState<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends ConsumerState<_DetailView> {
  bool _isInWatchlist = false;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
    _initYoutubePlayer();
  }

  void _initYoutubePlayer() {
    final url = widget.film.urlTrailer;
    if (url.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _checkWatchlist() async {
    try {
      final repo = ref.read(watchlistRepositoryProvider);
      final isIn = await repo.isInWatchlist(widget.film.id);
      if (mounted) {
        setState(() {
          _isInWatchlist = isIn;
        });
      }
    } catch (e) {
      // Gagal cek watchlist, default false
    }
  }

  Future<void> _toggleWatchlist() async {
    final repo = ref.read(watchlistRepositoryProvider);
    final wasInWatchlist = _isInWatchlist; // simpan state sebelum toggle

    try {
      if (wasInWatchlist) {
        await repo.removeFromWatchlist(widget.film.id);
      } else {
        await repo.addToWatchlist(widget.film);
      }

      if (mounted) {
        setState(() => _isInWatchlist = !wasInWatchlist);
        // invalidate watchlist provider biar halaman watchlist ikut update
        ref.invalidate(watchlistProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(
                !wasInWatchlist ? Icons.bookmark_added : Icons.bookmark_remove,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(!wasInWatchlist
                  ? 'Ditambahkan ke watchlist'
                  : 'Dihapus dari watchlist'),
            ]),
            backgroundColor: !wasInWatchlist ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteFilm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Hapus Film',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Yakin ingin menghapus "${widget.film.judul}"?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref
            .read(filmNotifierProvider.notifier)
            .deleteFilm(widget.film.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Film berhasil dihapus'),
              ]),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menghapus film: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Color _getRatingColor(int rating) {
    if (rating >= 75) return Colors.green;
    if (rating >= 50) return AppTheme.gold;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;

    // Jika ada YouTube player, wrap Scaffold dengan YoutubePlayerBuilder
    if (_youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primary,
          progressColors: ProgressBarColors(
            playedColor: AppTheme.primary,
            handleColor: AppTheme.primary,
          ),
        ),
        builder: (context, player) => _buildScaffold(film, player),
      );
    }

    return _buildScaffold(film, null);
  }

  Widget _buildScaffold(FilmModel film, Widget? youtubePlayer) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            iconTheme: const IconThemeData(color: AppTheme.textPrimary),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.textPrimary),
                tooltip: 'Edit Film',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditFilmScreen(film: film)),
                  );
                  if (result == true && mounted) {
                    ref.invalidate(filmDetailProvider(film.id));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.primary),
                tooltip: 'Hapus Film',
                onPressed: _deleteFilm,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  film.gambarSampul.isNotEmpty
                      ? Image.network(film.gambarSampul,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.surface,
                              child: const Icon(Icons.movie,
                                  color: AppTheme.textSecondary, size: 64)))
                      : Container(
                          color: AppTheme.surface,
                          child: const Icon(Icons.movie,
                              color: AppTheme.textSecondary, size: 64)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.background],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: film.gambarPoster.isNotEmpty
                            ? Image.network(film.gambarPoster,
                                width: 110, height: 160, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 110, height: 160,
                                    color: AppTheme.card,
                                    child: const Icon(Icons.image_not_supported,
                                        color: AppTheme.textSecondary)))
                            : Container(
                                width: 110, height: 160,
                                decoration: BoxDecoration(
                                    color: AppTheme.card,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.movie,
                                    color: AppTheme.textSecondary, size: 40)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.4)),
                              ),
                              child: Text(film.kategori,
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 8),
                            Text(film.judul,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2)),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.calendar_today,
                                  color: AppTheme.textSecondary, size: 14),
                              const SizedBox(width: 4),
                              Text('${film.tanggalRilis}',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.star_rounded,
                                  color: _getRatingColor(film.rating),
                                  size: 18),
                              const SizedBox(width: 4),
                              Text(
                                  '${film.ratingDesimal.toStringAsFixed(1)} / 10',
                                  style: TextStyle(
                                      color: _getRatingColor(film.rating),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: film.rating / 100,
                      minHeight: 6,
                      backgroundColor: AppTheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getRatingColor(film.rating)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol Watchlist (tombol Trailer dihapus karena sudah ada player)
                  OutlinedButton.icon(
                    onPressed: _toggleWatchlist,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isInWatchlist
                          ? AppTheme.gold
                          : AppTheme.textPrimary,
                      side: BorderSide(
                          color: _isInWatchlist
                              ? AppTheme.gold
                              : AppTheme.textSecondary),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(
                        _isInWatchlist
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 18),
                    label: Text(
                        _isInWatchlist ? 'Tersimpan' : 'Tambah ke Watchlist',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                  if (film.isComingSoon == true) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time,
                              color: AppTheme.gold, size: 16),
                          SizedBox(width: 8),
                          Text('Coming Soon',
                              style: TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // ── Trailer Section ──
                  if (youtubePlayer != null) ...[
                    const Text('Trailer',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: youtubePlayer,
                    ),
                    const SizedBox(height: 24),
                  ] else if (film.urlTrailer.isNotEmpty) ...[
                    // URL ada tapi bukan YouTube → tampil info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.textSecondary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'URL trailer tidak dapat diputar di dalam aplikasi.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // ── Ringkasan ──
                  const Text('Ringkasan',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    film.ringkasan.isNotEmpty
                        ? film.ringkasan
                        : 'Tidak ada ringkasan tersedia.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.7),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}