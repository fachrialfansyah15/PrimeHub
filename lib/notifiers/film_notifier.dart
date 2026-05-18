import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/film_model.dart';
import '../providers/providers.dart';

class FilmNotifier extends AsyncNotifier<List<FilmModel>> {
  @override
  Future<List<FilmModel>> build() async {
    return await _getFilms();
  }

  Future<List<FilmModel>> _getFilms() async {
    final repository = ref.read(filmRepositoryProvider);
    return await repository.getFilms();
  }

  Future<void> fetchFilms() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getFilms());
  }

  Future<void> createFilm(FilmModel film) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.createFilm(film);
    await fetchFilms();
  }

  Future<void> updateFilm(FilmModel film) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.updateFilm(film.id, film);
    await fetchFilms();
  }

  Future<void> deleteFilm(String id) async {
    final repository = ref.read(filmRepositoryProvider);
    await repository.deleteFilm(id);
    await fetchFilms();
  }
}
