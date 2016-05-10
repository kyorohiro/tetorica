import 'dart:typed_data' show Uint8List;
import 'package:tetorica/cipher/sha1.dart';
import 'package:crypto/crypto.dart' as cry;
import 'dart:math' as math;

void main() {
  int size = 1000000;
  List<int> data = new Uint8List(size);

  math.Random r = new math.Random();
  for (int i = 0; i < size; i++) {
    data[i] = r.nextInt(0xff) & 0xff;
  }

  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;
    cry.SHA1 sha1 = new cry.SHA1();
    sha1.add(data);
    var v = sha1.close();
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
  {
    int d1 = new DateTime.now().millisecondsSinceEpoch;
    SHA1 sha = new SHA1();
    var v = sha.calcSha1(new Uint8List.fromList(data));
    int d2 = new DateTime.now().millisecondsSinceEpoch;
    print(" ${v}  ${d2-d1}");
  }
}
