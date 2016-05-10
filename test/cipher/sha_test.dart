import 'dart:typed_data' show Uint8List;
import 'package:tetorica/cipher/sha1.dart';
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
    var v;
    for (int i = 0; i < 500; i++) {
      cry.SHA1 sha1 = new cry.SHA1();
//      sha1.add(data.sublist(0,size~/2));
//      sha1.add(data.sublist(size~/2));
      sha1.add(data);
      v = sha1.close();
    }
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;
    var v;
    SHA1 sha = new SHA1();
    Uint8List output = new Uint8List(20);
    for (int i = 0; i < 500; i++) {
      sha.sha1Reset();
      //sha.sha1Input(data.sublist(0,size~/2),size~/2);
      //sha.sha1Input(data.sublist(size~/2),size~/2);
      sha.sha1Input(data,size);
      v = sha.sha1Result(output: output);
    }
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
}
