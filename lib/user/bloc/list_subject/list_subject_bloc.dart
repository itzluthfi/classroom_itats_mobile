import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:equatable/equatable.dart';

part 'list_subject_event.dart';
part 'list_subject_state.dart';

class ListSubjectBloc extends Bloc<ListSubjectEvent, ListSubjectState> {
  final SubjectRepository subjectRepository;

  ListSubjectBloc({required this.subjectRepository})
      : super(ListSubjectInitial()) {
    on<GetLecturerSubject>((event, emit) async {
      emit(ListSubjectLoading());
      try {
        final subjects = await subjectRepository.getSubjectsFiltered(
            event.academicPeriod, event.major);

        emit(ListSubjectLoaded(subjects: subjects));
      } catch (e) {
        emit(ListSubjectLoadFailed());
      }
    });
  }
}
