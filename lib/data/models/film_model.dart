class FilmModel {
  final String id;
  final String judul;
  final String ringkasan;
  final String gambarPoster;
  final String gambarSampul;
  final dynamic tanggalRilis; // bisa int atau String dari API
  final dynamic skorRating;   // bisa int atau String dari API
  final String kategori;
  final String urlTrailer;
  final bool? isComingSoon;

  FilmModel({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.gambarPoster,
    required this.gambarSampul,
    required this.tanggalRilis,
    required this.skorRating,
    required this.kategori,
    required this.urlTrailer,
    this.isComingSoon,
  });

  factory FilmModel.fromJson(Map<String, dynamic> json) {
    return FilmModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      ringkasan: json['ringkasan']?.toString() ?? '',
      gambarPoster: json['gambar_poster']?.toString() ?? '',
      gambarSampul: json['gambar_sampul']?.toString() ?? '',
      tanggalRilis: json['tanggal_rilis'],
      skorRating: json['skor_rating'],
      kategori: json['kategori']?.toString() ?? '',
      urlTrailer: json['url_trailer']?.toString() ?? '',
      isComingSoon: json['is_coming_soon'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'ringkasan': ringkasan,
      'gambar_poster': gambarPoster,
      'gambar_sampul': gambarSampul,
      'tanggal_rilis': tanggalRilis,
      'skor_rating': skorRating,
      'kategori': kategori,
      'url_trailer': urlTrailer,
      if (isComingSoon != null) 'is_coming_soon': isComingSoon,
    };
  }

  // Helper: rating sebagai int (0-100)
  int get rating {
    if (skorRating is int) return skorRating as int;
    if (skorRating is String) return int.tryParse(skorRating as String) ?? 0;
    return 0;
  }

  // Helper: rating sebagai desimal 0.0 - 10.0
  double get ratingDesimal => rating / 10.0;

  FilmModel copyWith({
    String? judul,
    String? ringkasan,
    String? gambarPoster,
    String? gambarSampul,
    dynamic tanggalRilis,
    dynamic skorRating,
    String? kategori,
    String? urlTrailer,
    bool? isComingSoon,
  }) {
    return FilmModel(
      id: id,
      judul: judul ?? this.judul,
      ringkasan: ringkasan ?? this.ringkasan,
      gambarPoster: gambarPoster ?? this.gambarPoster,
      gambarSampul: gambarSampul ?? this.gambarSampul,
      tanggalRilis: tanggalRilis ?? this.tanggalRilis,
      skorRating: skorRating ?? this.skorRating,
      kategori: kategori ?? this.kategori,
      urlTrailer: urlTrailer ?? this.urlTrailer,
      isComingSoon: isComingSoon ?? this.isComingSoon,
    );
  }
}