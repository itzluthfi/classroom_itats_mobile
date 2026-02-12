import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/percentage_score.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:equatable/equatable.dart';

part 'percentage_score_event.dart';
part 'percentage_score_state.dart';

class PercentageScoreBloc
    extends Bloc<PercentageScoreEvent, PercentageScoreState> {
  final SubjectRepository subjectRepository;

  PercentageScoreBloc({required this.subjectRepository})
      : super(PercentageScoreInitial()) {
    on<GetPercentageScoreScore>((event, emit) async {
      emit(PercentageScoreLoading());
      try {
        var percentages =
            await subjectRepository.getPercentageScore(event.masterActivityId);
        emit(PercentageScoreLoaded(percentageScores: percentages));
      } catch (e) {
        emit(PercentageScoreLoadFailed());
      }
    });
  }
}
