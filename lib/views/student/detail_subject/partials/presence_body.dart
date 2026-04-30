import 'package:classroom_itats_mobile/models/lecture_presence.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/presence_question_body.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

// ─── Warna ───────────────────────────────────────────────────────────────────
const _kGreen  = Color(0xFF10B981);
const _kBlue   = Color(0xFF3B82F6);
const _kRed    = Color(0xFFEF4444);
const _kGray   = Color(0xFFCBD5E1);
const _kNavy   = Color(0xFF1E5AD6);

class StudentPresenceBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const StudentPresenceBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<StudentPresenceBody> createState() => _StudentPresenceBodyState();
}

class _StudentPresenceBodyState extends State<StudentPresenceBody> {
  @override
  void initState() {
    super.initState();
    _checkLoad();
  }

  _checkLoad() {
    // Selalu reload — flag per-subject tidak cukup karena LectureBloc global
    // bisa punya state dari subject lain yang sudah Loaded.
    if (!mounted) return;
    BlocProvider.of<LectureBloc>(context).add(GetStudentLecture(
      academicPeriod: widget.subject.academicPeriodId,
      subjectId: widget.subject.subjectId,
      subjectClass: widget.subject.subjectClass,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LectureBloc, LectureState>(
      listener: (_, __) {},
      builder: (context, state) {
        return RefreshIndicator(
          color: _kNavy,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            setState(() {
              BlocProvider.of<LectureBloc>(context).add(GetStudentLecture(
                academicPeriod: widget.subject.academicPeriodId,
                subjectId: widget.subject.subjectId,
                subjectClass: widget.subject.subjectClass,
              ));
            });
          },
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LectureState state) {
    if (state is LectureLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kNavy),
      );
    }

    List<LecturePresence> lectures = [];
    List<List<LecturePresence>> responsi = [];
    if (state is LectureLoaded) {
      lectures = state.lectures;
      responsi = state.responsiLectures;
    }

    final weekMap = _buildWeekMap(lectures, responsi);

    final totalMeet   = weekMap.values.where((w) => w.isNotEmpty).length;
    final totalHadir  = weekMap.values.where((w) => w.any((lp) => lp.presence != null)).length;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presensi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Gap(2),
                Text(
                  widget.subject.subjectName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (totalMeet > 0) ...[
                  const Gap(18),
                  _ProgressCard(hadir: totalHadir, total: totalMeet),
                ],
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final weekNum = i + 1;
                final entries = weekMap[weekNum] ?? [];
                return _WeekRow(
                  weekNum: weekNum,
                  entries: entries,
                  subject: widget.subject,
                  screenWidth: MediaQuery.of(context).size.width * 0.948,
                );
              },
              childCount: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Mapping weekNum → list of LecturePresence
  Map<int, List<LecturePresence>> _buildWeekMap(
    List<LecturePresence> lectures,
    List<List<LecturePresence>> responsi,
  ) {
    final map = <int, List<LecturePresence>>{};
    for (var i = 1; i <= 16; i++) map[i] = [];

    void add(LecturePresence lp) {
      final w = lp.presence?.weekID ?? lp.lecture?.weekID;
      if (w != null && w >= 1 && w <= 16) map[w]!.add(lp);
    }

    for (final lp in lectures) add(lp);
    for (final r in responsi) for (final lp in r) add(lp);
    return map;
  }
}

// ─── Progress card ────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int hadir;
  final int total;
  const _ProgressCard({required this.hadir, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? hadir / total : 0.0;
    final barColor = pct >= 0.75 ? _kGreen : pct >= 0.5 ? const Color(0xFFF59E0B) : _kRed;
    final label = pct >= 0.75
        ? 'Kehadiran memenuhi syarat'
        : pct >= 0.5
            ? '⚠️ Harap tingkatkan kehadiran'
            : '❌ Di bawah batas minimum';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kNavy, Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ringkasan Kehadiran',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${(pct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const Gap(10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '$hadir',
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, height: 1),
              ),
              TextSpan(
                text: ' / $total pertemuan',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ]),
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 7,
            ),
          ),
          const Gap(8),
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Row satu minggu ──────────────────────────────────────────────────────────
class _WeekRow extends StatelessWidget {
  final int weekNum;
  final List<LecturePresence> entries;
  final Subject subject;
  final double screenWidth;

