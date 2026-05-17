import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/film_model.dart';
import '../providers/providers.dart';


class FilmNotifier extends AsyncNotifier<List<FilmModel>> {
  @override
  Future<List<FilmModel>> build() async {
    // Otomatis dipanggil pertama kali, langsung fetch data
    return await _getFilms();
  }

  Future<List<FilmModel>> _getFilms() async {
    final repository = ref.read(filmRepositoryProvider);
    return await repository.getFilms();
  }

  // Refresh / ambil ulang semua film
  Future<void> fetchFilms() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getFilms());
  }

  // Tambah film baru
  Future<void> createFilm(FilmModel film) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.createFilm(film);
    await fetchFilms(); // refresh list
  }

  // Edit film
  Future<void> updateFilm(String id, FilmModel film) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.updateFilm(id, film);
    await fetchFilms(); // refresh list
  }

  // Hapus film
  Future<void> deleteFilm(String id) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.deleteFilm(id);
    await fetchFilms(); // refresh list
  }
}
