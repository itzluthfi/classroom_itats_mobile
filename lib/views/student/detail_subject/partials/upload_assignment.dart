import 'dart:io';

import 'package:classroom_itats_mobile/user/bloc/assignment/assignment_bloc.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class UploadAssignmentBody extends StatefulWidget {
  final double screenWidth;
  final int assignmentId;
  const UploadAssignmentBody(
      {super.key, required this.screenWidth, required this.assignmentId});

  @override
  State<UploadAssignmentBody> createState() => _UploadAssignmentBodyState();
}

class _UploadAssignmentBodyState extends State<UploadAssignmentBody> {
  var _noteController = TextEditingController();
  FilePickerResult? _result;
  File? _file;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: false,
      title: const Text(
        "Upload Tugas",
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        height: 200,
        width: widget.screenWidth,
        child: Column(
          children: [
            const SafeArea(
                child: Text(
              "*note: saat ini aplikasi hanya mensupport file dengan ekstensi pdf, doc, docx, xlsx, csv, rar & zip",
              style: TextStyle(
                  color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            )),
            const Gap(10),
            SafeArea(
              child: CustomTextField(
                label: "Keterangan",
                controller: _noteController,
                isPassword: false,
                width: widget.screenWidth,
                height: 75,
              ),
            ),
            const Gap(10),
            SafeArea(
              child: ElevatedButton(
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
                  fixedSize: Size(widget.screenWidth, 50),
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey)),
                ),
                child: Text(_file != null ? _file!.path : "Pilih file"),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            var path = "";
            var filename = "";
            if (_file != null) {
              path = _file!.path;
              final file = _file!.path.split('/');
              filename = file.last;
            }

            BlocProvider.of<AssignmentBloc>(context).add(SubmitAssignment(
                assignmentId: widget.assignmentId,
                note: _noteController.text,
                fileLink: path,
                fileName: filename));

            BlocProvider.of<AssignmentBloc>(context).add(
                GetStudentSubmitedAssignment(
                    assignmentId: widget.assignmentId));

            Navigator.pop(context, 'OK');
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
