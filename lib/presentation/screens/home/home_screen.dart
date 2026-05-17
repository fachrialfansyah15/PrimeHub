import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme.dart';
import '../../../providers/providers.dart';
import '../../widgets/film_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil semua film dari provider Adzan
    final filmAsync = ref.watch(filmNotifierProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_filter_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'PrimeHub',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Watchlist
          IconButton(
            icon: const Icon(Icons.bookmark_outlined),
            color: AppTheme.textPrimary,
            onPressed: () => context.push('/watchlist'),
          ),
          // Menu User
          PopupMenuButton(
            color: AppTheme.card,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary,
              child: Text(
                (user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
              PopupMenuItem(
                enabled: false,
                child: Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Keluar',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari judul atau kategori film...',
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                setState(() => _searchQuery = v.toLowerCase().trim());
              },
            ),
          ),

          // Konten Film
          Expanded(
            child: filmAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: AppTheme.textSecondary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: const TextStyle(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(filmNotifierProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (films) {
                // Filter realtime berdasarkan judul atau kategori
                final filtered = _searchQuery.isEmpty
                    ? films
                    : films.where((f) {
                        return f.judul
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            f.kategori
                                .toLowerCase()
                                .contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: AppTheme.textSecondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada film'
                              : 'Film "$_searchQuery" tidak ditemukan',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => ref.invalidate(filmNotifierProvider),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jumlah film
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _searchQuery.isEmpty
                                ? '${filtered.length} Film Tersedia'
                                : '${filtered.length} hasil untuk "$_searchQuery"',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        // Grid Film
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: filtered
                              .map((film) => FilmCard(film: film))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // FAB Tambah Film
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>('/film/tambah');
          // Refresh list kalau film berhasil ditambah
          if (result == true && mounted) {
            ref.invalidate(filmNotifierProvider);
          }
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Film',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}