part of 'items_list_view_bloc.dart';

@immutable
sealed class itemsListViewState {}

final class itemsListViewInitial extends itemsListViewState {}

final class IncOrDecState extends itemsListViewState {
  State<itemsListView> state;
  IncOrDecState(this.state);
}
