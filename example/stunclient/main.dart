import 'package:tetorica/net.dart' as net;
import 'package:tetorica/net_dartio.dart' as dartio;
import 'package:tetorica/stun.dart' as stun;

main(List<String> args) async {
  net.TetSocketBuilder builder = new dartio.TetSocketBuilderDartIO();
  if (args.length < 2) {
    print("dart xxx.dart <primary ip> <primary port> [<client ip>] ");
    return;
  }
  String primaryIP = args[0];
  int primaryPort = int.parse(args[1]);

  String clientIp = null;
  if (args.length >= 3) {
    clientIp = args[2];
  }

  if (clientIp != null) {
    print("#A#[${clientIp}]");
    await checkIP(builder, clientIp, primaryIP, primaryPort);
    return;
  }
  for (net.TetNetworkInterface i in await builder.getNetworkInterfaces()) {
    print("#B#[${i}]");
    await checkIP(builder, i.address, primaryIP, primaryPort);
  }
}

checkIP(net.TetSocketBuilder builder, String address, String primaryIP, int primaryPort) async {
  net.IPAddr addr = new net.IPAddr.fromString(address);
  if (addr.isLocalHost() == true || addr.isLinkLocal() == true || addr.isV6() == true) {
    return;
  }
  try {
    print("   ${addr.toString()}");
    stun.StunClient client = new stun.StunClient(builder, addr.toString(), 18081, primaryIP, primaryPort);
    print("   ${await client.testStunType()}");
  } catch (e) {
    ;
  }
  print("\n");
}
