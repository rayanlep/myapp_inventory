import 'package:bloc/bloc.dart';
import 'package:fastinv/home/models/item_data_model.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import '../utils/logger.dart';
import '../../postgres/connection.dart';
import 'package:flutter/material.dart';

part 'home_event.dart';
part 'home_state.dart';

const String g_target_table = "items_test";

const int ID = 0;
const int NAME = 1;
const int SIZE = 2;
const int QUANTITY = 3;
const int AREA = 4;
const int TIMESTAMP = 5;
var connection;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late List<dynamic> raw_table;
  List<dynamic> list_for_view = [];
  HomeBloc() : super(HomeInitial()) {
    /**************************************
    * pressing on a tile event
    *
    **************************************/
    on<TileOnPressEvent>((event, emit) {
      Logger.info("TileOnPressEvent ----------");
      var current_index = (event as TileOnPressEvent).index;
      emit(TileOnPressState(current_index));
    });
    /**************************************
    * first initial event on app open
    *
    **************************************/
    on<HomeInitialEvent>((event, emit) async {
      Logger.info("Home Initial Event ----------");

      emit(HomeLoadingState());
      Logger.info("connecting to postgres");
      connection = await OpenConnection();
      final res = await ExecuteQ(
          connection: connection, query: "SELECT *  FROM $g_target_table");

      raw_table = res.map((e) {
        return itemDataModel(
            id: e[ID],
            name: e[NAME].toString(),
            size: e[SIZE].toString(),
            quantity: e[QUANTITY],
            area: e[AREA].toString(),
            timestamp: e[TIMESTAMP]);
      }).toList();

      raw_table.sort((a, b) {
        var res = 0;
        if (0 == (res = a.size.compareTo(b.size))) {
          return a.name.compareTo(b.name);
        }
        return res;
      });

      var old_name = "";
      var old_size = "";
      var group_entries = [];
      raw_table.forEach((a) {
        if (a.name.trim().compareTo(old_name.trim()) == 0 &&
            a.size.trim().compareTo(old_size.trim()) == 0) {
          // areas with quantity !

          group_entries.add(a);
          // print(group_entries);
          group_entries[0] += a.quantity;
        } else {
          list_for_view.add(group_entries);
          old_name = a.name;
          old_size = a.size;
          group_entries = [a.quantity, a];
        }
      });
      // Logger.info(raw_table.toString());
      emit(DataTableReadyToShowState(
          // element is resultRow which has a list of objects
          items_list: list_for_view));
    });

    on<AlertDialogClosedEvent>((event, emit) {
      emit(DataTableReadyToShowState(items_list: raw_table));
    });
    /**************************************
    * user pressed to submit new item
    *
    **************************************/
    on<NewItemButtomPressedEvent>((event, emit) {
      Logger.info("NewItemButtomPressedEvent ----------");

      emit(HomeSubmitNewItemDialog());
    });

    /**************************************
    * user submitted new item
    *
    **************************************/
    on<SubmitNewItemFinishedEvent>((event, emit) async {
      Logger.info("SubmitNewItemFinishedEvent ----------");

      /* update table and counter */
      add_entry(
          event.name.trim().toLowerCase(),
          event.size.trim().toLowerCase(),
          event.area.trim().toLowerCase(),
          event.quantity.trim().toLowerCase());
      var res = await ExecuteQ(
          connection: connection, query: "SELECT *  FROM $g_target_table");

      raw_table = res
          .map((e) => itemDataModel(
              id: e[ID],
              name: e[NAME].toString(),
              size: e[SIZE].toString(),
              quantity: e[QUANTITY],
              area: e[AREA].toString(),
              timestamp: e[TIMESTAMP]))
          .toList();

      emit(DialogSubmittedState(items_list: raw_table));
    });

    on<EntryRemoveButtonPressedEvent>(
      (event, emit) {
        Logger.info("EntryRemoveButtonPressedEvent ----------");

        final String search_string = event.search_text;
        final id = event.id;
        final size = event.size;
        int index = -1;
        int count = 0;
        int i = 0;
        for (; i < raw_table.length; ++i) {
          if (id == raw_table[i].id) {
            index = i;
          }
          // if there are other brands with same size
          if (id != raw_table[i].id && size.compareTo(raw_table[i].size) == 0) {
            count += raw_table[i].quantity as int;
          }
        }

        // there are other entries remove safely
        if (count > 0) {
          RemoveEntry(
              raw_table[index].id,
              raw_table[index].name.trim().toLowerCase(),
              raw_table[index].size.trim().toLowerCase(),
              raw_table[index].quantity.toString().trim().toLowerCase(),
              raw_table[index].area.trim().toLowerCase());
          raw_table.removeAt(index);
        } else {
          raw_table[index].quantity = 0;
          /* add_entry will also update the counter
          we use counter as a sync variable */
          add_entry(
              raw_table[index].name.trim().toLowerCase(),
              raw_table[index].size.trim().toLowerCase(),
              ((-1) * raw_table[index].quantity)
                  .toString()
                  .trim()
                  .toLowerCase(),
              raw_table[index].area.trim().toLowerCase());
        }

        // Logger.info("after removing");
        /* TODO */
        // add entry to postgres !
        emit(DataTableReadyToShowState(
            items_list: raw_table.where((e) {
          if (search_string == "") {
            return true;
          }
          return ((e.name.contains(search_string)) ||
              (e.size.contains(search_string)));
        }).toList()));
      },
    );
    /**************************************
    * user changed quantity of an entry
    * TODO fix this
    **************************************/
    on<IncreaseQuantityEvent>((event, emit) {
      Logger.info("IncreaseQuantityEvent ----------");
      print("id = " + event.id.toString());

      int val = 1;
      if (event.action.compareTo("inc") != 0) {
        val *= -1;
      }
      final id = event.id;
      int i = 0;
      for (; i < raw_table.length; ++i) {
        if (id == raw_table[i].id) {
          break;
        }
      }

      add_entry(raw_table[i].name, raw_table[i].size, raw_table[i].area,
          val.toString());
      // update tables !!
      raw_table[i].quantity += val;
      // get index and alter directly
      // list_for_view[event.index][event.j].quantity += val;
      //
      emit(DataTableReadyToShowState(items_list: list_for_view));
    });

    /**************************************
    * user searched for an item
    *
    **************************************/

    on<HomeSearchBarTypeEvent>((event, emit) async {
      Logger.info("HomeSearchBarTypeEvent ----------");

      final String text = event.search_string.trim().toLowerCase();
      int new_table_change_counter = (await ExecuteQ(
          connection: connection,
          query: "SELECT *  FROM changed_counter"))[0][0] as int;
      /*  check ifa table was changed before, if not dont fetch all data,
      *   if it did, fetch all data */
      var res;
      // if (new_table_change_counter != g_current_table_change_counter) {
      res = await ExecuteQ(
          connection: connection, query: "SELECT *  FROM $g_target_table");

      raw_table = res
          .map((e) => itemDataModel(
              id: e[ID],
              name: e[NAME].toString(),
              size: e[SIZE].toString(),
              quantity: e[QUANTITY],
              area: e[AREA].toString(),
              timestamp: e[TIMESTAMP]))
          .toList();
      // }
      emit(DataTableReadyToShowState(
          items_list: raw_table.where((e) {
        if (text == "") {
          return true;
        }
        return ((e.name.contains(text)) || (e.size.contains(text)));
      }).toList()));
    });
  }
}

