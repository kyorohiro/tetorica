import 'package:tetorica/net.dart' as net;
import 'package:tetorica/net_dartio.dart' as dartio;
import 'package:tetorica/stun.dart' as stun;

main(List<String> args) async {
  net.TetSocketBuilder builder = new dartio.TetSocketBuilderDartIO();
  if(args.length != 2) {
    print("dart xxx.dart [primary ip] [primary port]");
    return;
  }
  //String primaryIP = args[0];
  //int primaryPort = int.parse(args[1]);

  for(net.TetNetworkInterface i in await builder.getNetworkInterfaces()) {
    print("## ${i}");
  }
//  stun.StunClient client = new stun.StunClient(builder, primaryIP, primaryPort);
//  client.testStunType(ipList);
}
