import 'dart:io';

import 'package:classroom_itats_mobile/auth/bloc/login/login_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class LecturerCreateAssignmentBody extends StatefulWidget {
  final String academicPeriodId;
  final String major;
  const LecturerCreateAssignmentBody(
      {super.key, required this.academicPeriodId, required this.major});

  @override
  State<LecturerCreateAssignmentBody> createState() =>
      _LecturerCreateAssignmentBodyState();
}

class _LecturerCreateAssignmentBodyState
    extends State<LecturerCreateAssignmentBody> {
  FilePickerResult? _result;
  File? _file;
  var classTextEditingController = TextEditingController();
  var weekTextEditingController = TextEditingController();
  var scoreTypeTextEditingController = TextEditingController();
  var assignmentTitle = TextEditingController();
  var assignmentDescription = TextEditingController();
  var isShowTypeTextEditingController = TextEditingController();
  var dateTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Hanya panggil sekali saat halaman pertama dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<AssignmentBloc>(context).add(GetCreateAssignment(
          academicPeriodId: widget.academicPeriodId, major: widget.major));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.9;

    return BlocConsumer<AssignmentBloc, AssignmentState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is AssignmentLoaded) {
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
                          "Buat Tugas Baru",
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
                            label: const Text("Pilih Kelas"),
                            initialSelection: classTextEditingController.text,
                            onSelected: (String? value) {
                              classTextEditingController.text = value ?? "";
                            },
                            dropdownMenuEntries: state.subjects
                                .map((value) => DropdownMenuEntry(
                                    value: value.activityMasterId,
                                    label:
                                        "${value.subjectClass} - ${value.subjectName}"))
                                .toList()),
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
                            dropdownMenuEntries: state.weekAssignments
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
                            label: const Text("Pilih Jenis Nilai"),
                            initialSelection:
                                scoreTypeTextEditingController.text,
                            onSelected: (String? value) {
                              scoreTypeTextEditingController.text = value ?? "";
                            },
                            dropdownMenuEntries: state.scoreType
                                .map((value) => DropdownMenuEntry(
                                    value: value.scoreTypeId,
                                    label: value.scoreTypeDesc))
                                .toList()),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          label: "Judul Tugas",
                          controller: assignmentTitle,
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
                        CustomTextField(
                          label: "Deskripsi Tugas",
                          controller: assignmentDescription,
                          isPassword: false,
                          width: screenWidth,
                          height: 75,
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
                            controller: dateTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              labelText: "pilih tanggal",
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
                                  firstDate: DateTime(int.parse(
                                      widget.academicPeriodId[0] +
                                          widget.academicPeriodId[1] +
                                          widget.academicPeriodId[2] +
                                          widget.academicPeriodId[3])),
                                  lastDate: DateTime(int.parse(
                                          widget.academicPeriodId[0] +
                                              widget.academicPeriodId[1] +
                                              widget.academicPeriodId[2] +
                                              widget.academicPeriodId[3]) +
                                      2));
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
                                    dateTextEditingController.text =
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
                        DropdownMenu<String>(
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
                            label: const Text("Ditampilkan?"),
                            initialSelection:
                                isShowTypeTextEditingController.text,
                            onSelected: (String? value) {
                              isShowTypeTextEditingController.text =
                                  value ?? "";
                            },
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: "true", label: "ya"),
                              DropdownMenuEntry(value: "false", label: "tidak"),
                            ]),
                      ],
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
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
                              ],
                            );

                            if (_result != null) {
                              setState(() {
                                _file = File(_result!.files.single.path ?? "");
                              });
                            } else {}
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            fixedSize: Size(screenWidth, 55),
                            surfaceTintColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.grey)),
                          ),
                          child: Text(
                              _file != null ? _file!.path : "Pilih file tugas"),
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
                                    var path = "";
                                    var filename = "";
                                    if (_file != null) {
                                      path = _file!.path;
                                      final file = _file!.path.split('/');
                                      filename = file.last;
                                    }

                                    BlocProvider.of<AssignmentBloc>(context)
                                        .add(
                                      CreateAssignment(
                                          activityMasterId:
                                              classTextEditingController.text,
                                          weekId:
                                              weekTextEditingController.text,
                                          scoreType:
                                              scoreTypeTextEditingController
                                                  .text,
                                          assignmentTitle: assignmentTitle.text,
                                          assignmentDescription:
                                              assignmentDescription.text,
                                          dueDate:
                                              dateTextEditingController.text,
                                          isShow:
                                              isShowTypeTextEditingController
                                                  .text,
                                          filepath: path,
                                          filename: filename),
                                    );

                                    classTextEditingController.text = "";
                                    weekTextEditingController.text = "";
                                    scoreTypeTextEditingController.text = "";
                                    assignmentTitle.text = "";
                                    assignmentDescription.text = "";
                                    dateTextEditingController.text = "";
                                    isShowTypeTextEditingController.text = "";
                                    _file = null;

                                    BlocProvider.of<AssignmentBloc>(context)
                                        .add(
                                      GetCreateAssignment(
                                          academicPeriodId:
                                              widget.academicPeriodId,
                                          major: ""),
                                    );
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
                    BlocProvider.of<AssignmentBloc>(context).add(
                        GetCreateAssignment(
                            academicPeriodId: widget.academicPeriodId,
                            major: widget.major));
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
                BlocProvider.of<AssignmentBloc>(context).add(
                    GetCreateAssignment(
                        academicPeriodId: widget.academicPeriodId,
                        major: widget.major));
              });
            },
          );
        }
      },
    );
  }
}
