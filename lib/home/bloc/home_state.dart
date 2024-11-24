part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeLoadingSuccessState extends HomeState {}

final class HomeSubmitNewItemDialog extends HomeState {}

final class DataTableReadyToShowState extends HomeState {
  final List<dynamic> items_list;
  DataTableReadyToShowState({required this.items_list}) {}
  List<dynamic> get getResult => items_list;
}

final class TileOnPressState extends HomeState {
  final int index;

  TileOnPressState(this.index);
}

final class updateTileInfoState extends HomeState {}

final class DialogSubmittedState extends HomeState {
  final List<dynamic> items_list;

  DialogSubmittedState({required this.items_list});
}
