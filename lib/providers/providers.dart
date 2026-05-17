import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/film_model.dart';
import '../notifiers/film_notifier.dart';
import '../repositories/film_repository.dart';
import '../services/film_service.dart';
import '../repositories/watchlist_repository.dart';

// ─── Chopper Client ───────────────────────────────────────────
// Ini adalah "mesin" HTTP yang terhubung ke mockapi
final chopperClientProvider = Provider<ChopperClient>((ref) {
  return ChopperClient(
    baseUrl: Uri.parse('https://68ff8dfbe02b16d1753e765d.mockapi.io'),
    services: [FilmService.create()],
    converter: const JsonConverter(),
  );
});

// ─── Film Service ─────────────────────────────────────────────
// Kurir HTTP ke mockapi
final filmServiceProvider = Provider<FilmService>((ref) {
  final client = ref.read(chopperClientProvider);
  return client.getService<FilmService>();
});

// ─── Film Repository ──────────────────────────────────────────
// Manajer data film
final filmRepositoryProvider = Provider<FilmRepository>((ref) {
  final service = ref.read(filmServiceProvider);
  return FilmRepository(service);
});

// ─── Film Notifier ────────────────────────────────────────────
// State management — daftar semua film
final filmNotifierProvider =
    AsyncNotifierProvider<FilmNotifier, List<FilmModel>>(
  FilmNotifier.new,
);

// ─── Search Provider ──────────────────────────────────────────
// Menyimpan kata kunci pencarian
final searchProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearch(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

// ─── Film Detail Provider ─────────────────────────────────────
// Ambil satu film berdasarkan ID
final filmDetailProvider =
    FutureProvider.family<FilmModel, String>((ref, id) async {
  final repository = ref.read(filmRepositoryProvider);
  return await repository.getFilmById(id);
});

// ─── Watchlist Repository ─────────────────────────────────────
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository();
});

final watchlistProvider = FutureProvider<List<FilmModel>>((ref) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  return repo.getWatchlist();
});