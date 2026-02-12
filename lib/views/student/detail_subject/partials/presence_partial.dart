import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentPresencePartial extends StatefulWidget {
  final Widget button;

  const StudentPresencePartial({super.key, required this.button});

  @override
  State<StudentPresencePartial> createState() => StudentPresencePartialState();
}

class StudentPresencePartialState extends State<StudentPresencePartial> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.88;

    return Row(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Card(
                          surfaceTintColor: Colors.white,
                          elevation: 0,
                          color: Colors.white,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: SizedBox(
                              width: screenWidth,
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [widget.button],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
          ],
        ),
      ],
    );
  }
}
