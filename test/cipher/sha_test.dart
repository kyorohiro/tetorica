import 'dart:typed_data' show Uint8List;
import 'package:tetorica/cipher/sha1.dart';
import 'package:crypto/crypto.dart' as cry;
import 'dart:math' as math;

void main() {
  int size = 512*1024;
  List<int> data = new Uint8List(size);

  math.Random r = new math.Random();
  for (int i = 0; i < size; i++) {
    data[i] = r.nextInt(0xff) & 0xff;
  }

  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;
    var v;
    for (int i = 0; i < 20; i++) {
      cry.SHA1 sha1 = new cry.SHA1();
      sha1.add(data.sublist(0,size~/2));
      sha1.add(data.sublist(size~/2));
      v = sha1.close();
    }
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;
    var v;
    for (int i = 0; i < 20; i++) {
      SHA1 sha = new SHA1();
      sha.sha1Reset();
      sha.sha1Input(data.sublist(0,size~/2),size~/2);
      sha.sha1Input(data.sublist(size~/2),size~/2);
      v = sha.sha1Result();
    }
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
}
