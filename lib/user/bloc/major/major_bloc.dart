import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/major.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
import 'package:equatable/equatable.dart';

part 'major_event.dart';
part 'major_state.dart';

class MajorBloc extends Bloc<MajorEvent, MajorState> {
  final MajorRepository majorRepository;
  final AcademicPeriodRepository academicPeriodRepository;

  MajorBloc(
      {required this.majorRepository, required this.academicPeriodRepository})
      : super(MajorInitial()) {
    on<GetMajor>((event, emit) async {
      emit(MajorLoading());
      try {
        final academicPeriod =
            await academicPeriodRepository.getCurrentAcademicPeriod();
        final major = await majorRepository
            .getLecturerMajors(academicPeriod == "" ? "0" : academicPeriod);
        await majorRepository.setlecturerMajor("");
        final currentMajor = await majorRepository.getlecturerMajor();
        emit(MajorLoaded(
            major: major, currentMajor: currentMajor, defaultMajor: ""));
      } catch (e) {
        emit(MajorLoadFailed());
      }
    });
  }
}
