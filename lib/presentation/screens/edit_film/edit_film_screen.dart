import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/models/film_model.dart';
import '../../../providers/providers.dart';

class EditFilmScreen extends ConsumerStatefulWidget {
  final FilmModel film;

  const EditFilmScreen({super.key, required this.film});

  @override
  ConsumerState<EditFilmScreen> createState() => _EditFilmScreenState();
}

class _EditFilmScreenState extends ConsumerState<EditFilmScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulCtrl;
  late final TextEditingController _ringkasanCtrl;
  late final TextEditingController _posterCtrl;
  late final TextEditingController _sampulCtrl;
  late final TextEditingController _tahunCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _trailerCtrl;
  late String _kategoriSelected;
  bool _isComingSoon = false;
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
  void initState() {
    super.initState();
    final f = widget.film;
    _judulCtrl = TextEditingController(text: f.judul);
    _ringkasanCtrl = TextEditingController(text: f.ringkasan);
    _posterCtrl = TextEditingController(text: f.gambarPoster);
    _sampulCtrl = TextEditingController(text: f.gambarSampul);
    _tahunCtrl = TextEditingController(text: '${f.tanggalRilis}');
    _ratingCtrl = TextEditingController(text: '${f.rating}');
    _trailerCtrl = TextEditingController(text: f.urlTrailer);

    // Pastikan kategori ada di list, kalau tidak default ke 'Action'
    _kategoriSelected =
        _kategoriList.contains(f.kategori) ? f.kategori : _kategoriList.first;

    _isComingSoon = f.isComingSoon ?? false;
  }

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
      final filmUpdated = widget.film.copyWith(
        judul: _judulCtrl.text.trim(),
        ringkasan: _ringkasanCtrl.text.trim(),
        gambarPoster: _posterCtrl.text.trim(),
        gambarSampul: _sampulCtrl.text.trim(),
        tanggalRilis: int.tryParse(_tahunCtrl.text.trim()) ?? 0,
        skorRating: int.tryParse(_ratingCtrl.text.trim()) ?? 0,
        kategori: _kategoriSelected,
        urlTrailer: _trailerCtrl.text.trim(),
        isComingSoon: _isComingSoon,
      );

      await ref.read(filmNotifierProvider.notifier).updateFilm(filmUpdated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Film berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui film: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
          'Edit Film',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          // Tombol simpan di AppBar sebagai shortcut
          TextButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: const Icon(Icons.save_outlined,
                color: AppTheme.primary, size: 18),
            label: const Text(
              'Simpan',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview poster/sampul jika URL sudah ada
              if (_posterCtrl.text.isNotEmpty || _sampulCtrl.text.isNotEmpty)
                _PreviewImages(
                  posterUrl: _posterCtrl.text,
                  sampulUrl: _sampulCtrl.text,
                ),

              const SizedBox(height: 4),

              // ── Section: Informasi Dasar ──
              _SectionLabel(label: 'Informasi Dasar'),
              const SizedBox(height: 10),

              _buildField(
                controller: _judulCtrl,
                label: 'Judul Film',
                hint: 'Contoh: Avengers Endgame',
                icon: Icons.title,
              ),
              const SizedBox(height: 14),

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
                value: _kategoriSelected,
                dropdownColor: AppTheme.card,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration:
                    _inputDecoration('Kategori / Genre', Icons.category),
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

              const SizedBox(height: 24),

              // ── Section: Media ──
              _SectionLabel(label: 'URL Media'),
              const SizedBox(height: 10),

              _buildField(
                controller: _posterCtrl,
                label: 'URL Gambar Poster',
                hint: 'https://example.com/poster.jpg',
                icon: Icons.image,
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              _buildField(
                controller: _sampulCtrl,
                label: 'URL Gambar Sampul',
                hint: 'https://example.com/cover.jpg',
                icon: Icons.panorama,
                keyboardType: TextInputType.url,
                isRequired: false,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              _buildField(
                controller: _trailerCtrl,
                label: 'URL Trailer (YouTube)',
                hint: 'https://youtu.be/...',
                icon: Icons.play_circle_outline,
                keyboardType: TextInputType.url,
                isRequired: false,
              ),

              const SizedBox(height: 24),

              // ── Section: Data Rilis ──
              _SectionLabel(label: 'Data Rilis'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _tahunCtrl,
                      label: 'Tahun Rilis',
                      hint: 'Contoh: 2024',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        if (int.tryParse(val.trim()) == null) {
                          return 'Harus angka';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _ratingCtrl,
                      label: 'Skor Rating (0–100)',
                      hint: 'Contoh: 85',
                      icon: Icons.star,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        final n = int.tryParse(val.trim());
                        if (n == null) return 'Harus angka';
                        if (n < 0 || n > 100) return '0–100';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Toggle Coming Soon
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Tandai film ini belum tayang',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  secondary: Icon(
                    Icons.new_releases_outlined,
                    color:
                        _isComingSoon ? AppTheme.gold : AppTheme.textSecondary,
                  ),
                  value: _isComingSoon,
                  activeColor: AppTheme.gold,
                  onChanged: (val) => setState(() => _isComingSoon = val),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Simpan Utama
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
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
                    _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
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
      errorStyle: const TextStyle(color: AppTheme.primary, fontSize: 11),
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      onChanged: onChanged,
      decoration: _inputDecoration(
        '$label${isRequired ? ' *' : ''}',
        icon,
      ).copyWith(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary)),
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

// Widget preview gambar poster & sampul
class _PreviewImages extends StatelessWidget {
  final String posterUrl;
  final String sampulUrl;

  const _PreviewImages({required this.posterUrl, required this.sampulUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Gambar',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (posterUrl.isNotEmpty) ...[
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      posterUrl,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 110,
                        color: AppTheme.surface,
                        child: const Icon(Icons.broken_image,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Poster',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            if (sampulUrl.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        sampulUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 110,
                          color: AppTheme.surface,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sampul',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Widget label section
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
