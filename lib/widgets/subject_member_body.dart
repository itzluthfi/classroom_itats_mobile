import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/subject_member/subject_member_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectMemberBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const SubjectMemberBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<SubjectMemberBody> createState() => _SubjectMemberBodyState();
}

class _SubjectMemberBodyState extends State<SubjectMemberBody> {
  // Subject? _subject;
  String? _role;
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  _getUserRole() async {
    _role = await storage.read(key: "role");
  }

  Future<void> _launchInBrowser(Uri url) async {
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _checkLoad();
  }

  _checkLoad() async {
    bool loaded = await widget.userRepository.getWidgetState('subject_member');
    if (!loaded) {
      setState(() {
        BlocProvider.of<SubjectMemberBloc>(context).add(
          GetSubjectMember(
            academicPeriodId: widget.subject.academicPeriodId,
            subjectId: widget.subject.subjectId,
            subjectClass: widget.subject.subjectClass,
            majorId: widget.subject.majorId,
          ),
        );
      });
      await widget.userRepository.setWidgetState('subject_member', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _subject = ModalRoute.of(context)!.settings.arguments as Subject;
    double screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<SubjectMemberBloc, SubjectMemberState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SubjectMemberLoaded) {
          return Placeholder(
            color: Colors.transparent,
            child: RefreshIndicator(
                child: SizedBox(
                  height: double.maxFinite,
                  width: screenWidth,
                  child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      controller: ScrollController(),
                      scrollDirection: Axis.vertical,
                      itemCount: state.subjectMembers.length - 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Gap(20),
                              const Text(
                                "List Mahasiswa",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(20),
                              SizedBox(
                                width: screenWidth,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    "Dosen",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                              const Gap(10),
                              SizedBox(
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.6,
                                                    child: Text(
                                                      state
                                                          .subjectMembers[index]
                                                          .name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.6,
                                                    child: Text(
                                                      state
                                                          .subjectMembers[index]
                                                          .userId,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Gap(screenWidth * 0.04),
                                          IconButton(
                                            onPressed: () {
                                              var phone = state
                                                  .subjectMembers[index]
                                                  .phoneNumber
                                                  .replaceAll(
                                                      RegExp(r'[^0-9]'), '');
                                              _launchInBrowser(
                                                Uri.parse(
                                                    "https://wa.me/$phone"),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.phone_in_talk,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        if (_role == "Mahasiswa") {
                          if (index == 1) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Gap(10),
                                SizedBox(
                                  width: screenWidth,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      "Anda",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                SizedBox(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .userId,
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Gap(5),
                                                Row(
                                                  children: [
                                                    LinearPercentIndicator(
                                                      width: screenWidth * 0.5,
                                                      animation: true,
                                                      lineHeight: 20.0,
                                                      percent: state
                                                              .subjectMembers[
                                                                  index]
                                                              .presence /
                                                          16,
                                                      curve: Curves.linear,
                                                      animationDuration: 1000,
                                                      barRadius:
                                                          const Radius.circular(
                                                              10),
                                                      leading: const Icon(Icons
                                                          .domain_verification),
                                                      center: Text(
                                                          "${(state.subjectMembers[index].presence / 16) * 100}%"),
                                                      progressColor:
                                                          Colors.green,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Gap(screenWidth * 0.04),
                                            IconButton(
                                              onPressed: () {
                                                var phone = state
                                                    .subjectMembers[index]
                                                    .phoneNumber
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'), '');
                                                _launchInBrowser(
                                                  Uri.parse(
                                                      "https://wa.me/$phone"),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.phone_in_talk,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          if (index == 2) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Gap(10),
                                SizedBox(
                                  width: screenWidth,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      "Mahasiswa",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                SizedBox(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .userId,
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Gap(screenWidth * 0.04),
                                            IconButton(
                                              onPressed: () {
                                                var phone = state
                                                    .subjectMembers[index]
                                                    .phoneNumber
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'), '');
                                                _launchInBrowser(
                                                  Uri.parse(
                                                      "https://wa.me/$phone"),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.phone_in_talk,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        if (_role == "Dosen") {
                          if (index == 1) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Gap(10),
                                SizedBox(
                                  width: screenWidth,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      "Mahasiswa",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                SizedBox(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        state
                                                            .subjectMembers[
                                                                index]
                                                            .userId,
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Gap(5),
                                                Row(
                                                  children: [
                                                    LinearPercentIndicator(
                                                      width: screenWidth * 0.5,
                                                      animation: true,
                                                      lineHeight: 20.0,
                                                      percent: state
                                                              .subjectMembers[
                                                                  index]
                                                              .presence /
                                                          16,
                                                      curve: Curves.linear,
                                                      animationDuration: 1000,
                                                      barRadius:
                                                          const Radius.circular(
                                                              10),
                                                      leading: const Icon(Icons
                                                          .domain_verification),
                                                      center: Text(
                                                          "${(state.subjectMembers[index].presence / 16) * 100}%"),
                                                      progressColor:
                                                          Colors.green,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Gap(screenWidth * 0.04),
                                            IconButton(
                                              onPressed: () {
                                                var phone = state
                                                    .subjectMembers[index]
                                                    .phoneNumber
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'), '');
                                                _launchInBrowser(
                                                  Uri.parse(
                                                      "https://wa.me/$phone"),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.phone_in_talk,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return SizedBox(
                            width: screenWidth,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.6,
                                                child: Text(
                                                  state.subjectMembers[index]
                                                      .name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.6,
                                                child: Text(
                                                  state.subjectMembers[index]
                                                      .userId,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          Row(
                                            children: [
                                              LinearPercentIndicator(
                                                width: screenWidth * 0.5,
                                                animation: true,
                                                lineHeight: 20.0,
                                                percent: state
                                                        .subjectMembers[index]
                                                        .presence /
                                                    16,
                                                curve: Curves.linear,
                                                animationDuration: 1000,
                                                barRadius:
                                                    const Radius.circular(10),
                                                leading: const Icon(
                                                    Icons.domain_verification),
                                                center: Text(
                                                    "${(state.subjectMembers[index].presence / 16) * 100}%"),
                                                progressColor: Colors.green,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Gap(screenWidth * 0.04),
                                      IconButton(
                                        onPressed: () {
                                          var phone = state
                                              .subjectMembers[index].phoneNumber
                                              .replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                          _launchInBrowser(
                                            Uri.parse("https://wa.me/$phone"),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.phone_in_talk,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox(
                          width: screenWidth,
                          child: Column(
                            children: [
                              ListTile(
                                title: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.6,
                                              child: Text(
                                                state
                                                    .subjectMembers[index].name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.6,
                                              child: Text(
                                                state.subjectMembers[index]
                                                    .userId,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Gap(screenWidth * 0.04),
                                    IconButton(
                                      onPressed: () {
                                        _launchInBrowser(
                                          Uri(
                                            scheme: "https",
                                            host: "wa.me",
                                            path: state.subjectMembers[index]
                                                .phoneNumber,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.phone_in_talk,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if (_role == "Mahasiswa") {
                          return index > 1
                              ? const Divider()
                              : const Divider(
                                  color: Colors.white,
                                );
                        } else {
                          return index > 0
                              ? const Divider()
                              : const Divider(
                                  color: Colors.white,
                                );
                        }
                      }),
                ),
                onRefresh: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 1000));
                  setState(() {
                    _getUserRole();

                    BlocProvider.of<SubjectMemberBloc>(context).add(
                      GetSubjectMember(
                        academicPeriodId: widget.subject.academicPeriodId,
                        subjectId: widget.subject.subjectId,
                        subjectClass: widget.subject.subjectClass,
                        majorId: widget.subject.majorId,
                      ),
                    );
                  });
                }),
          );
        }
        if (state is SubjectMemberLoading) {
          return const Placeholder(
            color: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Placeholder(
          color: Colors.transparent,
          child: RefreshIndicator(
              child: const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Column(
                      children: [
                        Gap(30),
                        Text(
                          "Mohon maaf, tidak ada data yang dapat ditampilkan",
                        ),
                      ],
                    ),
                  )
                ],
              ),
              onRefresh: () async {
                _getUserRole();

                BlocProvider.of<SubjectMemberBloc>(context).add(
                  GetSubjectMember(
                    academicPeriodId: widget.subject.academicPeriodId,
                    subjectId: widget.subject.subjectId,
                    subjectClass: widget.subject.subjectClass,
                    majorId: widget.subject.majorId,
                  ),
                );
              }),
        );
      },
    );
  }
}
