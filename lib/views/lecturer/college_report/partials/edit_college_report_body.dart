import 'package:classroom_itats_mobile/auth/bloc/login/login_bloc.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/study_material.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/study_material/study_material_bloc.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class LecturerEditCollegeReportBody extends StatefulWidget {
  final SubjectReport subject;
  final Lecture lecture;
  const LecturerEditCollegeReportBody(
      {super.key, required this.subject, required this.lecture});

  @override
  State<LecturerEditCollegeReportBody> createState() =>
      _LecturerEditCollegeReportBodyState();
}

class _LecturerEditCollegeReportBodyState
    extends State<LecturerEditCollegeReportBody> {
  var collegeDateTextEditingController = TextEditingController();
  var weekTextEditingController = TextEditingController();
  var timeRealizationTextEditingController = TextEditingController();
  var multiSelectController = MultiSelectController<String>();
  var presenceLimitTextEditingController = TextEditingController();
  var collegeTypeEditingController = TextEditingController(text: "1");
  var materialRealizationTextEditingController = TextEditingController();
  List<Map<String, String>> materialTextEditingController =
      List.empty(growable: true);

  List<DropdownItem<String>> materials = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _setInputValue();
  }

  @override
  void dispose() {
    setState(() {
      multiSelectController.clearAll();
      collegeDateTextEditingController.text = DateFormat("y-M-d")
          .parse(widget.lecture.lectureSchedule.toString())
          .toString()
          .split(" ")[0];
      weekTextEditingController.text = widget.lecture.weekID.toString();
      timeRealizationTextEditingController.text =
          widget.lecture.timeRealization.toString();
      presenceLimitTextEditingController.text =
          widget.lecture.presenceLimit.toString().replaceAll("Z", "");
      collegeTypeEditingController.text = widget.lecture.collegeType.toString();
      materialRealizationTextEditingController.text =
          widget.lecture.material.toString();
    });

    super.dispose();
  }

  _setInputValue() {
    setState(() {
      BlocProvider.of<StudyMaterialBloc>(context).add(
          GetLecturerMaterialWithDrowpdownValue(
              lectureId: widget.lecture.lectureID!));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.9;
    return BlocConsumer<StudyMaterialBloc, StudyMaterialState>(
      listener: (context, state) {
        if (state is StudyMaterialLoaded) {
          setState(() {
            collegeDateTextEditingController.text = DateFormat("y-M-d")
                .parse(widget.lecture.lectureSchedule.toString())
                .toString()
                .split(" ")[0];
            weekTextEditingController.text = widget.lecture.weekID.toString();
            timeRealizationTextEditingController.text =
                widget.lecture.timeRealization.toString();
            presenceLimitTextEditingController.text =
                widget.lecture.presenceLimit.toString().replaceAll("Z", "");
            collegeTypeEditingController.text =
                widget.lecture.collegeType.toString();
            materialRealizationTextEditingController.text =
                widget.lecture.material.toString();

            materials =
                _materialMap(state.studyMaterials, state.selectedMaterials);
          });
        }
      },
      builder: (context, state) {
        if (state is StudyMaterialLoaded) {
          return Form(
              key: GlobalKey<FormState>(),
              child: RefreshIndicator(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    const Gap(20),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Buat Pelaporan Baru",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const Gap(20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(10),
                        SizedBox(
                          width: screenWidth,
                          height: 60,
                          child: TextFormField(
                            controller: collegeDateTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              labelText: "pilih tanggal Perkuliahan",
                              suffixIcon: Icon(Icons.date_range_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                  width: 2,
                                ),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickdate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 90)));
                              if (pickdate != null) {
                                setState(() {
                                  collegeDateTextEditingController.text =
                                      DateFormat("yyyy-MM-dd").format(
                                    DateTime(
                                      pickdate.year,
                                      pickdate.month,
                                      pickdate.day,
                                    ),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownMenu<String>(
                            textStyle: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            menuStyle: const MenuStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                              fixedSize:
                                  WidgetStatePropertyAll(Size.fromHeight(200)),
                              maximumSize:
                                  WidgetStatePropertyAll(Size.fromHeight(200)),
                            ),
                            width: screenWidth,
                            label: const Text("Pilih Minggu"),
                            initialSelection: weekTextEditingController.text,
                            onSelected: (String? value) {
                              weekTextEditingController.text = value ?? "";
                            },
                            dropdownMenuEntries: state.weekMaterials
                                .map((value) => DropdownMenuEntry(
                                    value: "${value.weekId}",
                                    label: "Minggu Ke - ${value.weekId}"))
                                .toList()),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          label: "Realisasi Waktu",
                          controller: timeRealizationTextEditingController,
                          isPassword: false,
                          width: screenWidth,
                          height: 75,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth,
                          height: 60,
                          child: MultiDropdown<String>(
                            items: materials,
                            controller: multiSelectController,
                            enabled: true,
                            searchEnabled: true,
                            chipDecoration: const ChipDecoration(
                              backgroundColor: Colors.yellow,
                              wrap: true,
                              runSpacing: 2,
                              spacing: 10,
                            ),
                            fieldDecoration: FieldDecoration(
                              padding: const EdgeInsets.all(20),
                              hintText: 'Pilih Materi',
                              hintStyle:
                                  const TextStyle(color: Colors.blueGrey),
                              prefixIcon: const Icon(Icons.book),
                              showClearIcon: false,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.blueGrey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            dropdownDecoration: const DropdownDecoration(
                              maxHeight: 300,
                              header: Padding(
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                            dropdownItemDecoration: DropdownItemDecoration(
                              selectedIcon: const Icon(Icons.check_box,
                                  color: Colors.green),
                              disabledIcon:
                                  Icon(Icons.lock, color: Colors.grey.shade300),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih materi';
                              }
                              return null;
                            },
                            onSelectionChange: (selectedItems) {
                              materialTextEditingController =
                                  List.empty(growable: true);
                              for (var element in selectedItems) {
                                materialTextEditingController.add({
                                  "material_id": element,
                                });
                              }
                              debugPrint("OnSelectionChange: $selectedItems");
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(10),
                        SizedBox(
                          width: screenWidth,
                          height: 60,
                          child: TextFormField(
                            controller: presenceLimitTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              labelText: "pilih Batas Presensi",
                              suffixIcon: Icon(Icons.date_range_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                  width: 2,
                                ),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickdate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 90)));
                              if (pickdate != null) {
                                TimeOfDay? picktime = await showTimePicker(
                                  context: context,
                                  initialEntryMode: TimePickerEntryMode.input,
                                  initialTime: TimeOfDay(
                                      hour: DateTime.now().hour,
                                      minute: DateTime.now().hour),
                                );
                                if (picktime != null) {
                                  setState(() {
                                    presenceLimitTextEditingController.text =
                                        DateFormat("yyyy-MM-dd HH:mm:ss")
                                            .format(
                                      DateTime(
                                        pickdate.year,
                                        pickdate.month,
                                        pickdate.day,
                                        picktime.hour,
                                        picktime.minute,
                                      ),
                                    );
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownMenu<int>(
                            textStyle: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            menuStyle: MenuStyle(
                              shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                              fixedSize: WidgetStatePropertyAll(
                                  Size.fromWidth(screenWidth)),
                              maximumSize: WidgetStatePropertyAll(
                                  Size.fromWidth(screenWidth)),
                            ),
                            width: screenWidth,
                            label: const Text("Jenis Perkuliahan"),
                            initialSelection:
                                int.tryParse(collegeTypeEditingController.text),
                            onSelected: (int? value) {
                              collegeTypeEditingController.text =
                                  value.toString();
                            },
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: 1, label: "offline"),
                            ]),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          label: "Realisasi Materi",
                          controller: materialRealizationTextEditingController,
                          isPassword: false,
                          width: screenWidth,
                          height: 75,
                        ),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Placeholder(
                          color: Colors.transparent,
                          child: state is LoginLoading
                              ? const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      BlocProvider.of<LectureBloc>(context).add(
                                        EditLectureReport(
                                          lectureId: widget.lecture.lectureID!,
                                          academicPeriodId:
                                              widget.subject.academicPeriodId,
                                          subjectId: widget.subject.subjectId,
                                          majorId: widget.subject.majorId,
                                          lecturerId: widget.subject.lecturerId,
                                          subjectClass:
                                              widget.subject.subjectClass,
                                          lectureSchedule:
                                              "${collegeDateTextEditingController.text}T00:00:00Z",
                                          lectureType:
                                              widget.subject.collegeType,
                                          subjectCredit:
                                              widget.subject.subjectCredits,
                                          hourId: widget.subject.hourId,
                                          material:
                                              materialTextEditingController,
                                          entryTime:
                                              "${DateTime.now().toString().replaceAll(" ", "T")}Z",
                                          approvalStatus:
                                              widget.lecture.approvalStatus!,
                                          weekId: int.parse(
                                              weekTextEditingController.text),
                                          timeRealization: int.parse(
                                              timeRealizationTextEditingController
                                                  .text),
                                          materialRealization:
                                              materialRealizationTextEditingController
                                                  .text,
                                          presenceLimit:
                                              "${presenceLimitTextEditingController.text.replaceAll(" ", "T")}Z",
                                          collegeType: int.parse(
                                              collegeTypeEditingController
                                                  .text),
                                        ),
                                      );

                                      BlocProvider.of<LectureBloc>(context)
                                          .add(ClearStateLecture());
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(screenWidth, 60),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: const Color(0xFF0072BB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Submit'),
                                ),
                        ),
                      ],
                    ),
                    const Gap(20),
                  ],
                ),
                onRefresh: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));

                  setState(() {
                    BlocProvider.of<StudyMaterialBloc>(context)
                        .add(ClearStateStudyMaterial());

                    BlocProvider.of<StudyMaterialBloc>(context).add(
                        GetLecturerMaterialWithDrowpdownValue(
                            lectureId: widget.lecture.lectureID!));
                  });
                },
              ));
        } else {
          return RefreshIndicator(
            child: const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));

              setState(() {
                BlocProvider.of<StudyMaterialBloc>(context)
                    .add(ClearStateStudyMaterial());

                BlocProvider.of<StudyMaterialBloc>(context).add(
                    GetLecturerMaterialWithDrowpdownValue(
                        lectureId: widget.lecture.lectureID!));
              });
            },
          );
        }
      },
    );
  }
}

List<DropdownItem<String>> _materialMap(
    List<StudyMaterial> materials, List<StudyMaterial> initialValue) {
  List<DropdownItem<String>> items = List.empty(growable: true);
  for (var material in materials) {
    if (initialValue.isNotEmpty) {
      var flag = false;
      for (var initial in initialValue) {
        if (material.materialId == initial.materialId) {
          flag = true;
          break;
        }
      }
      if (flag) {
        items.add(DropdownItem(
          label: material.materialTitle,
          value: material.materialId,
          selected: true,
        ));
      } else {
        items.add(DropdownItem(
          label: material.materialTitle,
          value: material.materialId,
        ));
      }
    } else {
      items.add(DropdownItem(
        label: material.materialTitle,
        value: material.materialId,
      ));
    }
  }

  return items;
}
