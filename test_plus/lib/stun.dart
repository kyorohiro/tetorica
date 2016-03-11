library test_plus.stun;

import 'package:test/test.dart' as test;
import 'package:tetorica/net.dart' as net;
import 'package:tetorica/stun.dart' as stun;

doTest(net.TetSocketBuilder builder) async {
  //  -p sets the primary port and defaults to 3478
  //-o sets the secondary port and defaults to 3479
  stun.StunClient clientSrc = new stun.StunClient(builder,  "0.0.0.0", 18081, "183.181.26.146", 3478);
  stun.StunClientBasicTest client = new stun.StunClientBasicTest(clientSrc);
  await client.prepare();

  //print("#### \n ${await client.testBasic([])} \n####");

  print("################### test001");
  stun.StunRfcVersion version = stun.StunRfcVersion.ref5389;
  //stun.StunRfcVersion version = stun.StunRfcVersion.ref3489;
  try {
    stun.StunClientSendHeaderResult r = await client.test001(version: version);
    print("-ra- ${r.remoteAddress} ${r.remotePort} ");
    print("-ma- ${r.header.mappedAddress()} ${r.header.mappedPort()} ${r.header.haveMappedAddress()}");
    print("-ora- ${r.header.originAddress()} ${r.header.originPort()} ${r.header.haveOriginAddress()}");
    print("-ota- ${r.header.otherAddress()} ${r.header.otherPort()} ${r.header.haveOtherAddress()}");
  } catch (e, t) {
    print("EE ${e} ${t}");
  }
  print("################### test002");
  try {
    stun.StunClientSendHeaderResult r = await client.test002(version: version);
    print("-z- ${r.remoteAddress} ${r.remotePort} ${r.header.mappedAddress()} ${r.header.mappedPort()}");
  } catch (e) {
    print("EE");
  }
  print("################### test003");
  try {
    stun.StunClientSendHeaderResult r = await client.test003(version: version);
    print("-z- ${r.remoteAddress} ${r.remotePort} ${r.header.mappedAddress()} ${r.header.mappedPort()}");
  } catch (e) {
    print("EE");
  }

  print("###################");
}
