import 'package:bloc/bloc.dart';

class PageIndexCubit extends Cubit<int> {
  PageIndexCubit() : super(0);

  void pageClicked(int index) => emit((state - state) + index);

  void resetPage() => emit(0);
}
