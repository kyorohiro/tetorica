library test_plus.stun;

import 'package:test/test.dart' as test;
import 'package:tetorica/net.dart' as net;
import 'package:tetorica/stun.dart' as stun;

doTest(net.TetSocketBuilder builder) async {
  //  -p sets the primary port and defaults to 3478
  //-o sets the secondary port and defaults to 3479
//  stun.StunClient client = new stun.StunClient(builder, "183.181.26.146", 3478);
  stun.StunClient client = new stun.StunClient(builder, "stun.l.google.com", 19302);
  await client.prepare();

  client.test001();
}