  const _WeekRow({
    required this.weekNum,
    required this.entries,
    required this.subject,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Kumpulkan tombol-tombol untuk minggu ini
    final buttons = entries.map((lp) => _buildButton(context, lp)).toList();

    // Warna border card
    final borderColor = _cardBorder(entries);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Nomor minggu ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _circleColor(entries).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                weekNum.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: _circleColor(entries),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const Gap(14),

          // ── Label minggu ──
          Expanded(
            child: Text(
              'Minggu ke-$weekNum',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: entries.isEmpty ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
              ),
            ),
          ),

          // ── Tombol status (bisa >1 untuk responsi) ──
          if (buttons.isEmpty)
            _greyChip('Belum ada')
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const Gap(6),
                  buttons[i],
                ]
              ],
            ),
        ],
      ),
    );
  }

  // Satu tombol per LecturePresence
  Widget _buildButton(BuildContext context, LecturePresence lp) {
    if (lp.presence != null) {
      // ── Sudah hadir → hijau, tidak bisa di-klik ──
      return _StatusChip(
        label: 'Hadir',
        color: _kGreen,
        icon: Icons.check_circle_rounded,
      );
    }

    if (lp.lecture != null) {
      final isOpen = lp.lecture!.presenceLimit != null &&
          lp.lecture!.presenceLimit!.compareTo(DateTime.now()) >= 0;

      if (isOpen) {
        // ── Belum hadir, masih buka → biru, bisa klik ──
        return _TapChip(
          label: 'Absen Sekarang',
          color: _kBlue,
          icon: Icons.how_to_reg_rounded,
          onTap: () => _openModal(context, lp),
        );
      } else {
        // ── Belum hadir, sudah tutup → merah ──
        return _StatusChip(
          label: 'Tutup',
          color: _kRed,
          icon: Icons.lock_rounded,
        );
      }
    }

    return const SizedBox.shrink();
  }

  void _openModal(BuildContext context, LecturePresence lp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: PresenceQuestionBody(
                  subject: subject,
                  lecture: lp.lecture!,
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chip abu jika tidak ada data
  Widget _greyChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _kGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
      );

  // Warna border card berdasarkan status terpenting
  Color _cardBorder(List<LecturePresence> entries) {
    if (entries.isEmpty) return Colors.grey.shade100;
    if (entries.any((lp) => lp.presence != null)) return _kGreen.withOpacity(0.25);
    if (entries.any((lp) =>
        lp.lecture?.presenceLimit != null &&
        lp.lecture!.presenceLimit!.compareTo(DateTime.now()) >= 0)) {
      return _kBlue.withOpacity(0.25);
    }
    if (entries.any((lp) => lp.lecture != null)) return _kRed.withOpacity(0.2);
    return Colors.grey.shade100;
  }

  // Warna circle nomor minggu
  Color _circleColor(List<LecturePresence> entries) {
    if (entries.isEmpty) return _kGray;
    if (entries.any((lp) => lp.presence != null)) return _kGreen;
    if (entries.any((lp) =>
        lp.lecture?.presenceLimit != null &&
        lp.lecture!.presenceLimit!.compareTo(DateTime.now()) >= 0)) return _kBlue;
    if (entries.any((lp) => lp.lecture != null)) return _kRed;
    return _kGray;
  }
}

// ─── Chip statis (hadir / tutup) ──────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const Gap(5),
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─── Chip yang bisa diklik (absen sekarang) ────────────────────────────────────
class _TapChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TapChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const Gap(5),
            Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
