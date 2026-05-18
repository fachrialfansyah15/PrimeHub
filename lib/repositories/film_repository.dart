import 'package:chopper/chopper.dart';
import '../data/models/film_model.dart';
import '../services/film_service.dart';

class FilmRepository {
  final FilmService _filmService;

  FilmRepository(this._filmService);

  Future<List<FilmModel>> getFilms() async {
    try {
      final Response response = await _filmService.getFilms();
      if (response.isSuccessful && response.body != null) {
        final List<dynamic> data = response.body as List<dynamic>;
        return data
            .map((json) => FilmModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Gagal mengambil data film');
    } catch (e) {
      throw Exception('Error getFilms: $e');
    }
  }

  Future<FilmModel> getFilmById(String id) async {
    try {
      final Response response = await _filmService.getFilmById(id);
      if (response.isSuccessful && response.body != null) {
        return FilmModel.fromJson(response.body as Map<String, dynamic>);
      }
      throw Exception('Film tidak ditemukan');
    } catch (e) {
      throw Exception('Error getFilmById: $e');
    }
  }

  Future<FilmModel> createFilm(FilmModel film) async {
    try {
      final Response response = await _filmService.createFilm(film.toJson());
      if (response.isSuccessful && response.body != null) {
        return FilmModel.fromJson(response.body as Map<String, dynamic>);
      }
      throw Exception('Gagal menambah film');
    } catch (e) {
      throw Exception('Error createFilm: $e');
    }
  }

  Future<FilmModel> updateFilm(String id, FilmModel film) async {
    try {
      final Response response =
          await _filmService.updateFilm(id, film.toJson());
      if (response.isSuccessful && response.body != null) {
        return FilmModel.fromJson(response.body as Map<String, dynamic>);
      }
      throw Exception('Gagal mengupdate film');
    } catch (e) {
      throw Exception('Error updateFilm: $e');
    }
  }

  Future<void> deleteFilm(String id) async {
    try {
      final Response response = await _filmService.deleteFilm(id);
      if (!response.isSuccessful) {
        throw Exception('Gagal menghapus film');
      }
    } catch (e) {
      throw Exception('Error deleteFilm: $e');
    }
  }
}
