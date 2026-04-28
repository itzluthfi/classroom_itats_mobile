import 'package:classroom_itats_mobile/user/bloc/academic_period/academic_period_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/presensi/presensi_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/models/active_presence.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/student/detail_subject/partials/presence_question_body.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/app_bar.dart';
import 'package:classroom_itats_mobile/views/student/presensi/partials/presensi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentPresensiPage extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const StudentPresensiPage({
    super.key,
    required this.academicPeriodRepository,
  });

  @override
  State<StudentPresensiPage> createState() => _StudentPresensiPageState();
}

class _StudentPresensiPageState extends State<StudentPresensiPage> {
  String? _lastLoadedPeriod;
  String _selectedFilter = 'Belum';

  @override
  void initState() {
    super.initState();
    _getPresensi();
  }

  _getPresensi() async {
    var academicPeriod =
        await widget.academicPeriodRepository.getCurrentAcademicPeriod();
    if (academicPeriod != "" && mounted) {
      _lastLoadedPeriod = academicPeriod;
      context.read<PresensiBloc>().add(ClearPresences());
      context.read<PresensiBloc>().add(LoadActivePresences(academicPeriod));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicPeriodBloc, AcademicPeriodState>(
      listener: (context, state) {
        if (state is AcademicPeriodLoaded) {
          final selectedPeriod = state.currentAcademicPeriod;
          if (selectedPeriod.isNotEmpty &&
              selectedPeriod != _lastLoadedPeriod) {
            _lastLoadedPeriod = selectedPeriod;
            context.read<PresensiBloc>().add(ClearPresences());
            context
                .read<PresensiBloc>()
                .add(LoadActivePresences(selectedPeriod));
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: StudentAppBar(
          academicPeriodRepository: widget.academicPeriodRepository,
        ),
        body: BlocBuilder<PresensiBloc, PresensiState>(
          builder: (context, state) {
            int countSemua = 0;
            int countBelum = 0;
            int countSudah = 0;
            List<ActivePresence> displayList = [];

            if (state is PresensiLoaded) {
              countSemua = state.allPresences.length;
              countBelum = state.belumAbsen.length;
              countSudah = state.sudahAbsen.length;

              switch (_selectedFilter) {
                case 'Belum':
                  displayList = state.belumAbsen;
                  break;
                case 'Sudah':
                  displayList = state.sudahAbsen;
                  break;
                case 'Semua':
                default:
                  displayList = state.allPresences;
                  break;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          state is PresensiLoaded 
                            ? "Presensi Aktif (${displayList.length})"
                            : "Presensi Aktif",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
                        builder: (context, periodState) {
                          String periodName = "Loading...";
                          if (periodState is AcademicPeriodLoaded &&
                              _lastLoadedPeriod != null) {
                            try {
                              final matched = periodState.academicPeriod
                                  .firstWhere((p) =>
                                      p.academicPeriodId == _lastLoadedPeriod);
                              periodName = matched.academicPeriodDecription;
                            } catch (e) {
                              periodName = _lastLoadedPeriod!;
                            }
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.12)),
                            ),
                            child: Text(
                              periodName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        count: countSemua,
                        isSelected: _selectedFilter == 'Semua',
                        onSelected: (val) =>
                            setState(() => _selectedFilter = 'Semua'),
                      ),
                      _buildFilterChip(
                        label: 'Belum',
                        count: countBelum,
                        isSelected: _selectedFilter == 'Belum',
                        onSelected: (val) =>
                            setState(() => _selectedFilter = 'Belum'),
                      ),
                      _buildFilterChip(
                        label: 'Sudah',
                        count: countSudah,
                        isSelected: _selectedFilter == 'Sudah',
                        onSelected: (val) =>
                            setState(() => _selectedFilter = 'Sudah'),
                      ),
                    ],
                  ),
                ),

                // List Area
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is PresensiLoading) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 12.0, bottom: 24.0),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.shade200, width: 1.5),
                              ),
                              child: ShimmerEffect(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.5,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          width: 70,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 100,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.4,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.3,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: double.infinity,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is PresensiError) {
                        return Center(
                          child: Text(
                            "Gagal memuat data presensi\n${state.message}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                        );
                      } else if (state is PresensiLoaded) {
                        return displayList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_busy,
                                        size: 80, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada sesi presensi aktif\nuntuk filter $_selectedFilter',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    top: 8.0,
                                    bottom: 24.0),
                                itemCount: displayList.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final presence = displayList[index];
                                  return PresensiCard(
                                    presence: presence,
                                    onCardTap: () {
                                      if (!presence.sudahPresensi &&
                                          !presence.isHabisWaktu) {
                                        // Konversi ActivePresence → Lecture + Subject
                                        final kul = presence.kul;

                                        final lecture = Lecture(
                                          lectureID: kul.lectureId,
                                          academicPeriodID:
                                              kul.academicPeriodId,
                                          subjectID: kul.subjectId,
                                          majorID: kul.majorId,
                                          lecturerID: kul.lecturerId,
                                          subjectClass: kul.subjectClass,
                                          lectureSchedule: DateTime.tryParse(
                                              kul.lectureSchedule),
                                          lectureType: kul.lectureType,
                                          hourID: kul.hourId,
                                          material: kul.materialRealization,
                                          lectureLink: kul.lectureLink,
                                          approvalStatus: kul.approvalStatus,
                                          weekID: kul.weekId,
                                          timeRealization:
                                              kul.timeRealization,
                                          timeSuitability:
                                              kul.timeSuitability,
                                          materialSuitability:
                                              kul.materialSuitability,
                                          materialLink: kul.materialLink,
                                          presenceLimit: DateTime.tryParse(
                                              kul.presenceLimit),
                                          presenceStudent:
                                              kul.presenceStudent,
                                          linkMeet: kul.linkMeet,
                                          linkRecord: kul.linkRecord,
                                          collegeType: kul.collegeType,
                                          collegeTypeName:
                                              kul.collegeTypeName,
                                        );

                                        final subject = Subject(
                                          subjectClass: kul.subjectClass,
                                          subjectCredits: 0,
                                          subjectId: kul.subjectId,
                                          majorId: kul.majorId,
                                          majorName: "",
                                          academicPeriodId:
                                              kul.academicPeriodId,
                                          lecturerId: kul.lecturerId,
                                          subjectName: kul.subjectName,
                                          totalStudent: 0,
                                          activityMasterId: "",
                                          lecturerName: "",
                                          subjectSchedule: [],
                                        );

                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return CustomAlertDialog(
                                              subject: subject,
                                              screenWidth:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                              lecture: lecture,
                                            );
                                          },
                                        ).then((result) {
                                          // Setelah absen, reload data presensi
                                          final period = _lastLoadedPeriod;
                                          if (result == "OK" &&
                                              period != null &&
                                              context.mounted) {
                                            context.read<PresensiBloc>().add(
                                                  LoadActivePresences(
                                                      period),
                                                );
                                          }
                                        });
                                      }
                                    },
                                  );
                                },
                              );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text("$label ($count)"),
        selected: isSelected,
        selectedColor: const Color(0xFF1E3A8A),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        onSelected: onSelected,
      ),
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent - 0.5) * 2, 0.0, 0.0);
  }
}
