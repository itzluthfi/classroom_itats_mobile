import 'dart:io';

import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class UploadAssignmentBody extends StatefulWidget {
  final double screenWidth;
  final int assignmentId;
  const UploadAssignmentBody({
    super.key,
    required this.screenWidth,
    required this.assignmentId,
  });

  @override
  State<UploadAssignmentBody> createState() => _UploadAssignmentBodyState();
}

class _UploadAssignmentBodyState extends State<UploadAssignmentBody> {
  final _noteController = TextEditingController();
  FilePickerResult? _result;
  File? _file;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {
        if (state is CreateAssignmentSuccess) {
          // Tutup bottom sheet jika sukses
          Navigator.pop(context, 'OK');
        } else if (state is CreateAssignmentFailed) {
          // Tampilkan snackbar atau biarkan notifikasi bawaan
        }
      },
      builder: (context, state) {
        bool isLoading = state is CreateAssignmentLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Center(
                child: Text(
                  "Unggah Tugas",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Gap(24),

              // Peringatan Ekstensi File
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
                      child: Text(
                        "Saat ini aplikasi hanya mendukung file dengan ekstensi pdf, doc, docx, xlsx, csv, rar & zip.",
                        style: TextStyle(
                          color: const Color(0xFF991B1B),
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

              // File Picker Modern Button
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
                            'jpg',
                            'jpeg',
                            'png',
                            'pdf',
                            'doc',
                            'docx',
                            'xlsx',
                            'csv',
                            'zip',
                            'rar'
                          ],
                        );

                        if (_result != null) {
                          setState(() {
                            _file = File(_result!.files.single.path ?? "");
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
                      style: BorderStyle.solid, // Simulated modern stroke
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
                          fontWeight:
                              _file != null ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              // Keterangan Input
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
                    borderSide:
                        const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                  ),
                ),
              ),
              const Gap(32),

              // Aksi Bawah
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
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
                      onPressed: (_file == null || isLoading)
                          ? null
                          : () {
                              var path = _file!.path;
                              final fileArr = _file!.path.split('/');
                              var filename = fileArr.last;

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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
