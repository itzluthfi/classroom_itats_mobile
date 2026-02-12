import 'dart:io';

import 'package:classroom_itats_mobile/models/profile.dart';
import 'package:classroom_itats_mobile/user/bloc/profile/profile_bloc.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileBody extends StatefulWidget {
  final AcademicPeriodRepository academicPeriodRepository;

  const ProfileBody({super.key, required this.academicPeriodRepository});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  File? image;
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widget.academicPeriodRepository.getCurrentAcademicPeriod().then((value) =>
        BlocProvider.of<ProfileBloc>(context)
            .add(GetStudentProfile(academicPeriod: value)));
    double screenWidth = MediaQuery.of(context).size.width * 0.9;

    return BlocConsumer<ProfileBloc, ProfileState>(listener: (context, state) {
      if (state is ProfileLoaded) {
        if (emailController.text == "" && phoneNumberController.text == "") {
          emailController.text = state.profile.email;
          phoneNumberController.text = state.profile.phoneNumber;
        }
      }
    }, builder: (context, state) {
      if (state is ProfileLoaded) {
        return Placeholder(
            color: Colors.transparent,
            child: RefreshIndicator(
                child: ListView(
                  controller: ScrollController(),
                  scrollDirection: Axis.vertical,
                  children: [
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36, vertical: 19),
                                  child: SizedBox(
                                    width: screenWidth * 0.75,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 80,
                                          backgroundImage: NetworkImage(
                                            "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/img_mhs/${state.profile.photo}",
                                            headers: const <String, String>{
                                              "Connection": "Keep-Alive"
                                            },
                                          ),
                                        ),
                                        const Gap(20),
                                        SizedBox(
                                          child: Text(
                                            state.profile.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          child: Text(
                                            state.profile.userId,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const Gap(20),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularPercentIndicator(
                                                  radius: 40.0,
                                                  lineWidth: 10.0,
                                                  animation: true,
                                                  percent: double.parse((state
                                                              .profile
                                                              .presence /
                                                          state.profile
                                                              .totalPresence)
                                                      .toStringAsFixed(0)),
                                                  center: Text(
                                                    "${((state.profile.presence / state.profile.totalPresence) * 100).toStringAsFixed(0)}%",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.0),
                                                  ),
                                                  footer: const Text(
                                                    "Kehadiran",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0),
                                                  ),
                                                  circularStrokeCap:
                                                      CircularStrokeCap.round,
                                                  progressColor:
                                                      const Color(0xFF0072BB),
                                                ),
                                                Gap(screenWidth * 0.15),
                                                CircularPercentIndicator(
                                                  radius: 40.0,
                                                  lineWidth: 10.0,
                                                  animation: true,
                                                  percent: double.parse((state
                                                              .profile
                                                              .assignmentSubmited /
                                                          state.profile
                                                              .totalAssignment)
                                                      .toStringAsFixed(0)),
                                                  center: Text(
                                                    "${((state.profile.assignmentSubmited / state.profile.totalAssignment) * 100).toStringAsFixed(0)}%",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.0),
                                                  ),
                                                  footer: const Text(
                                                    "Tugas Selesai",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0),
                                                  ),
                                                  circularStrokeCap:
                                                      CircularStrokeCap.round,
                                                  progressColor: Colors.amber,
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 19),
                                  child: SizedBox(
                                    width: screenWidth * 0.85,
                                    child: Column(
                                      children: [
                                        const Gap(10),
                                        const Text(
                                          "List Mata Kuliah",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Gap(20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: _getStudentSubjectPresence(
                                              state.profile
                                                  .studentSubjectPresences,
                                              screenWidth),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 19),
                                  child: SizedBox(
                                    width: screenWidth * 0.85,
                                    child: Column(
                                      children: [
                                        const Gap(10),
                                        const Text(
                                          "Update Profile",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Gap(20),
                                        CustomTextField(
                                          label: "Email",
                                          controller: emailController,
                                          isPassword: false,
                                          width: screenWidth * 0.85,
                                          height: 60,
                                        ),
                                        const Gap(20),
                                        CustomTextField(
                                          label: "Nomor Telpon",
                                          controller: phoneNumberController,
                                          isPassword: false,
                                          width: screenWidth * 0.85,
                                          height: 60,
                                        ),
                                        const Gap(20),
                                        ElevatedButton(
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              useSafeArea: true,
                                              showDragHandle: true,
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: double.maxFinite,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            try {
                                                              final image =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.camera);
                                                              if (image ==
                                                                  null) {
                                                                return;
                                                              }
                                                              final imageTemp =
                                                                  File(image
                                                                      .path);
                                                              setState(() =>
                                                                  this.image =
                                                                      imageTemp);
                                                            } on PlatformException catch (_) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
                                                                          'Mohon maaf, gagal mengambil gambar'),
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          1500),
                                                                  width:
                                                                      280.0, // Width of the SnackBar.
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        8.0, // Inner padding for SnackBar content.
                                                                  ),
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            setState(() {
                                                              Navigator
                                                                  .maybePop(
                                                                      context);
                                                            });
                                                          },
                                                          style: ButtonStyle(
                                                            iconColor:
                                                                const MaterialStatePropertyAll(
                                                                    Colors
                                                                        .orange),
                                                            splashFactory: NoSplash
                                                                .splashFactory,
                                                            backgroundColor:
                                                                const MaterialStatePropertyAll(
                                                                    Colors
                                                                        .transparent),
                                                            elevation:
                                                                const MaterialStatePropertyAll(
                                                                    0),
                                                            iconSize:
                                                                MaterialStatePropertyAll(
                                                                    screenWidth *
                                                                        0.25),
                                                            fixedSize:
                                                                MaterialStatePropertyAll(
                                                              Size.fromRadius(
                                                                  screenWidth *
                                                                      0.24),
                                                            ),
                                                            shape:
                                                                MaterialStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0),
                                                              ),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            children: [
                                                              Icon(
                                                                  Icons.camera),
                                                              Text(
                                                                "Ambil gambar dari kamera",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            try {
                                                              final image =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                              if (image ==
                                                                  null) {
                                                                return;
                                                              }
                                                              final imageTemp =
                                                                  File(image
                                                                      .path);
                                                              setState(() =>
                                                                  this.image =
                                                                      imageTemp);
                                                            } on PlatformException catch (_) {}
                                                            setState(() {
                                                              Navigator
                                                                  .maybePop(
                                                                      context);
                                                            });
                                                          },
                                                          style: ButtonStyle(
                                                            iconColor:
                                                                const MaterialStatePropertyAll(
                                                                    Colors.red),
                                                            splashFactory: NoSplash
                                                                .splashFactory,
                                                            backgroundColor:
                                                                const MaterialStatePropertyAll(
                                                                    Colors
                                                                        .transparent),
                                                            elevation:
                                                                const MaterialStatePropertyAll(
                                                                    0),
                                                            iconSize:
                                                                MaterialStatePropertyAll(
                                                                    screenWidth *
                                                                        0.25),
                                                            fixedSize:
                                                                MaterialStatePropertyAll(
                                                              Size.fromRadius(
                                                                  screenWidth *
                                                                      0.24),
                                                            ),
                                                            shape:
                                                                MaterialStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0),
                                                              ),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            children: [
                                                              Icon(Icons.photo),
                                                              Text(
                                                                "Ambil gambar dari galeri",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            elevation: 0,
                                            fixedSize:
                                                Size(screenWidth * 0.85, 60),
                                            surfaceTintColor: Colors.white,
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: const BorderSide(
                                                    color: Colors.grey)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.image),
                                              const Gap(5),
                                              Expanded(
                                                child: Text(
                                                  image != null
                                                      ? image!.path
                                                      : "Pilih Gambar",
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            var path = "";
                                            var filename = "";
                                            if (image != null) {
                                              path = image!.path;
                                              final file =
                                                  image!.path.split('/');
                                              filename = file.last;
                                            }
                                            BlocProvider.of<ProfileBloc>(
                                                    context)
                                                .add(UpdateStudentProfile(
                                              email: emailController.text,
                                              phoneNumber:
                                                  phoneNumberController.text,
                                              filepath: path,
                                              filename: filename,
                                            ));
                                            image = null;
                                            emailController.text = "";
                                            phoneNumberController.text = "";

                                            final academicPeriod = await widget
                                                .academicPeriodRepository
                                                .getCurrentAcademicPeriod();

                                            BlocProvider.of<ProfileBloc>(
                                                    context)
                                                .add(GetStudentProfile(
                                                    academicPeriod:
                                                        academicPeriod));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            fixedSize:
                                                Size(screenWidth * 0.85, 50),
                                            surfaceTintColor: Colors.white,
                                            backgroundColor:
                                                const Color(0xFF0072BB),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text('Submit'),
                                        ),
                                        const Gap(20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                    widget.academicPeriodRepository
                        .getCurrentAcademicPeriod()
                        .then((value) => BlocProvider.of<ProfileBloc>(context)
                            .add(GetStudentProfile(academicPeriod: value)));
                  });
                }));
      }
      if (state is ProfileLoadFailed) {
        return RefreshIndicator(
          child: const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Column(
                  children: [
                    Gap(30),
                    Text("Mohon maaf, tidak ada data yang dapat ditampilkan"),
                  ],
                ),
              )
            ],
          ),
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 1000));
            setState(() {
              widget.academicPeriodRepository.getCurrentAcademicPeriod().then(
                  (value) => BlocProvider.of<ProfileBloc>(context)
                      .add(GetStudentProfile(academicPeriod: value)));
            });
          },
        );
      }
      return Center(
        child: RefreshIndicator(
            child: const CircularProgressIndicator(),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));
              setState(() {
                widget.academicPeriodRepository.getCurrentAcademicPeriod().then(
                    (value) => BlocProvider.of<ProfileBloc>(context)
                        .add(GetStudentProfile(academicPeriod: value)));
              });
            }),
      );
    });
  }
}

List<Widget> _getStudentSubjectPresence(
    List<StudentSubjectPresence> presences, double screenWidth) {
  var data = List<Widget>.empty(growable: true);

  for (var presence in presences) {
    data.add(
      Row(
        children: [
          CircularPercentIndicator(
            radius: 25.0,
            lineWidth: 6.0,
            animation: true,
            percent: double.parse((presence.presence / presence.totalPresence)
                .toStringAsFixed(0)),
            center: Text(
              "${((presence.presence / presence.totalPresence) * 100).toStringAsFixed(0)}%",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: const Color(0xFF0072BB),
          ),
          const Gap(15),
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.55,
                    child: Text(
                      presence.subjectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    "[${presence.subjectClass}]",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
    data.add(
      const Gap(10),
    );
  }

  return data;
}
