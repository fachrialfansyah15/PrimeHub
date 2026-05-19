import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/film_model.dart';

class WatchlistRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FilmModel>> getWatchlist() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');
      final response = await _supabase
          .from('watchlist')
          .select()
          .eq('user_id', userId);

      // Map dari struktur tabel watchlist ke FilmModel
      return (response as List).map((json) => FilmModel(
        id: json['film_id']?.toString() ?? '',
        judul: json['judul']?.toString() ?? '',
        ringkasan: json['ringkasan']?.toString() ?? '',
        gambarPoster: json['gambar_poster']?.toString() ?? '',
        gambarSampul: json['gambar_sampul']?.toString() ?? '',
        tanggalRilis: json['tanggal_rilis'],
        skorRating: json['skor_rating'],
        kategori: json['kategori']?.toString() ?? '',
        urlTrailer: json['url_trailer']?.toString() ?? '',
        isComingSoon: json['is_coming_soon'] as bool?,
      )).toList();
    } catch (e) {
      throw Exception('Gagal mengambil watchlist: $e');
    }
  }

  Future<void> addToWatchlist(FilmModel film) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');
      await _supabase.from('watchlist').insert({
        'user_id': userId,
        'film_id': film.id,
        'judul': film.judul,
        'gambar_poster': film.gambarPoster,
        'gambar_sampul': film.gambarSampul,
        'skor_rating': film.skorRating,
        'kategori': film.kategori,
        'ringkasan': film.ringkasan,
        'url_trailer': film.urlTrailer,
        'tanggal_rilis': film.tanggalRilis,
        'is_coming_soon': film.isComingSoon,
      });
    } catch (e) {
      throw Exception('Gagal menambah ke watchlist: $e');
    }
  }

  Future<void> removeFromWatchlist(String filmId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');
      await _supabase
          .from('watchlist')
          .delete()
          .eq('user_id', userId)
          .eq('film_id', filmId);
    } catch (e) {
      throw Exception('Gagal menghapus dari watchlist: $e');
    }
  }

  Future<bool> isInWatchlist(String filmId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;
      final response = await _supabase
          .from('watchlist')
          .select()
          .eq('user_id', userId)
          .eq('film_id', filmId);
      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}