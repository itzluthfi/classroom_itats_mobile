import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LecturerDetailCollegeReport extends StatefulWidget {
  final SubjectReport subject;
  const LecturerDetailCollegeReport({super.key, required this.subject});

  @override
  State<LecturerDetailCollegeReport> createState() =>
      _LecturerDetailCollegeReportState();
}

class _LecturerDetailCollegeReportState
    extends State<LecturerDetailCollegeReport> {
  @override
  void initState() {
    super.initState();
    _getLecture();
  }

  _getLecture() {
    if (!mounted) return;
    BlocProvider.of<LectureBloc>(context).add(GetLectureReport(
      subjectId: widget.subject.subjectId,
      subjectClass: widget.subject.subjectClass,
      hourId: widget.subject.hourId,
      collegeType: widget.subject.collegeType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LectureBloc, LectureState>(
      listener: (context, state) {
        if (state is LectureEditSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Pelaporan berhasil dihapus'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
          _getLecture();
        } else if (state is LectureDeleteFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Gagal menghapus pelaporan'),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF1F5F9),
          child: RefreshIndicator(
            color: const Color(0xFF1E5AD6),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 800));
              _getLecture();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader(state)),
                // Content
                _buildContent(context, state),
                // Bottom padding
                const SliverToBoxAdapter(child: Gap(100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LectureState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF1E5AD6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E5AD6).withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "[${widget.subject.collegeType}] ${widget.subject.subjectName}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    _headerChip(Icons.class_outlined,
                        "Kelas ${widget.subject.subjectClass}"),
                    const Gap(8),
                    _headerChip(Icons.access_time_outlined,
                        "${widget.subject.timeStart} - ${widget.subject.timeEnd}"),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),
          // Title + count
          Row(
            children: [
              const Text(
                "Daftar Pelaporan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              if (state is LectureLoaded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${state.lectureReports.length} Pertemuan",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4338CA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const Gap(4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LectureState state) {
    if (state is LectureLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: Color(0xFF1E5AD6), strokeWidth: 3),
              Gap(16),
              Text("Memuat data pelaporan...",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      );
    } else if (state is LectureLoaded && state.lectureReports.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _LectureReportCard(
              lecture: state.lectureReports[i],
              subject: widget.subject,
              onDelete: () => _getLecture(),
            ),
            childCount: state.lectureReports.length,
          ),
        ),
      );
    } else {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.snippet_folder_outlined,
                      size: 60, color: Colors.grey.shade400),
                ),
                const Gap(20),
                const Text(
                  "Belum Ada Pelaporan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const Gap(8),
                Text(
                  "Belum ada laporan kuliah\nuntuk kelas ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _LectureReportCard extends StatelessWidget {
  final Lecture lecture;
  final SubjectReport subject;
  final VoidCallback onDelete;

  const _LectureReportCard({
    required this.lecture,
    required this.subject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPresence = lecture.presenceStudent != 0;
    final String dateStr = lecture.lectureSchedule != null
        ? DateFormat("EEEE, d MMM yyyy", "id_ID")
            .format(lecture.lectureSchedule!)
        : "-";

    final int approvalStatus = lecture.approvalStatus ?? 0;
    Color approvalColor;
    String approvalText;
    if (approvalStatus == 0) {
      approvalColor = const Color(0xFFEF4444);
      approvalText = "Submitted";
    } else if (approvalStatus == 1) {
      approvalColor = const Color(0xFF0EA5E9);
      approvalText = "Approved";
    } else {
      approvalColor = const Color(0xFF10B981);
      approvalText = "Paid";
    }

    final bool isHybrid = lecture.collegeType == 2;
    final String collegeTypeBadgeText = isHybrid ? "Hybrid" : "Offline";
    final Color collegeTypeColor =
        isHybrid ? const Color(0xFF0EA5E9) : const Color(0xFF4338CA);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // top border
            Container(
              height: 3,
              color: approvalColor,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Week badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Minggu ${lecture.weekID}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      const Gap(8),
                      // Jenis Kuliah Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: collegeTypeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          collegeTypeBadgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: collegeTypeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Status Approval badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: approvalColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          approvalText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: approvalColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    "${subject.subjectName} - ${subject.subjectClass}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const Gap(5),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(12),
                      Icon(Icons.access_time_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const Gap(5),
                      Text(
                        "${subject.timeStart} - ${subject.timeEnd}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Icon(
                        hasPresence
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        size: 13,
                        color: hasPresence
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const Gap(5),
                      Text(
                        hasPresence ? "Sudah Absen" : "Belum Absen",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasPresence
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  
                  // Action buttons
                  if (!hasPresence || isHybrid) ...[
                    const Gap(12),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const Gap(10),
                    Row(
                      children: [
                        if (isHybrid &&
                            lecture.linkMeet != null &&
                            lecture.linkMeet!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(lecture.linkMeet!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.video_call_outlined, size: 16),
                              label: const Text(
                                "Join Meet",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0EA5E9),
                                side: const BorderSide(color: Color(0xFF0EA5E9)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        if (isHybrid && !hasPresence) const Gap(10),
                        if (!hasPresence) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/lecturer/college_report/edit",
                                arguments: <String, Object>{
                                  "subject": subject,
                                  "lecture": lecture,
                                },
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD97706),
                              side:
                                  const BorderSide(color: Color(0xFFD97706)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (BuildContext ctx) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Hapus Pelaporan?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  content: const Text(
                                    'Tindakan ini tidak dapat dibatalkan. Pelaporan akan dihapus secara permanen.',
                                    style: TextStyle(fontSize: 14, height: 1.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text('Batal',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Hapus',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true) {
                                  BlocProvider.of<LectureBloc>(context).add(
                                    DeleteLectureReport(
                                      lectureId: lecture.lectureID ?? '',
                                    ),
                                  );
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_outline, size: 15),
                            label: const Text(
                              "Hapus",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
