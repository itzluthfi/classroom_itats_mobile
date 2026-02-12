import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/models/forum.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/bloc/forum/forum_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class CreateForumPage extends StatefulWidget {
  const CreateForumPage({super.key});

  @override
  State<CreateForumPage> createState() => _CreateForumPageState();
}

class _CreateForumPageState extends State<CreateForumPage> {
  final QuillController _controller = QuillController.basic();
  bool shadowColor = false;
  double? scrolledUnderElevation;
  Map<String, Object?>? _mapped;
  Subject? _subject;
  Announcement? _announcement;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _mapped =
        ModalRoute.of(context)!.settings.arguments! as Map<String, Object?>;

    if (_mapped != null) {
      if (_mapped?["subject"] != null) {
        if (_mapped?["subject"] is Subject) {
          _subject = _mapped?["subject"] as Subject;
        }
      }

      if (_mapped?["announcement"] != null) {
        if (_mapped?["announcement"] is Announcement) {
          _announcement = _mapped?["announcement"] as Announcement;
          var delta = HtmlToDelta().convert(_announcement!.postContent,
              transformTableAsEmbed: false);

          var deltaJson = delta.toJson();

          _controller.document = Document.fromDelta(Delta()
            ..insert(deltaJson[0]["insert"].toString().replaceAll("\"", "")));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          "assets/application_images/Logo_Classroom_Rect-no_bg-rev1.png",
          height: 40,
          width: 200,
          fit: BoxFit.fill,
        ),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor:
            shadowColor == true ? Theme.of(context).colorScheme.shadow : null,
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: IconButton(
          onPressed: () {
            try {
              final deltaOps = _controller.document.toDelta().toJson().toList();

              if (_announcement == null) {
                BlocProvider.of<ForumBloc>(context).add(
                  CreateForum(
                    deltaOps: deltaOps,
                    activityMasterId: _subject!.activityMasterId,
                    // forumContent: html,
                    createdAt: "${DateTime.now().toLocal().toIso8601String()}Z",
                    updatedAt: "${DateTime.now().toLocal().toIso8601String()}Z",
                  ),
                );
              } else {
                BlocProvider.of<ForumBloc>(context).add(
                  UpdateForum(
                    announcementId: _announcement!.announcementId,
                    deltaOps: deltaOps,
                    activityMasterId: _subject!.activityMasterId,
                    // forumContent: html,
                    createdAt: "${DateTime.now().toLocal().toIso8601String()}Z",
                    updatedAt: "${DateTime.now().toLocal().toIso8601String()}Z",
                  ),
                );
              }
            } catch (_) {}

            BlocProvider.of<ForumBloc>(context)
                .add(GetForum(masterActivityId: _subject!.activityMasterId));

            Navigator.maybePop(context);
          },
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF0072BB))),
          icon: const Icon(
            Icons.send_rounded,
            color: Colors.white,
          )),
      body: QuillEditorProvider(
          child: Column(
        children: [
          QuillToolbar.simple(
            controller: _controller,
            configurations: QuillSimpleToolbarConfigurations(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              buttonOptions: const QuillSimpleToolbarButtonOptions(),
              sharedConfigurations: const QuillSharedConfigurations(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: QuillEditor.basic(
                controller: _controller,
                configurations: QuillEditorConfigurations(
                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                  expands: true,
                  scrollable: true,
                  checkBoxReadOnly: true,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
// QuillEditorProvider(
//         controller: _controller,
//         child: Column(
//           children: [
//             QuillToolbar(
//               configurations: const QuillToolbarConfigurations(
//                   buttonOptions: QuillSimpleToolbarButtonOptions(),
//                   sharedConfigurations: QuillSharedConfigurations()),
//               child: build(context),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: QuillEditor.basic(
//                   configurations: QuillEditorConfigurations(
//                       embedBuilders: FlutterQuillEmbeds.editorBuilders(),
//                       expands: true,
//                       scrollable: true,
//                       checkBoxReadOnly: true),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
