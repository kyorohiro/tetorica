library test_plus.networkinterface;


import 'package:test/test.dart' as test;
import 'package:tetorica/net.dart' as net;

doTest(net.TetSocketBuilder builder) async {
  test.test("put", () async {
    for(net.TetNetworkInterface ni in await builder.getNetworkInterfaces()) {
      print("## ${ni.address} ${ni.name} ${ni.prefixLength}");
    }
  });
}
