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
  String _selectedFilter = 'Semua';

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<PresensiBloc, PresensiState>(
                builder: (context, state) {
                  if (state is PresensiLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PresensiError) {
                    return Center(
                      child: Text(
                        "Gagal memuat data presensi\n${state.message}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    );
                  } else if (state is PresensiLoaded) {
                    List<ActivePresence> displayList;
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                              top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
                          color: const Color(0xFFF8FAFC),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  "Presensi Aktif (${displayList.length})",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              BlocBuilder<AcademicPeriodBloc,
                                  AcademicPeriodState>(
                                builder: (context, periodState) {
                                  String periodName = "Memuat periode...";
                                  if (periodState is AcademicPeriodLoaded &&
                                      _lastLoadedPeriod != null) {
                                    try {
                                      final matched = periodState.academicPeriod
                                          .firstWhere((p) =>
                                              p.academicPeriodId ==
                                              _lastLoadedPeriod);
                                      periodName =
                                          matched.academicPeriodDecription;
                                    } catch (e) {
                                      periodName = _lastLoadedPeriod!;
                                    }
                                  }
                                  return Text(
                                    periodName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade600,
                                      fontWeight: FontWeight.w500,
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
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: ['Semua', 'Belum', 'Sudah']
                                .map((String filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  selectedColor: const Color(0xFF1E3A8A),
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedFilter == filter
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: _selectedFilter == filter
                                          ? Colors.transparent
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedFilter = filter;
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: displayList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_busy,
                                          size: 80,
                                          color: Colors.grey.shade400),
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
                                ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
