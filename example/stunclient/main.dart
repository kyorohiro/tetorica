import 'package:tetorica/net.dart' as net;
import 'package:tetorica/net_dartio.dart' as dartio;
import 'package:tetorica/stun.dart' as stun;

main(List<String> args) async {
  net.TetSocketBuilder builder = new dartio.TetSocketBuilderDartIO();
  if(args.length != 4) {
    print("dart xxx.dart [primary ip] [primary port] [secondary ip] [secondary port]");
    return;
  }
  String primaryIP = args[0];
  int primaryPort = int.parse(args[1]);
  String secondaryIP = args[2];
  int secondaryPort = int.parse(args[3]);

  stun.StunServer server = new stun.StunServer(builder,
    primaryIP,
    primaryPort,
    secondaryIP,
    secondaryPort);

  await server.go();
}
