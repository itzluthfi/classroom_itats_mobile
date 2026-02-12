import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/student_score.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:equatable/equatable.dart';

part 'student_score_event.dart';
part 'student_score_state.dart';

class StudentScoreBloc extends Bloc<StudentScoreEvent, StudentScoreState> {
  final SubjectRepository subjectRepository;

  StudentScoreBloc({required this.subjectRepository})
      : super(StudentScoreInitial()) {
    on<GetStudentScore>((event, emit) async {
      emit(StudentScoreLoading());
      try {
        var studentScores = await subjectRepository.getStudentScore(
            event.academicPeriod, event.subjectId, event.subjectClass);

        emit(StudentScoreLoaded(studentScores: studentScores));
      } catch (e) {
        emit(StudentScoreLoadFailed());
      }
    });
  }
}
