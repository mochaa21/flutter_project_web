// Aby
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/prestasi_service.dart';
import '../services/master_service.dart';

class InputPrestasiScreen extends StatefulWidget {
  const InputPrestasiScreen({super.key});

  @override
  State<InputPrestasiScreen> createState() => _InputPrestasiScreenState();
}

class _InputPrestasiScreenState extends State<InputPrestasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final PrestasiService _prestasiService = PrestasiService();
  final MasterService _masterService = MasterService();

  // Controller untuk input teks
  final _namaKompetisiController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _tanggalKegiatanController = TextEditingController();

  // Variabel untuk Dropdown
  List<dynamic> _mahasiswaList = [];
  List<dynamic> _kategoriList = [];
  String? _selectedMahasiswaId;
  String? _selectedKategoriId;

  // Variabel untuk Gambar (WAJIB XFile biar aman di Web)
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isFetchingMasterData = true;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      final mahasiswa = await _masterService.getMahasiswa();
      final kategori = await _masterService.getKategori();
      
      if (mounted) {
        setState(() {
          _mahasiswaList = mahasiswa;
          _kategoriList = kategori;
          _isFetchingMasterData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingMasterData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data Master (Mahasiswa/Kategori). Pastikan endpoint API tersedia.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi untuk buka galeri dan pilih gambar
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi dikit biar ga terlalu berat
      );
      
      if (pickedFile != null) {
        setState(() {
          // PERBAIKAN KRUSIAL: Langsung simpan XFile-nya, jangan pakai File()
          _imageFile = pickedFile; 
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMahasiswaId == null || _selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih Mahasiswa dan Kategori terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan upload bukti sertifikat terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, String> data = {
        'mahasiswa_id': _selectedMahasiswaId!,
        'kategori_id': _selectedKategoriId!,
        'nama_kompetisi': _namaKompetisiController.text,
        'penyelenggara': _penyelenggaraController.text,
        'tanggal_kegiatan': _tanggalKegiatanController.text,
        'status_validasi': 'Menunggu', 
      };

      // Kirim data teks dan XFile gambar
      await _prestasiService.createPrestasi(data, _imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaKompetisiController.dispose();
    _penyelenggaraController.dispose();
    _tanggalKegiatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text('Input Prestasi Baru', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _isFetchingMasterData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedMahasiswaId,
                          decoration: _inputDecoration('Pilih Mahasiswa', Icons.person_outline),
                          items: _mahasiswaList.map((mhs) {
                            return DropdownMenuItem<String>(
                              value: mhs['id'].toString(),
                              child: Text(mhs['nama_lengkap'] ?? 'Tanpa Nama'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedMahasiswaId = value),
                          validator: (value) => value == null ? 'Pilih mahasiswa terlebih dahulu' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedKategoriId,
                          isExpanded: true,
                          decoration: _inputDecoration('Pilih Kategori', Icons.category_outlined),
                          items: _kategoriList.map((kat) {
                            return DropdownMenuItem<String>(
                              value: kat['id'].toString(),
                              child: Text("${kat['nama_kategori']} (${kat['tingkat']})", overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedKategoriId = value),
                          validator: (value) => value == null ? 'Pilih kategori terlebih dahulu' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _namaKompetisiController,
                          label: 'Nama Kompetisi / Kegiatan',
                          icon: Icons.emoji_events_outlined,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _penyelenggaraController,
                          label: 'Penyelenggara',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _tanggalKegiatanController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Kegiatan',
                            hintText: 'Pilih Tanggal',
                            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF2563EB),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF1E293B),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                _tanggalKegiatanController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        const Text('Bukti Sertifikat / Dokumentasi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb 
                                          ? Image.network(_imageFile!.path, fit: BoxFit.cover) 
                                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.upload_file, size: 40, color: Color(0xFF94A3B8)),
                                      SizedBox(height: 8),
                                      Text('Tap untuk pilih gambar dari Galeri', style: TextStyle(color: Color(0xFF64748B))),
                                    ],
                                  ),
                          ),
                        ),
                        if (_imageFile != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _imageFile = null),
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              label: const Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
      decoration: _inputDecoration(label, icon),
    );
  }
}