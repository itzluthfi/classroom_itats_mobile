import 'package:classroom_itats_mobile/models/student_score.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/student_score/student_score_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SubjectScoreBody extends StatefulWidget {
  final Subject subject;

  const SubjectScoreBody({super.key, required this.subject});

  @override
  State<SubjectScoreBody> createState() => _SubjectScoreBodyState();
}

class _SubjectScoreBodyState extends State<SubjectScoreBody> {
  @override
  void initState() {
    super.initState();
    _fetchScore();
  }

  void _fetchScore() {
    BlocProvider.of<StudentScoreBloc>(context).add(
      GetStudentScore(
        academicPeriod: widget.subject.academicPeriodId,
        subjectId: widget.subject.subjectId,
        subjectClass: widget.subject.subjectClass,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentScoreBloc, StudentScoreState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: RefreshIndicator(
            color: const Color(0xFF1E5AD6),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 800));
              _fetchScore();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Subject Header
                SliverToBoxAdapter(
                  child: _buildHeader(state),
                ),
                // Student list
                _buildContent(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(StudentScoreState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF1E5AD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E5AD6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.subject.subjectName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Gap(6),
          Text(
            "${widget.subject.lecturerId} - ${widget.subject.lecturerName}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(Icons.class_outlined, "Kelas ${widget.subject.subjectClass}"),
              const Gap(8),
              if (state is StudentScoreLoaded)
                _infoChip(Icons.people_outline, "${state.studentScores.length} Mahasiswa"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const Gap(5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StudentScoreState state) {
    if (state is StudentScoreLoading) {
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
                "Memuat data nilai...",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else if (state is StudentScoreLoaded && state.studentScores.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _StudentScoreCard(
              score: state.studentScores[index],
              rank: index + 1,
            ),
            childCount: state.studentScores.length,
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
                  child: Icon(Icons.assignment_outlined,
                      size: 60, color: Colors.grey.shade400),
                ),
                const Gap(20),
                const Text(
                  "Tidak Ada Data",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const Gap(8),
                Text(
                  "Belum ada mahasiswa yang terdaftar\npada mata kuliah ini.",
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

class _StudentScoreCard extends StatelessWidget {
  final StudentScore score;
  final int rank;

  const _StudentScoreCard({required this.score, required this.rank});

  Color _scoreColor(String alphabetic) {
    switch (alphabetic.toUpperCase().trim()) {
      case 'A':
        return const Color(0xFF059669);
      case 'A-':
        return const Color(0xFF10B981);
      case 'B+':
        return const Color(0xFF0EA5E9);
      case 'B':
        return const Color(0xFF3B82F6);
      case 'B-':
        return const Color(0xFF6366F1);
      case 'C+':
      case 'C':
        return const Color(0xFFF59E0B);
      case 'D':
        return const Color(0xFFF97316);
      case 'E':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasScore =
        score.numericScore.isNotEmpty || score.alphabeticScore.isNotEmpty;
    final Color gradeColor =
        hasScore ? _scoreColor(score.alphabeticScore) : const Color(0xFF94A3B8);

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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                "$rank",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const Gap(12),
            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    score.studentId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    score.sudentName.trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            // Score section
            hasScore
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Numeric score
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score.numericScore,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: gradeColor,
                          ),
                        ),
                      ),
                      const Gap(5),
                      // Alphabetic score badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: gradeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score.alphabeticScore,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      "Belum ada\nnilai",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
