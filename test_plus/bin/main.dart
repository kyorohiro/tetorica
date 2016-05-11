import 'package:tetorica/net_dartio.dart';
import 'package:test_plus/http.dart' as http;
import 'package:test_plus/networkinterface.dart' as networkinterface;
import 'package:test_plus/stun.dart' as stun;

main() async {
  TetSocketBuilderDartIO builder = new TetSocketBuilderDartIO();
  http.doTest(builder);
//  networkinterface.doTest(builder);
//  stun.doTest(builder);
}
