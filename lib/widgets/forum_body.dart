import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/forum.dart';
import 'package:classroom_itats_mobile/models/study_material.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/models/user.dart';
import 'package:classroom_itats_mobile/user/bloc/forum/forum_bloc.dart';
import 'package:classroom_itats_mobile/user/bloc/lecture/lecture_bloc.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ForumBody extends StatefulWidget {
  final Subject subject;
  final UserRepository userRepository;

  const ForumBody(
      {super.key, required this.subject, required this.userRepository});

  @override
  State<ForumBody> createState() => _ForumBodyState();
}

class _ForumBodyState extends State<ForumBody> {
  var commentTextEditingController = TextEditingController();
  User? user;
  Function? event;

  @override
  void initState() {
    super.initState();
    _checkLoad();
  }

  _checkLoad() async {
    bool loaded = await widget.userRepository.getWidgetState('forum');
    if (!loaded) {
      setState(() {
        BlocProvider.of<ForumBloc>(context)
            .add(GetForum(masterActivityId: widget.subject.activityMasterId));
      });
      await widget.userRepository.setWidgetState('forum', true);
    }

    String token = await widget.userRepository.getToken();
    user = await widget.userRepository.decodeTokenToUser(token);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.9;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is ForumLoadFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Load Forums Failed'),
              duration: const Duration(milliseconds: 1500),
              width: 280.0, // Width of the SnackBar.
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0, // Inner padding for SnackBar content.
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
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
                      height: 180,
                      width: screenWidth,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          image: DecorationImage(
                            image:
                                AssetImage("assets/application_images/U2.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          borderOnForeground: true,
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Color Overlay to emulate the mockups (greenish/dark tint)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3D3E).withOpacity(
                                      0.4), // Dark greenish-blue overlay with reduced opacity
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.subject.lecturerName.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.subject.subjectName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: _subjectRoomRows(
                                                widget.subject.subjectSchedule),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            widget.subject.subjectClass,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
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
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getForums(
                    context,
                    state,
                    widget.subject,
                    screenWidth,
                    screenHeight,
                    user,
                  ),
                ),
              ],
            ),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1000));
              setState(() {
                BlocProvider.of<ForumBloc>(context).add(GetForum(
                    masterActivityId: widget.subject.activityMasterId));
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  List<Widget> _getForums(
    context,
    state,
    Subject subject,
    double screenWidth,
    double screenHeight,
    User? user,
  ) {
    if (state is ForumLoading) {
      return [
        const Center(
          child: CircularProgressIndicator(),
        ),
      ];
    } else if (state is ForumLoaded && state.announcement.isNotEmpty) {
      return [
        Column(
          children: _listForums(
            context,
            state.announcement,
            screenWidth,
            subject,
            user,
          ),
        )
      ];
    } else {
      return [
        SizedBox(
          width: screenWidth,
          height: screenHeight * 0.5,
          child: const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.forum_outlined,
                        size: 80, color: Colors.grey),
                    Gap(16),
                    Text(
                      "Maaf, tidak ada data forum yang dapat ditampilkan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ];
    }
  }

  List<Widget> _listForums(
    context,
    List<Announcement> announcements,
    double screenWidth,
    Subject subject,
    User? user,
  ) {
    List<Widget> announcementCards = List.empty(growable: true);

    for (var announcement in announcements) {
      var htmlContent = announcement.postContent
          .replaceAll("\\r", "")
          .replaceAll("\\n", "")
          .replaceAll("\\t", "")
          .replaceFirst(r'"', '')
          .replaceAll("\\", "");

      htmlContent = htmlContent.replaceFirst(r'"', '', htmlContent.length - 1);

      announcementCards.add(
        Row(
          children: [
            SizedBox(
              width: screenWidth,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              0.04), // Keeping it for compatibility or use withAlpha(10) if preferred, but withAlpha(10) is safer. Let's use withAlpha(10)
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              announcement.photo != ""
                                  ? CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/img_mhs/${announcement.photo}",
                                        headers: const <String, String>{
                                          "Connection": "Keep-Alive"
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.account_circle_outlined,
                                      size: 30),
                              const Gap(6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.53,
                                        child: Text(
                                          announcement.author,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        announcement.createdAt,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Gap(5),
                                      user != null &&
                                              announcement.authorId == user.name
                                          ? SizedBox(
                                              width: 35,
                                              height: 35,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  shape:
                                                      WidgetStateProperty.all(
                                                    const CircleBorder(),
                                                  ),
                                                  padding:
                                                      WidgetStateProperty.all(
                                                    const EdgeInsets.all(8),
                                                  ),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.amber),
                                                  foregroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context, "/forum/create",
                                                      arguments: <String,
                                                          Object?>{
                                                        "subject": subject,
                                                        "announcement":
                                                            announcement,
                                                      });
                                                },
                                                child: const Icon(Icons.edit),
                                              ),
                                            )
                                          : Column(),
                                      const Gap(5),
                                      user != null &&
                                              announcement.authorId == user.name
                                          ? SizedBox(
                                              width: 35,
                                              height: 35,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  shape:
                                                      WidgetStateProperty.all(
                                                    const CircleBorder(),
                                                  ),
                                                  padding:
                                                      WidgetStateProperty.all(
                                                    const EdgeInsets.all(8),
                                                  ),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.red),
                                                  foregroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white),
                                                ),
                                                onPressed: () {
                                                  BlocProvider.of<ForumBloc>(
                                                          context)
                                                      .add(DeleteForum(
                                                    announcementId: announcement
                                                        .announcementId,
                                                  ));

                                                  BlocProvider.of<ForumBloc>(
                                                          context)
                                                      .add(GetForum(
                                                          masterActivityId: subject
                                                              .activityMasterId));
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Column(),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        const Gap(10),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.8915,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                HtmlWidget(
                                                  htmlContent,
                                                  textStyle: const TextStyle(
                                                      fontSize: 16),
                                                  onTapUrl: (url) {
                                                    _launchInBrowser(Uri.parse(
                                                        url.replaceAll(
                                                            "\\", "")));
                                                    return true;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        announcement.materials.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        height: 100.0 *
                                            announcement.materials.length,
                                        width: screenWidth * 0.8915,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _materialList(context,
                                              subject, announcement.materials),
                                        )),
                                  ],
                                ),
                              )
                            : const Gap(10),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Form(
                                key: GlobalKey<FormState>(),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            CustomTextField(
                                              label: "berikan komentar anda...",
                                              controller:
                                                  commentTextEditingController,
                                              isPassword: false,
                                              width: screenWidth * 0.75,
                                              height: 45,
                                            ),
                                          ],
                                        ),
                                        const Gap(7),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  shape:
                                                      WidgetStateProperty.all(
                                                    const CircleBorder(),
                                                  ),
                                                  padding:
                                                      WidgetStateProperty.all(
                                                    const EdgeInsets.all(9),
                                                  ),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Color(0xFF0072BB)),
                                                  foregroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white),
                                                ),
                                                onPressed: () {
                                                  event ??= () => BlocProvider
                                                          .of<
                                                                  ForumBloc>(
                                                              context)
                                                      .add(CreateForumComment(
                                                          announcementId:
                                                              announcement
                                                                  .announcementId,
                                                          commentContent:
                                                              commentTextEditingController
                                                                  .text,
                                                          createdAt:
                                                              "${DateTime.now().toLocal().toIso8601String()}Z",
                                                          updatedAt:
                                                              "${DateTime.now().toLocal().toIso8601String()}Z"));

                                                  event!();

                                                  BlocProvider.of<ForumBloc>(
                                                          context)
                                                      .add(GetForum(
                                                          masterActivityId: subject
                                                              .activityMasterId));

                                                  commentTextEditingController
                                                      .text = "";
                                                  event = null;
                                                },
                                                child: const Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.5, vertical: 8.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7F9FC), // light modern grey
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _forumComments(
                                  context,
                                  announcement.comments,
                                  screenWidth,
                                  user,
                                  subject,
                                ).isNotEmpty
                                    ? _forumComments(
                                        context,
                                        announcement.comments,
                                        screenWidth,
                                        user,
                                        subject,
                                      )
                                    : [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.8915,
                                              child: const Center(
                                                child: Text(
                                                    "Tidak ada komentar yang dapat ditampilkan"),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      announcementCards.add(
        const Gap(20),
      );
    }
    announcementCards.add(const Gap(80));

    return announcementCards;
  }

  List<Widget> _subjectRoomRows(List<Map<String, dynamic>> subjectSchedules) {
    List<Widget> data = List.empty(growable: true);

    if (subjectSchedules.isEmpty) {
      data.add(const Text(
        "Belum ada jadwal",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
      ));
      return data;
    }

    for (var subjectSchedule in subjectSchedules) {
      // Safety check for keys
      final type = subjectSchedule["subject_type"] ?? "-";
      final room = subjectSchedule["subject_room"] ?? "-";
      final day = subjectSchedule["day"] ?? "";
      final start = subjectSchedule["time_start"];
      final end = subjectSchedule["time_end"];

      String timeStr = "";
      if (start != null && end != null) {
        try {
          final fmtStart = start.toString().split(":").take(2).join(":");
          final fmtEnd = end.toString().split(":").take(2).join(":");
          if (fmtStart.isNotEmpty && fmtEnd.isNotEmpty) {
            timeStr = ", $fmtStart-$fmtEnd";
          }
        } catch (e) {
          timeStr = "";
        }
      }

      data.add(
        Row(
          children: [
            Text(
              "[$type] $room $day$timeStr",
              style: const TextStyle(
                fontSize: 16, // Adjusted slightly for better fit
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          ],
        ),
      );
    }
    return data;
  }

  String _formatCommentDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(dt);
    } catch (e) {
      // Fallback manual formatting if parsing fails
      return dateStr.replaceAll("T", " ").split(".")[0].replaceAll("Z", "");
    }
  }

  List<Widget> _forumComments(
    context,
    List<Comment> forumComments,
    double screenWidth,
    User? user,
    Subject subject,
  ) {
    List<Widget> comments = List.empty(growable: true);

    for (var comment in forumComments) {
      if (comment.announcementId != 0 &&
          comment.author != "" &&
          comment.commentContent != "" &&
          comment.commentId != 0 &&
          comment.createdAt != "") {
        comments.add(
          Row(
            children: [
              Column(
                children: [
                  comment.photo != ""
                      ? CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/img_mhs/${comment.photo}",
                            headers: const <String, String>{
                              "Connection": "Keep-Alive"
                            },
                          ),
                        )
                      : const Icon(Icons.account_circle_outlined, size: 30),
                ],
              ),
              const Gap(6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.53,
                        child: Text(
                          comment.author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _formatCommentDate(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Gap(5),
                      user != null && comment.authorId == user.name
                          ? SizedBox(
                              width: 35,
                              height: 35,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    const CircleBorder(),
                                  ),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(8),
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Colors.amber),
                                  foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white),
                                ),
                                onPressed: () {
                                  commentTextEditingController.text =
                                      comment.commentContent;

                                  event = () =>
                                      BlocProvider.of<ForumBloc>(context)
                                          .add(UpdateForumComment(
                                        commentId: comment.commentId,
                                        commentContent:
                                            commentTextEditingController.text,
                                        announcementId: comment.announcementId,
                                        updatedAt:
                                            "${DateTime.now().toLocal().toIso8601String()}Z",
                                      ));
                                },
                                child: const Icon(Icons.edit),
                              ),
                            )
                          : Column(),
                      const Gap(5),
                      user != null && comment.authorId == user.name
                          ? SizedBox(
                              width: 35,
                              height: 35,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    const CircleBorder(),
                                  ),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(8),
                                  ),
                                  backgroundColor:
                                      const WidgetStatePropertyAll(Colors.red),
                                  foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white),
                                ),
                                onPressed: () {
                                  BlocProvider.of<ForumBloc>(context).add(
                                    DeleteForumComment(
                                      commentId: comment.commentId,
                                    ),
                                  );

                                  BlocProvider.of<ForumBloc>(context).add(
                                      GetForum(
                                          masterActivityId:
                                              subject.activityMasterId));
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Column(),
                    ],
                  )
                ],
              )
            ],
          ),
        );
        comments.add(const Gap(2));
        comments.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.8915,
                        child: HtmlWidget(
                          comment.commentContent.replaceAll("\"", ""),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        comments.add(const Gap(10));
      }
    }

    return comments;
  }

  List<Widget> _materialList(
      context, Subject subject, List<StudyMaterial> announcementMaterials) {
    List<Widget> materials = List.empty(growable: true);

    for (var material in announcementMaterials) {
      materials.add(
        const Gap(5),
      );
      materials.add(
        const Text(
          "Materi : ",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
      materials.add(const Gap(10));
      materials.add(
        ElevatedButton(
          onPressed: () {
            BlocProvider.of<LectureBloc>(context).add(
              DownloadMaterial(fileLink: material.materialLink),
            );

            BlocProvider.of<ForumBloc>(context)
                .add(GetForum(masterActivityId: subject.activityMasterId));
          },
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF0072BB)),
              foregroundColor: WidgetStatePropertyAll(Colors.white)),
          child: const Text("Download Materi"),
        ),
      );
      materials.add(const Gap(10));
    }

    return materials;
  }
}
