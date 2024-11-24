import 'dart:math';

import 'package:fastinv/home/bloc/home_bloc.dart';
import 'package:fastinv/home/ui/bloc/items_list_view_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../../lists.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final HomeBloc homeBloc = HomeBloc();

class _HomeScreenState extends State<HomeScreen> {
  static final TextEditingController search_controller =
      TextEditingController();
  @override
  void initState() {
    homeBloc.add(HomeInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
        bloc: homeBloc,
        // listenWhen: () {},
        // buildWhen: () {},
        listener: (context, state) async {
          var chosen_name = "",
              chosen_size = "",
              chosen_area = "",
              chosen_quantity = '0';

          if (state.runtimeType == HomeSubmitNewItemDialog) {
            await showDialog<void>(
              context: context,
              /* TODO on dismiss */
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: Row(children: [
                    const Text('Submit New Item'),
                    IconButton(
                        onPressed: () {
                          homeBloc.add(AlertDialogClosedEvent());
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close))
                  ]),
                  content: Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Row(children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text('name'),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue tev) {
                              if (tev.text == "") {
                                return const Iterable<String>.empty();
                              }
                              chosen_name = tev.text.trim().toLowerCase();
                              return g_brand_list.where((b) {
                                return b
                                    .startsWith(tev.text.trim().toLowerCase());
                              });
                            }),
                          )
                        ]),
                        Row(children: [
                          Flexible(
                              flex: 1, fit: FlexFit.tight, child: Text('size')),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue tev) {
                              if (tev.text == "") {
                                return const Iterable<String>.empty();
                              }
                              chosen_size = tev.text.trim().toLowerCase();
                              return g_size_list.where((b) {
                                return b
                                    .startsWith(tev.text.trim().toLowerCase());
                              });
                            }),
                          ),
                        ]),
                        Row(children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text('quantity'),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Autocomplete<int>(
                                optionsBuilder: (TextEditingValue tev) {
                              if (tev.text == "") {
                                return const Iterable<int>.empty();
                              }

                              chosen_quantity = tev.text;
                              return g_quants.where((b) {
                                return b ==
                                    int.parse(tev.text.trim().toLowerCase());
                              });
                            }),
                          )
                        ]),
                        Row(children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text('area'),
                          ),
                          Flexible(
                            /* TODO */
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue tev) {
                              if (tev.text == "") {
                                return const Iterable<String>.empty();
                              }
                              chosen_area = tev.text.trim().toLowerCase();
                              return g_areas_list.where((b) {
                                return b
                                    .startsWith(tev.text.trim().toLowerCase());
                              });
                            }),
                          )
                        ]),
                      ],
                    ),
                  ),
                  actions: [
                    FloatingActionButton(
                        child: Text("submit"),
                        onPressed: () {
                          homeBloc.add(SubmitNewItemFinishedEvent(
                              context,
                              /* TODO */
                              chosen_name,
                              chosen_size,
                              chosen_area,
                              chosen_quantity));
                        }),
                  ],
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: AppBarHeader(),
            ),
            body: [MyBuilder.getBuilder(state, search_controller, homeBloc)][0],
          );
        });
  }
}

/******************************************************************************* 
* table header widget
* id, name etc..
*******************************************************************************/
class TableHeaderText extends StatelessWidget {
  final String text;
  const TableHeaderText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
          color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: TableHeaderText(text: "name")),
          Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: TableHeaderText(text: "size")),
          Flexible(
              flex: 1, fit: FlexFit.tight, child: TableHeaderText(text: "#")),
          // Flexible(
          //     flex: 1,
          //     fit: FlexFit.tight,
          //     child: TableHeaderText(text: "area")),
          // Flexible(
          //   flex: 2,
          //   fit: FlexFit.tight,
          //   child: Icon(Icons.access_time),
          // ),
          // child: TableHeaderText(text: "timestamp")),
        ],
      ),
    );
  }
}

final itemsListViewBloc items_list_view_bloc = itemsListViewBloc();

/******************************************************************************* 
* items list view wdiget
* widget that shows the items table
*******************************************************************************/
class itemsListView extends StatefulWidget {
  var current_color = Colors.white;
  final TextEditingController search_controller;
  int affected_index = -1;
  double current_tile_size = 70;
  final List<dynamic> items_list;
  List<bool> inc_or_dec = [];
  itemsListView(
      {required this.items_list, required this.search_controller, super.key});

  @override
  State<itemsListView> createState() => _itemsListViewState();
}

