import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/upload_assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StudentAssignmentsBody extends StatefulWidget {
  final Assignment assignment;

  const StudentAssignmentsBody({
    super.key,
    required this.assignment,
  });

  @override
  State<StudentAssignmentsBody> createState() => _StudentAssignmentsBodyState();
}

class _StudentAssignmentsBodyState extends State<StudentAssignmentsBody> {
  @override
  void initState() {
    super.initState();
    // Fetch detail tugas yang sudah join dengan submission mahasiswa
    BlocProvider.of<AssignmentBloc>(context).add(GetStudentAssignmentWeek(
        masterActivityId: widget.assignment.activityMasterId,
        weekId: widget.assignment.weekId));
  }

  void _openUploadSheet(
      BuildContext ctx, StudentAssignmentJoin assignment, double screenWidth) {
    final bloc = ctx.read<AssignmentBloc>();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: BlocProvider.value(
                    value: bloc,
                    child: UploadAssignmentBody(
                      screenWidth: screenWidth,
                      assignmentId: assignment.assignmentId,
                      assignment: Assignment(
                        assignmentId: assignment.assignmentId,
                        activityMasterId: assignment.activityMasterId,
                        weekId: assignment.weekId,
                        assignmentTitle: assignment.assignmentTitle,
                        description: assignment.description,
                        dueDate: assignment.dueDate,
                        endTime: assignment.endTime,
                        jNilId: assignment.jNilId,
                        createdAt: assignment.createdAt,
                        updatedAt: assignment.updatedAt,
                        fileLink: assignment.fileLink,
                        fileName: assignment.fileName,
                        isShow: true,
                        realPrercentage: 0.0,
                        subjectClass: '',
                        subjectName: '',
                        jNilDesc: '',
                        totalSubmited: 0,
                        sudahSubmit: assignment.assignmentSubmissionId != 0,
                        submissionFile: assignment.assignmentFile,
                        submissionLink: assignment.assignmentLink,
                        submissionDate: assignment.createdAt,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Reload setelah modal ditutup
      bloc.add(GetStudentAssignmentWeek(
        masterActivityId: assignment.activityMasterId,
        weekId: assignment.weekId,
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<AssignmentBloc, AssignmentState>(
      // Bug 10 fix: jangan rebuild saat state adalah loading/success dari download
      // agar data assignment tidak hilang sementara
      buildWhen: (prev, curr) {
        if (curr is AssignmentFileDownloadLoading) return false;
        if (curr is AssignmentFileDownloadSuccess) return false;
        return true;
      },
      builder: (context, state) {
        if (state is AssignmentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignments =
            state is AssignmentLoaded ? state.assignmentsJoin : <StudentAssignmentJoin>[];

        if (assignments.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada tugas untuk minggu ini.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AssignmentBloc>().add(GetStudentAssignmentWeek(
                masterActivityId: widget.assignment.activityMasterId,
                weekId: widget.assignment.weekId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: assignments.length,
            itemBuilder: (ctx, index) {
              final a = assignments[index];
              final sudahSubmit = a.assignmentSubmissionId != 0;
              final endTime = a.endTime?.toLocal() ?? a.dueDate.toLocal();
              
              final isLate = sudahSubmit
                  ? a.dueDate.isBefore(a.createdAt)
                  : a.dueDate.isBefore(DateTime.now());

              final isExpired = DateTime.now().isAfter(endTime);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sudahSubmit
                        ? const Color(0xFFBBF7D0)
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: judul + badge status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              a.assignmentTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sudahSubmit
                                  ? const Color(0xFFECFDF5)
                                  : isLate
                                      ? const Color(0xFFFEF2F2)
                                      : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sudahSubmit
                                  ? 'Terkumpul'
                                  : isLate
                                      ? 'Terlambat'
                                      : 'Belum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sudahSubmit
                                    ? const Color(0xFF10B981)
                                    : isLate
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFF97316),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(6),

                      // Deadline
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: isLate && !sudahSubmit
                                ? const Color(0xFFEF4444)
                                : Colors.grey.shade500,
                          ),
                          const Gap(4),
                          Text(
                            "Tenggat: ${DateFormat("EEEE, d MMM y HH:mm", "id_ID").format(a.dueDate)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isLate && !sudahSubmit
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      if (a.endTime != null && a.endTime!.isAfter(a.dueDate)) ...[
                        const Gap(4),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 13,
                              color: isExpired && !sudahSubmit
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey.shade500,
                            ),
                            const Gap(4),
                            Text(
                              "Batas Terlambat: ${DateFormat("EEEE, d MMM y HH:mm", "id_ID").format(a.endTime!)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpired && !sudahSubmit
                                    ? const Color(0xFFEF4444)
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Deskripsi
                      if (a.description.isNotEmpty) ...[
                        const Gap(10),
                        Text(
                          a.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Gap(12),

                      // Download file soal (dari dosen)
                      if (a.fileLink.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () {
                            BlocProvider.of<AssignmentBloc>(context).add(
                              DownloadAssignment(
                                  fileLink: a.fileLink,
                                  fileName: a.fileName),
                            );
                          },
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text("Download Soal Tugas",
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1E5AD6),
                            side: const BorderSide(color: Color(0xFF1E5AD6)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),

                      const Gap(12),

                      // Submission info (jika sudah submit)
                      if (sudahSubmit) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.task_alt,
                                      color: Color(0xFF10B981), size: 16),
                                  const Gap(6),
                                  const Text(
                                    "Tugas Sudah Dikumpulkan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF059669),
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (isLate) ...[
                                    const Gap(6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Terlambat",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              const Gap(6),
                              // Tanggal dikumpulkan
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 12,
                                      color: Colors.grey.shade500),
                                  const Gap(4),
                                  Text(
                                    "Dikumpulkan: ${DateFormat("d MMM y, HH:mm", "id_ID").format(a.createdAt)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              // File submission
                              if (a.assignmentFile.isNotEmpty) ...[
                                const Gap(8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.insert_drive_file_outlined,
                                          size: 16,
                                          color: Color(0xFF10B981)),
                                      const Gap(8),
                                      Expanded(
                                        child: Text(
                                          a.assignmentFile,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.download_outlined,
                                            size: 18,
                                            color: Color(0xFF10B981)),
                                        onPressed: () {
                                          BlocProvider.of<AssignmentBloc>(
                                                  context)
                                              .add(
                                            DownloadStudentAssignmentSubmission(
                                                fileLink: a.assignmentLink,
                                                fileName: a.assignmentFile),
                                          );
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // Note submission
                              if (a.note.isNotEmpty && a.note != '-') ...[
                                const Gap(6),
                                Text(
                                  "Catatan: ${a.note}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Gap(12),
                        // Tombol ubah submission
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isExpired
                                ? null
                                : () => _openUploadSheet(context, a, screenWidth),
                            icon:
                                const Icon(Icons.edit_outlined, size: 16),
                            label: const Text("Ubah Submission",
                                style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              disabledForegroundColor: Colors.grey.shade400,
                              side:
                                  BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Tombol upload
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isExpired
                                ? null
                                : () => _openUploadSheet(context, a, screenWidth),
                            icon: const Icon(Icons.attach_file, size: 16),
                            label: const Text("Kumpulkan Tugas",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5AD6),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              disabledForegroundColor: Colors.grey.shade500,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
