library test_plus.stun;

import 'package:test/test.dart' as test;
import 'package:tetorica/net.dart' as net;
import 'package:tetorica/stun.dart' as stun;

doTest(net.TetSocketBuilder builder) async {
//  stun.StunClient client = new stun.StunClient(builder, "183.181.26.146", 19302);
  stun.StunClient client = new stun.StunClient(builder, "stun.l.google.com", 19302);
  client.test001();
}