class _itemsListViewState extends State<itemsListView> {
  static const R = 255;
  static const G = 240;
  static const B = 235;
  static const A = 235;
  static const double hiden_container_maximize_size = 300;
  static const double hidden_container_minimize_size = 5;
  List<List<bool>> checkbox_val = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<itemsListViewBloc, itemsListViewState>(
        bloc: items_list_view_bloc,
        listener: (state, context) {},
        builder: (context, state) {
          if (state.runtimeType != itemsListViewInitial) {
            widget.inc_or_dec =
                (state as IncOrDecState).state.widget.inc_or_dec;
          }
          for (int i = 0; i < widget.items_list.length; ++i) {
            widget.inc_or_dec.add(false);
            checkbox_val.add(<bool>[false, false, false, false, false]);
          }

          /* TODO wrap with scrollview */
          return Expanded(
            child: ListView.builder(
                itemCount: widget.items_list.length,
                itemBuilder: (context, index) {
                  // if (inc_or_dec[index]) {
                  //   widget.current_color = widget.current_color ==
                  //           const Color.fromARGB(255, 253, 250, 205)
                  //       ? Colors.white
                  //       : const Color.fromARGB(255, 253, 250, 205);
                  //   widget.affected_index = index;
                  //   widget.current_tile_size =
                  //       widget.current_tile_size == hiden_container_maximize_size
                  //           ? hidden_container_minimize_size
                  //           : hiden_container_maximize_size;
                  // }
                  if (index == 0) {
                    return Container();
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.inc_or_dec[index] = !widget.inc_or_dec[index];
                        widget.current_color = widget.current_color ==
                                const Color.fromARGB(255, 253, 250, 205)
                            ? Colors.white
                            : const Color.fromARGB(255, 253, 250, 205);
                        print("index = " + index.toString());
                        print("name = " +
                            widget.items_list[index][1].name.toString());
                        print("size = " +
                            widget.items_list[index][1].size.toString());
                        print(widget.current_tile_size);
                        widget.affected_index = index;

                        widget.current_tile_size = (widget.current_tile_size ==
                                hiden_container_maximize_size)
                            ? hidden_container_minimize_size
                            : hiden_container_maximize_size;
                        print(widget.current_tile_size);
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              // border: Border.all(width: 0.2, color: Colors.grey),
                              color: (index != -1)
                                  ? (index == widget.affected_index
                                      ? widget.current_color
                                      : Colors.white)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.only(
                              left: 20, right: 20, bottom: 2, top: 2),
                          child: Row(
                            children: [
                              Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child:
                                      Text(widget.items_list[index][1].name)),
                              Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child:
                                      Text(widget.items_list[index][1].size)),
                              Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Text(
                                      widget.items_list[index][0].toString())),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          height: () {
                            if (index == widget.affected_index) {
                              print("index = " + index.toString());
                              print(widget.current_tile_size);
                              return widget.current_tile_size;
                            }
                            return hidden_container_minimize_size;
                          }(),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                color: (index != -1)
                                    ? (index == widget.affected_index
                                        ? widget.current_color
                                        : Colors.white)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            margin: EdgeInsets.only(
                                left: 20, right: 20, bottom: 2, top: 2),
                            child: Column(
                              children: [
                                Flexible(
                                  flex: 3,
                                  fit: FlexFit.tight,
                                  child: ListView.builder(
                                    itemCount: widget.items_list[index].length,
                                    itemBuilder: (context, j) {
                                      if (j == 0) return Container();
                                      return Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(widget
                                                    .items_list[index][j]
                                                    .quantity
                                                    .toString() +
                                                " " +
                                                widget
                                                    .items_list[index][j].area),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Container(
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color.fromARGB(
                                                    255, 175, 202, 176),
                                              ),
                                              /****************************************************
                                 * increase quantity 
                                ****************************************************/
                                              child: FloatingActionButton(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 175, 202, 176),
                                                  onPressed: () {
                                                    widget.inc_or_dec[index] =
                                                        true;
                                                    // not index !!! rather id  !!!!
                                                    items_list_view_bloc.add(
                                                        IncreaseQuantityEvent(
                                                            widget
                                                                .items_list[
                                                                    index][j]
                                                                .id,
                                                            "inc",
                                                            index,
                                                            j));
                                                  },
                                                  child: Text(
                                                    "+",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black45),
                                                  )),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color.fromARGB(
                                                    255, 243, 206, 189),
                                              ),
                                              /****************************************************
                                 * decrease quantity 
                                ****************************************************/
                                              child: FloatingActionButton(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 243, 206, 189),
                                                  onPressed: () {
                                                    widget
                                                      ..inc_or_dec[index] =
                                                          true;
                                                    // not index !!! rather id  !!!!
                                                    items_list_view_bloc.add(
                                                        IncreaseQuantityEvent(
                                                            widget
                                                                .items_list[
                                                                    index][j]
                                                                .id,
                                                            "dec",
                                                            index,
                                                            j));
                                                  },
                                                  child: Text(
                                                    "-",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black45),
                                                  )),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      " ?",
                                                      style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: checkbox_val[index]
                                                        [j],
                                                    onChanged: (_) {
                                                      setState(() {
                                                        checkbox_val[index][j] =
                                                            !checkbox_val[index]
                                                                [j];
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          DeleteButton(
                                              widget: widget,
                                              index: index,
                                              j: j),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text("action:"),
                                      ),
                                      Container(
                                        // move to
                                        // inc/dec
                                        child: Text("__dropdownmenu__"),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text("by exact quantity:"),
                                      ),
                                      Container(
                                        child: Text("_________"),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text("last changed by:"),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          // TODO
                                          globalUser.user!.email,
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }
}

class DeleteButton extends StatelessWidget {
  itemsListView widget;
  int index;
  int j;
  DeleteButton(
      {required this.widget, required this.index, required this.j, super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
        height: 40,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
          BoxShadow(
              blurStyle: BlurStyle.solid,
              spreadRadius: 0,
              color: const Color.fromARGB(255, 223, 139, 133))
        ]),
        child: IconButton(
            onPressed: () {
              // RemoveEntry();
              homeBloc.add(EntryRemoveButtonPressedEvent(
                  widget.items_list[index][j].id,
                  widget.items_list[index][j].size,
                  widget.search_controller.text));
            },
            icon: Icon(Icons.delete)),
      ),
    );
  }
}

/******************************************************************************* 
* items listview card widget
* 
*******************************************************************************/
class itemsListCard extends StatelessWidget {
  final List<dynamic> items_list;
  final TextEditingController search_controller;
  const itemsListCard(
      {required this.items_list, required this.search_controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: MyCard.getBoxDecoration(),
        child: Column(
          children: [
            TableHeader(),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              height: 0.5,
              color: Colors.grey,
            ),
            itemsListView(
                items_list: items_list, search_controller: search_controller),
          ],
        ),
      ),
    );
  }
}

/*******************************************************************************
 * AppBar Header
*******************************************************************************/
class AppBarHeader extends StatelessWidget {
  const AppBarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      margin: EdgeInsets.all(20),
      child: Row(
        children: [
          Flexible(
            flex: 7,
            fit: FlexFit.tight,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("Fast Inventory",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[800])),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "inventory management",
                    style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
          // Flexible(flex: 2, fit: FlexFit.tight, child: Container()),
          Container(
            child: ElevatedButton(
              onPressed: () {},
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Rayan",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*******************************************************************************
 * Card Decoration
*******************************************************************************/
class MyCard {
  static BoxDecoration getBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );
  }
}

/*******************************************************************************
 * Builder 
 * 
*******************************************************************************/
class MyBuilder {
  static Widget getBuilder(state, search_controller, homeBloc) {
    return Builder(builder: (context) {
      if (state.runtimeType == HomeInitial ||
          state.runtimeType == HomeLoadingState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state.runtimeType == DialogSubmittedState) {
        Navigator.of(context).pop();
        final current_state = state as DialogSubmittedState;
        state = DataTableReadyToShowState(items_list: current_state.items_list);
      }
      if (state.runtimeType == DataTableReadyToShowState) {
        final current_state = state as DataTableReadyToShowState;
        final List<dynamic> items_list = current_state.getResult;
        return Container(
          child: Column(
            children: [
              Container(
                // padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                // decoration: MyCard.getBoxDecoration(),
                child: Row(
                  children: [
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: search_controller,
                            onChanged: (text) {
                              homeBloc.add(HomeSearchBarTypeEvent(
                                  search_controller.text));
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                labelText: 'Search',
                                labelStyle: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: FloatingActionButton.small(
                          backgroundColor: Colors.blue[800],
                          onPressed: () {
                            homeBloc.add(NewItemButtomPressedEvent());
                          },
                          child: Container(
                            child: Text(
                              "add",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              itemsListCard(
                  items_list: items_list, search_controller: search_controller),
            ],
          ),
        );
      }

      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
