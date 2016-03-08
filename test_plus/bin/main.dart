import 'package:tetorica/net_dartio.dart';
import 'package:tetorica/http.dart' as http;
import 'package:test_plus/http.dart' as http;

main() async {
  TetSocketBuilderDartIO builder = new TetSocketBuilderDartIO();
  http.testHttp(builder);
}
