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
        return RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 1000));
            setState(() {
              BlocProvider.of<ForumBloc>(context).add(GetForum(
                  masterActivityId: widget.subject.activityMasterId));
            });
          },
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
                            // Color Overlay
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3D3E).withOpacity(0.4),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                          color: Colors.white.withOpacity(0.25),
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
                    Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
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
        Center(
          child: Container(
            width: screenWidth,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Post
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      announcement.photo != ""
                          ? CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/img_mhs/${announcement.photo}",
                              ),
                            )
                          : CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(Icons.person,
                                  color: Colors.grey.shade400, size: 20),
                            ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.author,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatCommentDate(announcement.createdAt),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      if (user != null && announcement.authorId == user.name)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 18, color: Colors.amber),
                              onPressed: () {
                                Navigator.pushNamed(context, "/forum/create",
                                    arguments: {
                                      "subject": subject,
                                      "announcement": announcement,
                                    });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              onPressed: () {
                                BlocProvider.of<ForumBloc>(context).add(
                                    DeleteForum(
                                        announcementId:
                                            announcement.announcementId));
                                BlocProvider.of<ForumBloc>(context).add(
                                    GetForum(
                                        masterActivityId:
                                            subject.activityMasterId));
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: HtmlWidget(
                    htmlContent,
                    textStyle: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
                const Gap(12),
                // Materials
                if (announcement.materials.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Lampiran Materi:",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const Gap(8),
                        ..._materialList(
                            context, subject, announcement.materials),
                      ],
                    ),
                  ),
                const Gap(8),
                // Comment Input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Tulis komentar...",
                          controller: commentTextEditingController,
                          isPassword: false,
                          height: 45,
                          width: screenWidth * 0.7,
                        ),
                      ),
                      const Gap(8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF0072BB)),
                        onPressed: () {
                          if (commentTextEditingController.text.trim().isEmpty)
                            return;
                          BlocProvider.of<ForumBloc>(context)
                              .add(CreateForumComment(
                            announcementId: announcement.announcementId,
                            commentContent: commentTextEditingController.text,
                            createdAt:
                                "${DateTime.now().toLocal().toIso8601String()}Z",
                            updatedAt:
                                "${DateTime.now().toLocal().toIso8601String()}Z",
                          ));
                          BlocProvider.of<ForumBloc>(context).add(GetForum(
                              masterActivityId: subject.activityMasterId));
                          commentTextEditingController.clear();
                        },
                      ),
                    ],
                  ),
                ),
                // Comments List
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _forumComments(context, announcement.comments,
                            screenWidth, user, subject)
                        .isNotEmpty
                        ? _forumComments(context, announcement.comments,
                            screenWidth, user, subject)
                        : [
                            const Center(
                                child: Text("Belum ada komentar",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)))
                          ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    announcementCards.add(const Gap(80));

    return announcementCards;
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
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
                fontSize: 16,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    comment.photo != ""
                        ? CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/img_mhs/${comment.photo}",
                            ),
                          )
                        : CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(Icons.person,
                                size: 18, color: Colors.grey.shade400),
                          ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.author,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    _formatCommentDate(comment.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              if (user != null && comment.authorId == user.name)
                                Row(
                                  children: [
                                    _buildActionIconButton(
                                      icon: Icons.edit_rounded,
                                      color: Colors.amber,
                                      onTap: () {
                                        commentTextEditingController.text =
                                            comment.commentContent;
                                        event = () => BlocProvider.of<
                                                ForumBloc>(context)
                                            .add(
                                          UpdateForumComment(
                                            commentId: comment.commentId,
                                            commentContent:
                                                commentTextEditingController
                                                    .text,
                                            announcementId:
                                                comment.announcementId,
                                            updatedAt:
                                                "${DateTime.now().toLocal().toIso8601String()}Z",
                                          ),
                                        );
                                      },
                                    ),
                                    const Gap(4),
                                    _buildActionIconButton(
                                      icon: Icons.delete_rounded,
                                      color: Colors.red,
                                      onTap: () {
                                        BlocProvider.of<ForumBloc>(context).add(
                                          DeleteForumComment(
                                              commentId: comment.commentId),
                                        );
                                        BlocProvider.of<ForumBloc>(context).add(
                                          GetForum(
                                              masterActivityId:
                                                  subject.activityMasterId),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const Gap(4),
                          HtmlWidget(
                            comment.commentContent.replaceAll("\"", ""),
                            textStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    return comments;
  }

  String _getFileName(String url) {
    try {
      String fileName = url.split('/').last;
      return fileName.length > 30
          ? "${fileName.substring(0, 27)}..."
          : fileName;
    } catch (e) {
      return "Lampiran Materi";
    }
  }

  List<Widget> _materialList(
      context, Subject subject, List<StudyMaterial> announcementMaterials) {
    List<Widget> materials = List.empty(growable: true);

    for (var material in announcementMaterials) {
      String fileName = _getFileName(material.materialLink);

      materials.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          width: double.infinity,
          child: InkWell(
            onTap: () {
              BlocProvider.of<LectureBloc>(context).add(
                DownloadMaterial(fileLink: material.materialLink),
              );
              BlocProvider.of<ForumBloc>(context)
                  .add(GetForum(masterActivityId: subject.activityMasterId));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0072BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.file_present_rounded,
                      color: Color(0xFF0072BB),
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "Klik untuk mengunduh materi",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.download_for_offline_rounded,
                    color: Color(0xFF0072BB),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return materials;
  }
}
