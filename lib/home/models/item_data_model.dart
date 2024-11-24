class itemDataModel {
  final int? id;
  final String? name;
  final String? size;
  final String? area;
  var quantity;
  final String? timestamp;

  itemDataModel(
      {required this.id,
      required this.name,
      required this.size,
      required this.area,
      required this.quantity,
      required this.timestamp});
  // @override
  // String toString() {
  //   // TODO: implement toString
  //   return this.name! + " " + this.size!;
  // }
}
