import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/academic_period.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:equatable/equatable.dart';

part 'academic_period_event.dart';
part 'academic_period_state.dart';

class AcademicPeriodBloc
    extends Bloc<AcademicPeriodEvent, AcademicPeriodState> {
  final AcademicPeriodRepository academicPeriodRepository;

  AcademicPeriodBloc({required this.academicPeriodRepository})
      : super(AcademicPeriodInitial()) {
    on<GetAcademicPeriod>((event, emit) async {
      emit(AcademicPeriodLoading());
      try {
        final academicPeriod = await academicPeriodRepository.academicPeriod();
        final hasActiveAcademicPeriod =
            await academicPeriodRepository.hasActiveAcademicPeriod();
        final hasCurrentAcademicPeriod =
            await academicPeriodRepository.hasCurrentAcademicPeriod();

        if (!hasActiveAcademicPeriod && !hasCurrentAcademicPeriod) {
          await academicPeriodRepository
              .initActiveAcademicPeriod(academicPeriod);
        }

        final activeAcademicPeriod =
            await academicPeriodRepository.getActiveAcademicPeriod();
        final currentAcademicPeriod =
            await academicPeriodRepository.getCurrentAcademicPeriod();

        emit(AcademicPeriodLoaded(
          academicPeriod: academicPeriod,
          activeAcademicPeriod: activeAcademicPeriod,
          currentAcademicPeriod: currentAcademicPeriod,
        ));
      } catch (e) {
        emit(AcademicPeriodLoadFailed());
      }
    });
  }
}
