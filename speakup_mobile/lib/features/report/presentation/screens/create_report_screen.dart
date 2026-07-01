import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  bool _isAnonymous = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _reportedController = TextEditingController();
  String _selectedCategory = 'Fisik & Pemerasan';
  DateTime? _selectedDate;
  final List<File> _selectedFiles = [];
  final List<String> _fileNames = [];

  final List<String> _categories = [
    'Fisik & Pemerasan',
    'Verbal & Ejekan',
    'Cyberbullying',
    'Pengucilan',
    'Lainnya'
  ];

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _selectedFiles.add(File(file.path!));
              _fileNames.add(file.name);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e'), backgroundColor: AppTheme.danger600),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _selectedFiles.add(File(pickedFile.path));
          _fileNames.add(pickedFile.name);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppTheme.danger600),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppTheme.primary600),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Laporan Anda aman. Anda bisa memilih untuk tidak menyertakan identitas (anonim).',
                      style: TextStyle(fontSize: 14, color: AppTheme.primary600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            SwitchListTile(
              title: const Text('Lapor Secara Anonim', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Identitas Anda akan disembunyikan', style: TextStyle(fontSize: 12)),
              value: _isAnonymous,
              activeColor: AppTheme.primary600,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _isAnonymous = val;
                });
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            _buildLabel('Judul Laporan'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Misal: Pemalakan di Kantin'),
            ),
            const SizedBox(height: 16),

            _buildLabel('Jenis Perundungan'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            
            _buildLabel('Tanggal Kejadian'),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _selectedDate == null ? 'Pilih Tanggal' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 16),
            
            _buildLabel('Lokasi Kejadian'),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Misal: Area Parkir Motor'),
            ),
            const SizedBox(height: 16),

            _buildLabel('Nama Terlapor (Opsional)'),
            TextField(
              controller: _reportedController,
              decoration: const InputDecoration(hintText: 'Misal: Budi kelas 12A'),
            ),
            const SizedBox(height: 16),
            
            _buildLabel('Kronologi Kejadian'),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Ceritakan detail kronologi kejadian...'),
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Upload Bukti (Foto/Video/PDF)'),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.neutral300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt, size: 36, color: AppTheme.primary600),
                          const SizedBox(height: 8),
                          const Text('Kamera/Galeri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickFiles,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.neutral300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.attach_file, size: 36, color: AppTheme.primary600),
                          const SizedBox(height: 8),
                          const Text('File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(_selectedFiles.length, (index) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success600),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.success600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_fileNames[index], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppTheme.danger600),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty || _descController.text.isEmpty || _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi judul, tanggal, dan kronologi!'), backgroundColor: AppTheme.danger600));
                    return;
                  }

                  final reportData = {
                    'title': _titleController.text,
                    'category': _selectedCategory,
                    'incidentDate': '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                    'incidentLocation': _locationController.text,
                    'reportedId': _reportedController.text,
                    'description': _descController.text,
                    'isAnonymous': _isAnonymous,
                    'filePaths': _selectedFiles.map((f) => f.path).toList(),
                    'hasFile': _selectedFiles.isNotEmpty,
                  };
                  
                  context.push('/report/review', extra: reportData);
                },
                child: const Text('Lanjut ke Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Text(' *', style: TextStyle(color: AppTheme.danger600)),
        ],
      ),
    );
  }
}
