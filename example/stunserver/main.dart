import 'package:tetorica/net.dart' as net;
import 'package:tetorica/net_dartio.dart' as dartio;
import 'package:tetorica/stun.dart' as stun;

main(List<String> args) async {
  net.TetSocketBuilder builder = new dartio.TetSocketBuilderDartIO();
  if(args.length != 4) {
    print("dart xxx.dart [primary ip] [primary port] [secondary ip] [secondary port]");
    
    return;
  } else {

  }


}
