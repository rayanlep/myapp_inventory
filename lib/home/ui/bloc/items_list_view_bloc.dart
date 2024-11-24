import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import '../home.dart';

part 'items_list_view_event.dart';
part 'items_list_view_state.dart';

class itemsListViewBloc extends Bloc<itemsListViewEvent, itemsListViewState> {
  itemsListViewBloc() : super(itemsListViewInitial()) {
    on<itemsListViewEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
