part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeInitialEvent extends HomeEvent {}

final class HomeSearchBarTypeEvent extends HomeEvent {
  final String search_string;

  HomeSearchBarTypeEvent(this.search_string);
}

final class NewItemButtomPressedEvent extends HomeEvent {}

final class AlertDialogClosedEvent extends HomeEvent {}

final class SubmitNewItemFinishedEvent extends HomeEvent {
  final String name;
  final String size;
  final String area;
  final String quantity;
  var context;
  SubmitNewItemFinishedEvent(
      this.context, this.name, this.size, this.area, this.quantity);
}

final class TileOnPressEvent extends HomeEvent {
  final int index;

  TileOnPressEvent(this.index);
}

final class updateTileInfoEvent extends HomeEvent {}

final class IncreaseQuantityEvent extends HomeEvent {
  final int id;
  final String action;
  final int index;
  final int j;
  IncreaseQuantityEvent(this.id, this.action, this.index, this.j);
}

final class EntryRemoveButtonPressedEvent extends HomeEvent {
  final String size;
  final int id;
  final String search_text;
  EntryRemoveButtonPressedEvent(this.id, this.size, this.search_text);
}
