import 'package:tetorica/net_dartio.dart';
import 'package:test_plus/http.dart' as http;
import 'package:test_plus/networkinterface.dart' as networkinterface;

main() async {
  TetSocketBuilderDartIO builder = new TetSocketBuilderDartIO();
  http.doTest(builder);
  networkinterface.doTest(builder);
}
