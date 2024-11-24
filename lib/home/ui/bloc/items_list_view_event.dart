part of 'items_list_view_bloc.dart';

@immutable
sealed class itemsListViewEvent {}

class IncOrDecEvent extends itemsListViewEvent {
  State<itemsListView> state;
  IncOrDecEvent(this.state);
}
