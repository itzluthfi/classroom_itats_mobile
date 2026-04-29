import 'dart:io';

import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class UploadAssignmentBody extends StatefulWidget {
  final double screenWidth;
  final int assignmentId;
  final Assignment? assignment; // nullable untuk backward compatibility
  const UploadAssignmentBody({
    super.key,
    required this.screenWidth,
    required this.assignmentId,
    this.assignment,
  });

  @override
  State<UploadAssignmentBody> createState() => _UploadAssignmentBodyState();
}

class _UploadAssignmentBodyState extends State<UploadAssignmentBody> {
  final _noteController = TextEditingController();
  FilePickerResult? _result;
  File? _file;
  bool _isDownloading = false;

  bool get _sudahSubmit => widget.assignment?.sudahSubmit ?? false;
  String get _submissionFile => widget.assignment?.submissionFile ?? '';
  String get _submissionLink => widget.assignment?.submissionLink ?? '';
  DateTime? get _submissionDate => widget.assignment?.submissionDate;

  /// Bangun URL download yang lengkap.
  /// file_tugas di DB disimpan sebagai path relatif,
  /// contoh: "file_task_mhs/03-2026/namafile.pdf"
  /// URL lengkap: https://classroom.itats.ac.id/storage/file_task_mhs/03-2026/namafile.pdf
  String _buildDownloadUrl() {
    // Jika submission_link sudah berupa URL lengkap, pakai langsung
    if (_submissionLink.startsWith('http://') ||
        _submissionLink.startsWith('https://')) {
      return _submissionLink;
    }
    // Jika submission_file sudah URL lengkap, pakai langsung
    if (_submissionFile.startsWith('http://') ||
        _submissionFile.startsWith('https://')) {
      return _submissionFile;
    }

    // Bangun URL dari WEB_URL + /storage/ + path relatif
    final webUrl =
        dotenv.get('WEB_URL').replaceAll(RegExp(r'^https?://'), '').trim();
    final relativePath =
        _submissionFile.isNotEmpty ? _submissionFile : _submissionLink;
    return 'https://$webUrl/storage/$relativePath';
  }

