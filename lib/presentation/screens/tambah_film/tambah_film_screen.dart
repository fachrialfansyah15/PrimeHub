import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/models/film_model.dart';
import '../../../providers/providers.dart';

class TambahFilmScreen extends ConsumerStatefulWidget {
  const TambahFilmScreen({super.key});

  @override
  ConsumerState<TambahFilmScreen> createState() => _TambahFilmScreenState();
}

class _TambahFilmScreenState extends ConsumerState<TambahFilmScreen> {
  final _formKey = GlobalKey<FormState>();

  final _judulCtrl = TextEditingController();
  final _ringkasanCtrl = TextEditingController();
  final _posterCtrl = TextEditingController();
  final _sampulCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _trailerCtrl = TextEditingController();
  String _kategoriSelected = 'Action';
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Action',
    'Drama',
    'Comedy',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Fantasy',
    'Thriller',
    'Animasi',
    'Dokumenter',
  ];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _ringkasanCtrl.dispose();
    _posterCtrl.dispose();
    _sampulCtrl.dispose();
    _tahunCtrl.dispose();
    _ratingCtrl.dispose();
    _trailerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Buat FilmModel lalu kirim ke createFilm milik Adzan
      final filmBaru = FilmModel(
        id: '',
        judul: _judulCtrl.text.trim(),
        ringkasan: _ringkasanCtrl.text.trim(),
        gambarPoster: _posterCtrl.text.trim(),
        gambarSampul: _sampulCtrl.text.trim(),
        tanggalRilis: int.tryParse(_tahunCtrl.text.trim()) ?? 0,
        skorRating: int.tryParse(_ratingCtrl.text.trim()) ?? 0,
        kategori: _kategoriSelected,
        urlTrailer: _trailerCtrl.text.trim(),
      );
      await ref.read(filmNotifierProvider.notifier).createFilm(filmBaru);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Film berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke HomeScreen dan trigger refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan film: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Tambah Film Baru',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              _buildField(
                controller: _judulCtrl,
                label: 'Judul Film',
                hint: 'Contoh: Avengers Endgame',
                icon: Icons.title,
              ),
              const SizedBox(height: 14),

              // Ringkasan
              _buildField(
                controller: _ringkasanCtrl,
                label: 'Ringkasan',
                hint: 'Tuliskan sinopsis singkat...',
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 14),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                initialValue: _kategoriSelected,
                dropdownColor: AppTheme.card,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: _inputDecoration('Kategori / Genre', Icons.category),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(k),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _kategoriSelected = val);
                },
              ),
              const SizedBox(height: 14),

              // URL Poster
              _buildField(
                controller: _posterCtrl,
                label: 'URL Gambar Poster',
                hint: 'https://example.com/poster.jpg',
                icon: Icons.image,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),

              // URL Sampul
              _buildField(
                controller: _sampulCtrl,
                label: 'URL Gambar Sampul',
                hint: 'https://example.com/cover.jpg',
                icon: Icons.panorama,
                keyboardType: TextInputType.url,
                isRequired: false,
              ),
              const SizedBox(height: 14),

              // Tahun Rilis
              _buildField(
                controller: _tahunCtrl,
                label: 'Tahun Rilis',
                hint: 'Contoh: 2024',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Tahun rilis tidak boleh kosong';
                  }
                  if (int.tryParse(val.trim()) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Skor Rating
              _buildField(
                controller: _ratingCtrl,
                label: 'Skor Rating (0–100)',
                hint: 'Contoh: 85',
                icon: Icons.star,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Rating tidak boleh kosong';
                  }
                  final n = int.tryParse(val.trim());
                  if (n == null) return 'Masukkan angka yang valid';
                  if (n < 0 || n > 100) return 'Rating harus 0–100';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // URL Trailer
              _buildField(
                controller: _trailerCtrl,
                label: 'URL Trailer (YouTube)',
                hint: 'https://youtu.be/...',
                icon: Icons.play_circle_outline,
                keyboardType: TextInputType.url,
                isRequired: false,
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : 'Simpan Film',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.primary),
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: _inputDecoration(
        '$label${isRequired ? ' *' : ''}',
        icon,
      ).copyWith(hintText: hint),
      validator: validator ??
          (val) {
            if (!isRequired) return null;
            if (val == null || val.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
    );
  }
}