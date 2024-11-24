import 'package:postgres/postgres.dart';
import '../home/utils/logger.dart';

late int g_current_table_change_counter;

Future<dynamic> ExecuteQ(
    {required Connection? connection, required String? query}) async {
  var res;
  if (query == null || Connection == null) {
    return Future.error("null params");
  } else if (connection != null && query != null) {
    while (true) {
      try {
        Logger.info("here?");
        res = await connection.execute(query);
      } catch (e) {
        await connection.close();
        continue;
      }
      break;

      // connection is open
    }
    return res;
  }
  return Future.error("null param");
}

Future<Connection> OpenConnection() async {
  final conn = await Connection.open(
    Endpoint(
      host: '', 
      database: '',
      username: '',
      password: '',
    ),
    // The postgres server hosted locally doesn't have SSL by default. If you're
    // accessing a postgres server over the Internet, the server should support
    // SSL and you should swap out the mode with `SslMode.verifyFull`.
    settings: ConnectionSettings(
      sslMode: SslMode.require,
      connectTimeout: Duration(hours: 1),
    ),
  );

  g_current_table_change_counter =
      (await conn.execute("SELECT * FROM changed_counter"))[0][0] as int;

  return conn;
}