Future<void> RemoveEntry(id, name, size, quant, area) async {
  var more_query_to_execute =
      'INSERT INTO outs("name", "size",quantity, area, "timestamp") VALUES(' +
          "'$name', '$size', '$quant', '$area', '" +
          DateTime.now().toString().split(' ')[0] +
          "')";

  // await ExecuteQ(connection: connection, query: more_query_to_execute);

  await ExecuteQ(
      connection: connection,
      query: "DELETE FROM " + g_target_table + " WHERE id = $id");
  // Logger.info("$id");
  return;
}

Future<void> add_entry(
    String name, String size, String area, String quantity) async {
  var new_q = 'SELECT id FROM ' +
      g_target_table +
      ' WHERE position(' +
      " '${name}'" +
      ' in "name") > 0 AND ' +
      " position('${size}'" +
      ' in "size") > 0 AND ' +
      " position('${area}'" +
      ' in "area") > 0';

  var check_if_entry_exists;
  // bool done = false;

  check_if_entry_exists = await ExecuteQ(connection: connection, query: new_q);

  late var query_to_execute = 'INSERT INTO ' +
      g_target_table +
      ' ("name", "size",quantity, area, "timestamp") VALUES' +
      '(' +
      "'" +
      "${name}" +
      "','" +
      "${size}" +
      "','" +
      quantity +
      "','" +
      area +
      "','" +
      DateTime.now().toString().split(' ')[0] +
      "')";

  if (!check_if_entry_exists.isEmpty) {
    query_to_execute = 'UPDATE ' +
        g_target_table +
        ' SET quantity = (quantity +' +
        " ${quantity}), " +
        ' "timestamp" = ' +
        DateTime.now().toString().split(' ')[0] +
        ' WHERE "id" = ${check_if_entry_exists[0][0]}';
  }

  var more_query_to_execute = "";
/*******************************************************************************
 * now query ins or outs 
*******************************************************************************/
  if (int.parse(quantity) > 0) {
    more_query_to_execute =
        'INSERT INTO ins("name", "size",quantity, area, "timestamp") VALUES' +
            '(' +
            "'" +
            "${name}" +
            "','" +
            "${size}" +
            "','" +
            quantity +
            "','" +
            area +
            "','" +
            DateTime.now().toString().split(' ')[0] +
            "')";
  } else {
    more_query_to_execute =
        'INSERT INTO outs("name", "size",quantity, area, "timestamp") VALUES' +
            '(' +
            "'" +
            "${name}" +
            "','" +
            "${size}" +
            "','" +
            (-int.parse(quantity)).toString() +
            "','" +
            area +
            "','" +
            DateTime.now().toString().split(' ')[0] +
            "')";
  }

  // done = false;
  // maximum 185/60/15 3 wc
  // must be in a transaction
  await ExecuteQ(connection: connection, query: query_to_execute);
  // await connection.runTx((s) async {
  //   Logger.info("???" + query_to_execute);
  //   await ExecuteQ(connection: s, query: query_to_execute);
  //   /* TODO */
  //   // await ExecuteQ(more_query_to_execute);
  //   Logger.info("UPDATE changed_counter SET counter = counter + 1");
  //   await ExecuteQ(
  //       connection: s,
  //       query: "UPDATE changed_counter SET counter = counter + 1");
  // });
}
