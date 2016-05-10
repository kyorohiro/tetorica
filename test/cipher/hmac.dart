import 'dart:typed_data' show Uint8List;
import 'package:tetorica/cipher/hmac.dart';
import 'package:crypto/crypto.dart' as cry;
import 'dart:math' as math;

void main() {
  int size = 1024*1024;
  Uint8List data = new Uint8List(size);

  math.Random r = new math.Random();
  for (int i = 0; i < size; i++) {
    data[i] = r.nextInt(0xff) & 0xff;
  }

  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;

    cry.HMAC hmac = new cry.HMAC(
      new cry.SHA1(), //
      new Uint8List.fromList( //
        [ 0x82, 0xf3, 0xb6, 0x9a, 0x1b, 0xff, 0x4d, 0xe1, 0x5c, 0x33 ]));//
    //
    hmac.add(data);
    var v = hmac.close();
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v} ${d2-d1}");
  }
  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;

    HMAC hmac = new HMAC.SHA1(new Uint8List.fromList( //
      [ 0x82, 0xf3, 0xb6, 0x9a, 0x1b, 0xff, 0x4d, 0xe1, 0x5c, 0x33 ]));

    var v = hmac.calcHMAC(data);
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v} ${d2-d1}");
  }
}
