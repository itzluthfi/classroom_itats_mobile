import 'package:classroom_itats_mobile/user/cubit/page_index_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LecturerBottomNavbar extends StatefulWidget {
  const LecturerBottomNavbar({super.key});

  @override
  State<LecturerBottomNavbar> createState() => _LecturerBottomNavbarState();
}

class _LecturerBottomNavbarState extends State<LecturerBottomNavbar> {
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageIndexCubit, int>(
      listener: (context, state) {},
      builder: (context, state) {
        return NavigationBar(
          labelBehavior: labelBehavior,
          selectedIndex: state,
          onDestinationSelected: (int index) {
            setState(() {
              context.read<PageIndexCubit>().pageClicked(index);
            });
          },
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.grey,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Forum',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assignment),
              icon: Icon(Icons.assignment_outlined),
              label: 'Presensi',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.folder_copy),
              icon: Icon(Icons.folder_copy_outlined),
              label: 'Materi',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.people_alt),
              icon: Icon(Icons.people_alt_outlined),
              label: 'Mahasiswa',
            ),
          ],
        );
      },
    );
  }
}
