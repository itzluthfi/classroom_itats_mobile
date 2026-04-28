import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/list_subject/list_subject_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LecturerSubjectScoreBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;
  final MajorRepository majorRepository;

  const LecturerSubjectScoreBody(
      {super.key,
      required this.academicPeriodRepository,
      required this.majorRepository});

  @override
  State<LecturerSubjectScoreBody> createState() =>
      _LecturerSubjectScoreBodyState();
}

class _LecturerSubjectScoreBodyState extends State<LecturerSubjectScoreBody> {
  @override
  void initState() {
    super.initState();
    _getSubjectLecturer();
  }

  _getSubjectLecturer() async {
    if (!mounted) return;
    widget.academicPeriodRepository.getCurrentAcademicPeriod().then(
      (ac) {
        if (!mounted) return;
        widget.majorRepository.getlecturerMajor().then((value) {
          if (!mounted) return;
          BlocProvider.of<ListSubjectBloc>(context).add(
            GetLecturerSubject(academicPeriod: ac, major: value),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ListSubjectBloc, ListSubjectState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: RefreshIndicator(
            color: const Color(0xFF1E5AD6),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 800));
              setState(() {
                widget.academicPeriodRepository
                    .getCurrentAcademicPeriod()
                    .then(
                      (ac) => widget.majorRepository.getlecturerMajor().then(
                            (value) =>
                                BlocProvider.of<ListSubjectBloc>(context).add(
                              GetLecturerSubject(
                                  academicPeriod: ac, major: value),
                            ),
                          ),
                    );
              });
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Buku Nilai",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "Pilih mata kuliah untuk mengelola nilai mahasiswa",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (state is ListSubjectLoaded) ...[
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${state.subjects.length} Mata Kuliah",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4338CA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // List content
                _buildContent(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ListSubjectState state) {
    if (state is ListSubjectLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1E5AD6),
                strokeWidth: 3,
              ),
              Gap(16),
              Text(
                "Memuat mata kuliah...",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else if (state is ListSubjectLoaded && state.subjects.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _SubjectScoreCard(subject: state.subjects[index]),
            childCount: state.subjects.length,
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
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
                const Gap(24),
                const Text(
                  "Tidak Ada Mata Kuliah",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const Gap(8),
                Text(
                  "Belum ada mata kuliah yang tersedia\npada semester ini.",
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

class _SubjectScoreCard extends StatelessWidget {
  final Subject subject;
  const _SubjectScoreCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final schedules = subject.subjectSchedule;
    final subjectType = schedules.isNotEmpty
        ? (schedules[0]["subject_type"] as String? ?? '').isEmpty
            ? '-'
            : schedules[0]["subject_type"] as String
        : '-';

    final Color typeColor = subjectType == 'T'
        ? const Color(0xFF0EA5E9)
        : subjectType == 'P'
            ? const Color(0xFF10B981)
            : const Color(0xFF8B5CF6);

    final String typeLabel = subjectType == 'T'
        ? 'Teori'
        : subjectType == 'P'
            ? 'Praktikum'
            : subjectType;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E5AD6), Color(0xFF60A5FA)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Subject code + type badge + class badge
                  Row(
                    children: [
                      Text(
                        subject.subjectId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Kelas ${subject.subjectClass}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  // Subject name
                  Text(
                    subject.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const Gap(6),
                  // Major row
                  Row(
                    children: [
                      Icon(Icons.school_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const Gap(4),
                      Text(
                        subject.majorName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const Gap(12),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/lecturer/score",
                              arguments: subject,
                            );
                          },
                          icon: const Icon(Icons.list_alt_rounded, size: 16),
                          label: const Text(
                            "Rekap Nilai",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5AD6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/lecturer/percentage",
                              arguments: subject,
                            );
                          },
                          icon: const Icon(Icons.bar_chart_rounded, size: 16),
                          label: const Text(
                            "Persentase",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