  Future<void> _downloadFile(String rawPath, String defaultName) async {
    final fileName = rawPath.isNotEmpty ? rawPath.split('/').last : defaultName;

    setState(() => _isDownloading = true);

    final repo = AssignmentRepository();
    final savedPath = await repo.downloadAssignmentFile(rawPath, fileName);

    setState(() => _isDownloading = false);

    if (!mounted) return;

    if (savedPath != null) {
      // Tampilkan notifikasi
      try {
        await NotificationService().showNotification(
            title: "Unduhan Berhasil",
            body: "File tersimpan di perangkat Anda.",
            payload: savedPath);
      } catch (_) {}

      // Tampilkan SnackBar dengan tombol Lihat File
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ File berhasil diunduh!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Lihat File',
            textColor: Colors.white,
            onPressed: () {
              OpenFilex.open(savedPath);
            },
          ),
        ),
      );
    } else {
      try {
        await NotificationService().showNotification(
            title: "Unduhan Gagal",
            body: "Gagal mengunduh file. Cek koneksi internet.");
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal mengunduh file. Cek koneksi internet.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorModal(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const Gap(8),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Mengerti", style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {
        if (state is CreateAssignmentSuccess) {
          BlocProvider.of<AssignmentBloc>(context).add(
            GetStudentSubmitedAssignment(assignmentId: widget.assignmentId),
          );
          Navigator.pop(context, 'OK');
        } else if (state is CreateAssignmentFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah tugas. Silakan coba lagi.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is CreateAssignmentLoading;
        bool isDownloading = state is AssignmentFileDownloadLoading;

        return Padding(
          padding: EdgeInsets.only(
            left: 24.0, 
            right: 24.0, 
            top: 16.0, 
            bottom: 16.0 + MediaQuery.of(context).padding.bottom
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Center(
                child: Text(
                  _sudahSubmit ? "Lihat / Ubah Tugas" : "Unggah Tugas",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Gap(16),

              // ── SECTION: Judul & Instruksi Dosen ──
              if (widget.assignment != null) ...[ 
                // Judul Tugas
                Text(
                  widget.assignment!.assignmentTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Gap(4),
                Text(
                  widget.assignment!.subjectName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(12),

                // Instruksi / Deskripsi
                if (widget.assignment!.description.isNotEmpty || widget.assignment!.fileLink.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined,
                                size: 14, color: Color(0xFFD97706)),
                            Gap(6),
                            Text(
                              "Instruksi / Soal",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD97706),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        if (widget.assignment!.description.isNotEmpty) ...[
                          const Gap(8),
                          Text(
                            widget.assignment!.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1C1C1C),
                              height: 1.55,
                            ),
                          ),
                        ],
                        if (widget.assignment!.fileLink.isNotEmpty) ...[
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFD97706).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file_rounded,
                                    size: 14, color: Color(0xFFD97706)),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    widget.assignment!.fileName.isNotEmpty
                                        ? widget.assignment!.fileName
                                        : widget.assignment!.fileLink
                                            .split('/')
                                            .last,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _isDownloading
                                      ? null
                                      : () => _downloadFile(
                                          widget.assignment!.fileLink,
                                          widget.assignment!.fileName),
                                  icon: _isDownloading
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFD97706),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.download_rounded,
                                          size: 18,
                                          color: Color(0xFFD97706),
                                        ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(16),
                ],
              ],

              // ── SECTION: Informasi Batas Waktu ──
              if (widget.assignment != null) ...[
                Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final dueDate = widget.assignment!.dueDate.toLocal();
                    final endTime = widget.assignment!.endTime?.toLocal() ?? dueDate;

                    final isLate = now.isAfter(dueDate) && now.isBefore(endTime);
                    final isExpired = now.isAfter(endTime);

                    Color statusColor = const Color(0xFF10B981); // Hijau (Tepat Waktu)
                    String statusText = "Tepat Waktu";
                    IconData statusIcon = Icons.check_circle_outline;

                    if (isExpired) {
                      statusColor = const Color(0xFFEF4444); // Merah (Ditutup)
                      statusText = "Waktu Habis / Ditutup";
                      statusIcon = Icons.cancel_outlined;
                    } else if (isLate) {
                      statusColor = const Color(0xFFF59E0B); // Kuning/Oranye (Terlambat)
                      statusText = "Terlambat";
                      statusIcon = Icons.warning_amber_rounded;
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 18),
                              const Gap(8),
                              Text(
                                "Status: $statusText",
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Text(
                            "Batas Pengumpulan: ${DateFormat("d MMM yyyy, HH:mm").format(dueDate)}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          if (widget.assignment!.endTime != null)
                            Text(
                              "Batas Keterlambatan: ${DateFormat("d MMM yyyy, HH:mm").format(endTime)}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          if (isExpired) ...[
                            const Gap(8),
                            const Text(
                              "Maaf, Anda sudah tidak dapat mengumpulkan tugas.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),
                const Gap(24),
              ],

              // ── SECTION: File yang sudah dikumpulkan (hanya jika sudah submit) ──
              if (_sudahSubmit) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.task_alt,
                              color: Color(0xFF10B981), size: 18),
                          Gap(8),
                          Text(
                            "File Tugas yang Dikumpulkan",
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      // Nama file
                      if (_submissionFile.isNotEmpty)
                        Text(
                          _submissionFile.split('/').last,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (_submissionLink.isNotEmpty)
                        Text(
                          _submissionLink,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          "Tidak ada file tersimpan",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      // Tanggal submit
                      if (_submissionDate != null) ...[
                        const Gap(4),
                        Text(
                          "Dikumpulkan: ${DateFormat("d MMM yyyy, HH:mm").format(_submissionDate!.toLocal())}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                          if (_submissionFile.isNotEmpty ||
                          _submissionLink.isNotEmpty) ...[
                        const Gap(12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isDownloading
                                ? null
                                : () => _downloadFile(
                                    _submissionLink.isNotEmpty ? _submissionLink : _submissionFile,
                                    _submissionFile.isNotEmpty ? _submissionFile : _submissionLink.split('/').last),
                            icon: _isDownloading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.download_rounded, size: 16),
                            label: Text(_isDownloading
                                ? "Mengunduh..."
                                : "Unduh File Submission"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ],
                    ),
                  ),

                const Gap(20),
                const Divider(),
                const Gap(8),
                const Text(
                  "Ingin mengumpulkan ulang? Pilih file baru di bawah:",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(16),
              ],

              // ── Peringatan Ekstensi File ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFEF4444), size: 18),
                    const Gap(8),
                    Expanded(
                      child: const Text(
                        "Saat ini aplikasi hanya mendukung file maksimal 5 MB dengan ekstensi pdf, doc, docx, xlsx, csv, rar & zip.",
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // ── File Picker ──
              Text(
                "Pilih File",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Gap(8),
              InkWell(
                onTap: isLoading
                    ? null
                    : () async {
                        _result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'jpg', 'jpeg', 'png', 'pdf', 'doc',
                            'docx', 'xlsx', 'csv', 'zip', 'rar'
                          ],
                        );
                        if (_result != null && _result!.files.single.path != null) {
                          File pickedFile = File(_result!.files.single.path!);
                          int fileSize = pickedFile.lengthSync();
                          String extension = pickedFile.path.split('.').last.toLowerCase();
                          List<String> validExtensions = [
                            'pdf', 'doc', 'docx', 'xlsx', 'csv', 'zip', 'rar'
                          ];

                          if (!validExtensions.contains(extension)) {
                            _showErrorModal(
                              "Format Tidak Didukung", 
                              "Format file .$extension tidak didukung. Harap pilih file dengan format yang diizinkan."
                            );
                            return;
                          }

                          if (fileSize > 5 * 1024 * 1024) {
                            _showErrorModal(
                              "Ukuran Terlalu Besar", 
                              "Ukuran file Anda melebihi batas maksimal 5 MB. Harap pilih file yang lebih kecil."
                            );
                            return;
                          }

                          setState(() {
                            _file = pickedFile;
                          });
                        }
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _file != null
                          ? const Color(0xFF3B82F6)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _file != null
                            ? Icons.file_present_rounded
                            : Icons.cloud_upload_outlined,
                        color: _file != null
                            ? const Color(0xFF3B82F6)
                            : Colors.grey.shade400,
                        size: 32,
                      ),
                      const Gap(8),
                      Text(
                        _file != null
                            ? _file!.path.split('/').last
                            : "Ketuk untuk memilih file",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _file != null
                              ? const Color(0xFF0F172A)
                              : Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: _file != null
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              // ── Keterangan ──
              Text(
                "Keterangan (Opsional)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Gap(8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: "Tambahkan catatan...",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF3B82F6), width: 1.5),
                  ),
                ),
              ),
              const Gap(32),

              // ── Tombol Aksi ──
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final endTime = widget.assignment?.endTime?.toLocal() ?? widget.assignment?.dueDate.toLocal() ?? DateTime.now().add(const Duration(days: 1));
                  final isExpired = now.isAfter(endTime);

                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_file == null || isLoading || isExpired)
                              ? null
                              : () {
                                  final path = _file!.path;
                                  final filename = _file!.path.split('/').last;
                                  BlocProvider.of<AssignmentBloc>(context).add(
                                    SubmitAssignment(
                                      assignmentId: widget.assignmentId,
                                      note: _noteController.text,
                                      fileLink: path,
                                      fileName: filename,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Unggah",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }
}
